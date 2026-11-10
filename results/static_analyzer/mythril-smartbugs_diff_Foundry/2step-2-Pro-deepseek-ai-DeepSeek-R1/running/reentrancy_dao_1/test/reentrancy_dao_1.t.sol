// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_dao.sol";

contract ReentrancyDaoTest is Test {
    ReentrancyDAO public dao;

    function setUp() public {
        dao = new ReentrancyDAO();
    }

    function test_depositOverflow() public {
        // Set the initial balance to max uint - 1
        uint256 initialValue = type(uint256).max - 1;
        vm.store(address(dao), bytes32(uint256(1)), bytes32(initialValue));
        
        // Verify storage setup
        assertEq(dao.getContractBalance(), initialValue, "Initial DAO balance not set correctly");
        
        // Create a user with enough ether
        address user = makeAddr("user");
        vm.deal(user, 2);
        uint256 initialCredit = dao.getUserCredit(user);

        // 1️⃣ Log BEFORE state
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Contract Balance:", dao.getContractBalance());
        console2.log("User Credit:", initialCredit);
        
        console2.log("--- Trigger Deposit ---");
        // Deposit 2 wei causing overflow
        vm.prank(user);
        dao.deposit{value: 2}();
        
        // 2️⃣ Log AFTER state
        console2.log("--- AFTER-Trigger ---");
        uint256 newContractBalance = dao.getContractBalance();
        uint256 newUserCredit = dao.getUserCredit(user);
        console2.log("Contract Balance:", newContractBalance);
        console2.log("User Credit:", newUserCredit);

        // Differential validation
        console2.log("--- RESULT VERDICT ---");
        bool contractBalanceOverflowed = (newContractBalance == 0);
        bool userCreditUpdated = (newUserCredit == initialCredit + 2);
        
        console2.log("Contract balance reset to zero?", 
            contractBalanceOverflowed ? "YES" : "NO");
        
        console2.log("User credit updated correctly?",
            userCreditUpdated ? "YES" : "NO");

        // Final vulnerability verdict
        if (contractBalanceOverflowed && userCreditUpdated) {
            console2.log("Vulnerability Exists: deposit causes overflow resetting contract balance to zero");
        } else {
            console2.log("Vulnerability not Exist: deposit overflow not triggered or state update inconsistent");
        }

        // Original assertions remain
        assertEq(newContractBalance, 0, "Balance overflow not handled");
        assertEq(newUserCredit, initialCredit + 2, "User credit not updated correctly");
    }
}