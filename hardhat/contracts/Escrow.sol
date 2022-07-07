// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPOOL.sol";

contract Escrow is Ownable {
    address depositor;
    address beneficiary;
    uint amount;
    uint deadline;

    IPOOL pool = IPOOL(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
    IERC20 dai = IERC20(0xE0FbA4fC209B4948668006B2Be61711B7F465baF);

    // step 1: only first escrow, approve factory to transfer user dai

    constructor(address _beneficiary, uint _amount, uint _deadline) {
        amount = _amount;
        deadline = _deadline;
        depositor = msg.sender; // change when created by contract factory
        beneficiary = _beneficiary;

        // deposits the money in pool
        pool.deposit(address(dai), _amount, address(this), 0);
        // transfer ownership of contract to depositor
        transferOwnership(depositor);

    }

    function releaseFunds() external onlyOwner {
        // only owner
        // withdraw from pool
        // send funds to the beneficiary
        // send funds to self // selfdestruct contract
        pool.withdraw(address(dai), amount, beneficiary);
    }

    function withdraw() external onlyOwner {
        // only when time has elasped
        // only owner
        // withdraw the rest of the funds
        pool.withdraw(address(dai), type(uint).max, msg.sender);
    }
 
}

contract EscrowFactory {
    // store all contracts? // associate contract to an address for retrieval ?

    function createEscrow() external {}
}