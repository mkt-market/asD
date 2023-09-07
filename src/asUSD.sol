// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import {Turnstile} from "../interface/Turnstile.sol";
import {IasUSDFactory} from "../interface/IasUSDFactory.sol";
import {CTokenInterface, CErc20Interface} from "../interface/clm/CTokenInterfaces.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract asUSD is ERC20, Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    IasUSDFactory public factory;
    
    /// @notice Initiates CSR on main- and testnet
    /// @param _name Name of the token
    /// @param _symbol Symbol of the token
    /// @param _owner Initial owner of the vault/token
    /// @param _csrRecipient Address that should receive CSR rewards
    constructor(string memory _name, string memory _symbol, address _owner, address _csrRecipient) ERC20(_name, _symbol) {
        _transferOwnership(_owner);
        factory = IasUSDFactory(msg.sender);
        if (block.chainid == 7700 || block.chainid == 7701) {
            // Register CSR on Canto main- and testnet
            Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
            turnstile.register(_csrRecipient);
        }
    }

    /// @notice Mint amount of asUSD tokens by providing NOTE. The NOTE:asUSD exchange rate is always 1:1 
    /// @param _amount Amount of tokens to mint
    /// @dev User needs to approve the asUSD contract for _amount of NOTE 
    function mint(uint256 _amount) external {
        CErc20Interface cNote = CErc20Interface(factory.note());
        IERC20 note = IERC20(cNote.underlying());
        SafeERC20.safeTransferFrom(note, msg.sender, address(this), _amount);
        SafeERC20.safeApprove(note, address(cNote), _amount);
        uint256 returnCode = cNote.mint(_amount);
        // Mint returns 0 on success: https://docs.compound.finance/v2/ctokens/#mint
        require(returnCode == 0, "Error when minting");
        _mint(msg.sender, _amount);
    }

    /// @notice Burn amount of asUSD tokens to get back NOTE. Like when minting, the NOTE:asUSD exchange rate is always 1:1
    /// @param _amount Amount of tokens to burn
    function burn(uint256 _amount) external {
        CErc20Interface cNote = CErc20Interface(factory.note());
        IERC20 note = IERC20(cNote.underlying());
        uint256 returnCode = cNote.redeemUnderlying(_amount); // Request _amount of NOTE (the underlying of cNOTE)
        require(returnCode == 0, "Error when redeeming"); // 0 on success: https://docs.compound.finance/v2/ctokens/#redeem-underlying
        _burn(msg.sender, _amount);
        SafeERC20.safeTransfer(note, msg.sender, _amount);
    }
}
