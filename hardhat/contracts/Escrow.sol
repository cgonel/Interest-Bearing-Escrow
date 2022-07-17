// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IPool.sol";

contract Escrow is Ownable, AccessControl {
    address public depositor;
    address public beneficiary;
    uint public amount;
    uint public deadline;
    bytes32 public constant KEEPER = keccak256("KEEPER");

    IPOOL pool = IPOOL(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
    IERC20 dai = IERC20(0xE0FbA4fC209B4948668006B2Be61711B7F465baF);

    // step 1: approve contract to transfer user dai

    constructor(address _beneficiary, uint _amount, uint _deadline) {
        amount = _amount;
        deadline = block.timestamp + _deadline;
        depositor = tx.origin;
        beneficiary = _beneficiary;

        // deposit the money in pool
        dai.transferFrom(depositor, address(this), _amount);
        dai.approve(address(pool), _amount);
        pool.deposit(address(dai), _amount, address(this), 0);
        // transfer ownership of contract to depositor
        transferOwnership(depositor);
        // set keeper
        // _setupRole(KEEPER, account); // ** gelato contract address

    }

    function releaseFunds() external onlyOwner {
        pool.withdraw(address(dai), amount, beneficiary);
        pool.withdraw(address(dai), type(uint).max, msg.sender);
    }

    // only callable by gelato keeper
    function cancelEscrow() external {
        require(hasRole(KEEPER, msg.sender));
        require(block.timestamp > deadline, "Active Escrow");
        pool.withdraw(address(dai), type(uint).max, depositor);
    }

}

contract EscrowFactory {
    event EscrowCreated(address indexed depositor, address beneficiary, uint amount);

    function createEscrow(address _beneficiary, uint _amount, uint _deadline) external {
        new Escrow(_beneficiary, _amount, _deadline);

        // gas optimization: emit event instead of storing in array
        // emit EscrowCreated(address ,_beneficiary,_amount);
    }
}

// look into clone proxy