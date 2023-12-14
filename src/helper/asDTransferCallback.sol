// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;


contract asDTransferCallback {

    address immutable asDHelper;

    constructor(address _asdHelper) {
        asDHelper = _asdHelper;
    }

    function receiveFrom(address _sender, uint256 _amount, address _asdToken) external {
        require(msg.sender == asDHelper, "Only asDTransferHelper can call this function");
        _onReceiveFrom(_sender, _amount, _asdToken);
    }

    function _onReceiveFrom(address _sender, uint256 _amount, address _asdToken) internal virtual {
        // To be implemented by child contracts
    }

}
