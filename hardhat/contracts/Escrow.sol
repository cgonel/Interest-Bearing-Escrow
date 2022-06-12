// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

contract Escrow {
    address depositor;
    address beneficiary;
    uint amount;
    uint deadline;

    // address pool = "";
    // address asset = "";

    // step 1: only first escrow, approve factory to transfer user dai

    constructor(address _beneficiary, uint _amount, uint _deadline) {
        amount = _amount;
        deadline = _deadline;
        depositor = msg.sender;
        beneficiary = _beneficiary;


        // deposits the money in pool
    }

    function releaseFunds() external {
        // only owner
        // withdraw from pool
        // send funds to the beneficiary
        // send funds to self // selfdestruct contract
    }

    function withdraw() external {
        // only when time has elasped
        // only owner
        // withdraw the rest of the funds
    }
 
}

contract EscrowFactory {
    // store all contracts? // associate contract to an address for retrieval ?

    function createEscrow() external {}
}