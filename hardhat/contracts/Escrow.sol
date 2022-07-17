// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./IPool.sol";

contract Escrow is Ownable, AccessControl {
    bool initialized;
    address public depositor;
    address public beneficiary;
    uint public amount;
    uint public deadline;
    bytes32 public constant KEEPER = keccak256("KEEPER");

    IPOOL pool = IPOOL(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
    IERC20 dai = IERC20(0xE0FbA4fC209B4948668006B2Be61711B7F465baF);

    // step 1: approve contract to transfer user dai

    /// @notice initialize the escrow, called by the EscrowCloneFactory
    /// @dev sends the escrow amount to AAVE Protocol and sets the contract keeper
    /// @param _beneficiary account that will receive the amount
    /// @param _amount the amount to be escrowed
    /// @param _deadline time by which the escrow will be cancelled if the service hasn't been provided
    function init(address _beneficiary, uint _amount, uint _deadline) external onlyOwner {
        require(!initialized, "Escrow has been initialized");
        amount = _amount;
        deadline = block.timestamp + _deadline;
        depositor = tx.origin;
        beneficiary = _beneficiary;

        // deposit the money in pool
        dai.transferFrom(depositor, address(this), _amount);
        dai.approve(address(pool), _amount);
        pool.deposit(address(dai), _amount, address(this), 0);

        // set keeper
        // _setupRole(KEEPER, account); // ** gelato contract address
    }

    /// @notice called by depositor to release funds to beneficiary
    /// @dev only callable by the depositor
    function releaseFunds() external onlyOwner {
        pool.withdraw(address(dai), amount, beneficiary);
        pool.withdraw(address(dai), type(uint).max, msg.sender);
    }

    /// @notice cancel the escrow
    /// @dev only callable by gelato keeper
    function cancelEscrow() external {
        require(hasRole(KEEPER, msg.sender));
        require(block.timestamp > deadline, "Active Escrow");
        pool.withdraw(address(dai), type(uint).max, depositor);
    }

}

contract EscrowCloneFactory {
    // **change address
    address public immutable ESCROW = 0xf5A772D78467f77cfF79e6c17cDD3A27e0C13fAc;

    // **make implementation upgradeable?

    /// @notice emits event of new escrow created
    /// @param depositor account that will deposit the amount
    /// @param beneficiary account that will receive the amount
    /// @param amount the amount to be escrowed
    event EscrowCreated(address indexed depositor, address beneficiary, uint amount);

    /// @notice create clone and initialize the escrow
    /// @param _beneficiary account that will receive the amount
    /// @param _amount the amount to be escrowed
    /// @param _deadline time by which the escrow will be cancelled if the service hasn't been provided
    function createEscrow(address _beneficiary, uint _amount, uint _deadline) external {
        address instance = Clones.clone(ESCROW);
        Escrow(instance).init(_beneficiary, _amount, _deadline);
        Escrow(instance).transferOwnership(msg.sender);

        // gas optimization: emit event instead of storing in array
        emit EscrowCreated(msg.sender ,_beneficiary,_amount);
    }
}
