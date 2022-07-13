// SPDX-LIcense-Identifier: UNLICENSED

pragma solidity ^0.8.14;

interface IPOOL {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external;
}
