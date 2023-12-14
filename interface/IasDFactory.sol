// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IasDFactory {

    function isAsD(address _address) external view returns (bool);

    function create(string memory _symbol, string memory _name) external;

    function note() external view returns (address);
}
