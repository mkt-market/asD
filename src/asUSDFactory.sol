// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import {Turnstile} from "../interface/Turnstile.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {asUSD} from "./asUSD.sol";

contract asUSDFactory is Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    address public note;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event CreatedToken(address token, string symbol, string name, address creator);
    
    /// @notice Initiates CSR on main- and testnet
    /// @param _note Address of the NOTE token
    constructor(address _note) {
        note = _note;
        if (block.chainid == 7700 || block.chainid == 7701) {
            // Register CSR on Canto main- and testnet
            Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
            turnstile.register(tx.origin);
        }
    }

    function create(string memory _symbol, string memory _name) external {
        asUSD createdToken = new asUSD(_symbol, _name, msg.sender, owner());
        emit CreatedToken(address(createdToken), _symbol, _name, msg.sender);
    }
}
