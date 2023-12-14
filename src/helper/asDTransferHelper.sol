// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {Turnstile} from "../../interface/Turnstile.sol";
import {IasDFactory} from "../../interface/IasDFactory.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {CTokenInterface, CErc20Interface} from "../../interface/clm/CTokenInterfaces.sol";
import {asD} from "../asD.sol";
import {asDTransferCallback} from "./asDTransferCallback.sol";

/// @notice Auxiliary contract that can be used for the integration of ASD with certain applications
contract asDTransferHelper {
    IasDFactory public immutable asdFactory;
    address public immutable cNote;

    constructor(address _asdFactory, address _cNote) {
        asdFactory = IasDFactory(_asdFactory);
        cNote = _cNote;
        if (block.chainid == 7700 || block.chainid == 7701) {
            // Register CSR on Canto main- and testnet
            Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
            turnstile.register(tx.origin);
        }
    }

    function mintTo(
        uint256 _amount,
        address _recipient,
        address _asdToken
    ) external {
        require(asdFactory.isAsD(_asdToken), "Only asD tokens can be minted");
        CErc20Interface cNoteToken = CErc20Interface(cNote);
        IERC20 note = IERC20(cNoteToken.underlying());
        SafeERC20.safeTransferFrom(note, msg.sender, address(this), _amount);
        SafeERC20.safeApprove(note, _asdToken, _amount);
        asD(_asdToken).mint(_amount);
        SafeERC20.safeTransfer(IERC20(_asdToken), _recipient, _amount);
        asDTransferCallback(_asdToken).receiveFrom(msg.sender, _amount, _asdToken);
    }

    function burnTo(
        uint256 _amount,
        address _recipient,
        address _asdToken
    ) external {
        require(asdFactory.isAsD(_asdToken), "Only asD tokens can be burned");
        CErc20Interface cNoteToken = CErc20Interface(cNote);
        IERC20 note = IERC20(cNoteToken.underlying());
        asD(_asdToken).burn(_amount);
        SafeERC20.safeTransfer(note, _recipient, _amount);
    }
}
