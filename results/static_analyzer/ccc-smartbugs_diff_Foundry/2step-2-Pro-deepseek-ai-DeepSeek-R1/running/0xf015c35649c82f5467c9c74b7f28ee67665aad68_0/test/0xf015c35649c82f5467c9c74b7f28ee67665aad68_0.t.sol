// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol";

contract MYBANKTest is Test {
    Log public logContract;
    MY_BANK public myBank;
    address public alice = makeAddr("alice");
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;
    uint256 public unlockTime;

    function setUp() public {
        logContract = new Log();
        myBank = new MY_BANK(address(logContract));
        vm.deal(alice, DEPOSIT_AMOUNT);

        unlockTime = block.timestamp + 1 days;
        vm.prank(alice);
        myBank.Put{value: DEPOSIT_AMOUNT}(unlockTime);
    }

    function testTimestampBypass() public {
        bool vulnExists = false;
        
        // Test withdrawal before unlock time
        console2.log("====== Scenario 1: Withdrawal BEFORE unlock time ======");
        console2.log("--- BEFORE-TRIGGER [pre-collect] ---");
        uint256 aliceBalanceBefore1 = address(alice).balance;
        uint256 bankBalanceBefore1 = address(myBank).balance;
        console2.log("Alice balance BEFORE:", aliceBalanceBefore1);
        console2.log("Contract balance BEFORE:", bankBalanceBefore1);
        
        vm.warp(unlockTime - 1);
        console2.log("--- TRIGGER: Collect call at %s unlock time minus 1 ---", unlockTime);
        vm.prank(alice);
        myBank.Collect(DEPOSIT_AMOUNT);
        
        console2.log("--- AFTER-TRIGGER [post-collect] ---");
        uint256 aliceBalanceAfter1 = address(alice).balance;
        uint256 bankBalanceAfter1 = address(myBank).balance;
        console2.log("Alice balance AFTER:", aliceBalanceAfter1);
        console2.log("Contract balance AFTER:", bankBalanceAfter1);
        
        if (aliceBalanceAfter1 != aliceBalanceBefore1 || bankBalanceAfter1 != bankBalanceBefore1) {
            console2.log("Verdict: UNEXPECTED change! Withdrawal succeeded BEFORE unlock - VULNERABILITY");
            vulnExists = true;
        } else {
            console2.log("Verdict: NO change - Withdrawal blocked before unlock (expected)");
        }

        // Test withdrawal at exact unlock time
        console2.log("====== Scenario 2: Withdrawal AT unlock time ======");
        console2.log("--- BEFORE-TRIGGER [pre-collect] ---");
        uint256 aliceBalanceBefore2 = address(alice).balance;
        uint256 bankBalanceBefore2 = address(myBank).balance;
        console2.log("Alice balance BEFORE:", aliceBalanceBefore2);
        console2.log("Contract balance BEFORE:", bankBalanceBefore2);
        
        vm.warp(unlockTime);
        console2.log("--- TRIGGER: Collect call at EXACT unlock time %s ---", unlockTime);
        vm.prank(alice);
        myBank.Collect(DEPOSIT_AMOUNT);
        
        console2.log("--- AFTER-TRIGGER [post-collect] ---");
        uint256 aliceBalanceAfter2 = address(alice).balance;
        uint256 bankBalanceAfter2 = address(myBank).balance;
        console2.log("Alice balance AFTER:", aliceBalanceAfter2);
        console2.log("Contract balance AFTER:", bankBalanceAfter2);
        
        if (aliceBalanceAfter2 != aliceBalanceBefore2 || bankBalanceAfter2 != bankBalanceBefore2) {
            console2.log("Verdict: UNEXPECTED change! Withdrawal succeeded AT unlock time - VULNERABILITY");
            vulnExists = true;
        } else {
            console2.log("Verdict: NO change - Withdrawal blocked at unlock time (expected)");
        }

        // Test withdrawal manipulation (warp from before to after)
        console2.log("====== Scenario 3: Warp manipulation ======");
        vm.warp(unlockTime - 1); // Reset to before unlock
        
        console2.log("--- BEFORE-TRIGGER [pre-manipulation] ---");
        uint256 aliceBalanceBefore3 = address(alice).balance;
        uint256 bankBalanceBefore3 = address(myBank).balance;
        console2.log("Current timestamp (BEFORE warp):", block.timestamp);
        console2.log("Alice balance BEFORE warp:", aliceBalanceBefore3);
        console2.log("Contract balance BEFORE warp:", bankBalanceBefore3);
        
        console2.log("--- TRIGGER: Warp to after unlock time + Collect call ---");
        vm.warp(unlockTime + 1);
        vm.prank(alice);
        myBank.Collect(DEPOSIT_AMOUNT);
        
        console2.log("--- AFTER-TRIGGER [post-manipulation] ---");
        uint256 aliceBalanceAfter3 = address(alice).balance;
        uint256 bankBalanceAfter3 = address(myBank).balance;
        console2.log("Alice balance AFTER (should increase):", aliceBalanceAfter3);
        console2.log("Contract balance AFTER (should decrease to 0):", bankBalanceAfter3);
        
        if (aliceBalanceAfter3 != aliceBalanceBefore3 + DEPOSIT_AMOUNT || bankBalanceAfter3 != 0) {
            console2.log("Verdict: State change did NOT occur as expected!");
        } else {
            console2.log("Verdict: State changed as expected (withdrawal succeeded)");
        }

        // Final vulnerability verdict
        if (vulnExists) {
            console2.log("Vulnerability Exists: Withdrawal succeeded before/at unlock time");
        } else {
            console2.log("Vulnerability not Exist: All before/at unlock withdrawals were blocked as expected");
        }
    }
}