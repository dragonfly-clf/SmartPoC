// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock public timeLock;
    address public victim;
    uint256 public constant MINER_TIMESTAMP_MANIPULATION = 900;
    
    function setUp() public {
        timeLock = new TimeLock();
        victim = address(0x1);
        vm.deal(victim, 10 ether);
    }

    function test_MinerTimestampManipulation() public {
        // Set initial timestamp for baseline
        uint256 baseTimestamp = block.timestamp;
        
        // Victim deposits under normal conditions
        vm.prank(victim);
        timeLock.deposit{value: 1 ether}();
        uint256 normalLockTime = timeLock.lockTime(victim);
        uint256 expectedNormalLockTime = baseTimestamp + 1 weeks;
        assertEq(normalLockTime, expectedNormalLockTime, "Normal lock time mismatch");
        
        // ----------------------- DIFFERENTIAL VALIDATION STARTS HERE -----------------------
        console.log("--- BEFORE-Trigger State ---");
        uint256 prevLockTime = timeLock.lockTime(victim);
        console.log("Lock time before attack:", prevLockTime);
        
        console.log("--- Triggering Miner Timestamp Manipulation ---");
        // Simulate miner timestamp manipulation
        uint256 manipulatedTimestamp = baseTimestamp + MINER_TIMESTAMP_MANIPULATION;
        vm.warp(manipulatedTimestamp);
        
        // Victim makes another deposit with manipulated timestamp
        vm.prank(victim);
        timeLock.deposit{value: 1 ether}();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 newLockTime = timeLock.lockTime(victim);
        console.log("Lock time after attack:", newLockTime);
        
        // Verify lock time extension due to miner manipulation
        uint256 lockTimeExtension = newLockTime - prevLockTime;
        console.log("Lock time increased by:", lockTimeExtension);
        console.log("Expected increase by:", MINER_TIMESTAMP_MANIPULATION);
        
        // Final vulnerability verdict
        if (lockTimeExtension == MINER_TIMESTAMP_MANIPULATION) {
            console.log("Vulnerability Exists: Miner timestamp manipulation extended lock time without cooldown enforcement");
        } else {
            console.log("Vulnerability not Exist: Lock time extension (%s) didn't match manipulation offset (%s)", 
                lockTimeExtension, MINER_TIMESTAMP_MANIPULATION);
        }
        // ----------------------- DIFFERENTIAL VALIDATION ENDS HERE -----------------------
    }
}