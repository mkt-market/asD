// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import {Turnstile} from "../interface/Turnstile.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract asUSD is ERC20, Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Initiates CSR on main- and testnet
    /// @param _csrRecipient Address that should receive CSR rewards
    constructor(string memory _name, string memory _symbol, address _owner, address _csrRecipient) ERC20(_name, _symbol) {
        _transferOwnership(_owner);
        if (block.chainid == 7700 || block.chainid == 7701) {
            // Register CSR on Canto main- and testnet
            Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
            turnstile.register(_csrRecipient);
        }
    }
}
