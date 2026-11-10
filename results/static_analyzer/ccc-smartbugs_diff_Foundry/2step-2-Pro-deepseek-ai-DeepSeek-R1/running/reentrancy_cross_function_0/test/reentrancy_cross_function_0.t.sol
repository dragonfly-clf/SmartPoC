// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract ReentrancyCrossFunctionTest is Test {
    Reentrancy_cross_function reentrancy;
    address alice;

    function setUp() public {
        // Set initial timestamp to base time for first withdrawal to succeed
        vm.warp(86400); // Exactly 24 hours after epoch
        reentrancy = new Reentrancy_cross_function();
        alice = address(0xABCD);
        vm.deal(alice, 10 ether);
    }

    function test_TimestampManipulation() public {
        uint256 baseTime = block.timestamp;

        // First deposit and withdrawal
        vm.startPrank(alice);
        reentrancy.deposit{value: 1 ether}();
        reentrancy.withdrawBalance();
        vm.stopPrank();

        // Deposit again for next withdrawal test
        vm.prank(alice);
        reentrancy.deposit{value: 1 ether}();

        // Try withdrawing too early - should fail
        vm.warp(baseTime + 23 hours + 55 minutes);
        vm.expectRevert("Can only withdraw once per day");
        vm.prank(alice);
        reentrancy.withdrawBalance();

        // Miner manipulation: warp to just after cooldown period
        vm.warp(baseTime + 24 hours + 1 minutes);
        
        // Differential validation: before withdrawal state
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 aliceBalanceBefore = reentrancy.getBalance(alice);
        uint256 totalWithdrawalsBefore = reentrancy.totalWithdrawals();
        console.log("Alice's contract balance before:", aliceBalanceBefore);
        console.log("Total withdrawals before:", totalWithdrawalsBefore);
        
        // Critical vulnerability trigger
        console.log("--- Trigger Withdrawal ---");
        vm.prank(alice);
        reentrancy.withdrawBalance();

        // Differential validation: after withdrawal state
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 aliceBalanceAfter = reentrancy.getBalance(alice);
        uint256 totalWithdrawalsAfter = reentrancy.totalWithdrawals();
        console.log("Alice's contract balance after:", aliceBalanceAfter);
        console.log("Total withdrawals after:", totalWithdrawalsAfter);

        // Calculate state changes
        uint256 aliceBalanceChange = aliceBalanceBefore - aliceBalanceAfter;
        uint256 withdrawalsChange = totalWithdrawalsAfter - totalWithdrawalsBefore;

        console.log("Alice balance change:", aliceBalanceChange);
        console.log("Withdrawals change:", withdrawalsChange);
        
        // Print final verdict
        if (aliceBalanceChange == 1 ether && withdrawalsChange == 1 ether) {
            console.log("Vulnerability Exists: Successfully withdrew funds during cooldown period");
        } else {
            console.log("Vulnerability not Exist: Withdrawal did not change state as expected");
        }

        // Verify successful withdrawal
        assertEq(reentrancy.getBalance(alice), 0, "Balance not cleared");
    }
}