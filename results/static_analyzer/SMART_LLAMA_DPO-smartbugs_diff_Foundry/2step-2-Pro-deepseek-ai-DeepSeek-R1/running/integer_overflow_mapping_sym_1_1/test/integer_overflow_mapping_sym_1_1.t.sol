// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowMappingSym1Test is Test {
    IntegerOverflowMappingSym1 public testedContract;
    address public testOperator = makeAddr("testOperator");
    bool private vulnerabilityExists;

    function setUp() public {
        vm.prank(testOperator);
        testedContract = new IntegerOverflowMappingSym1();
    }

    function test_TimestampManipulation() public {
        uint256 initialTimestamp = 100000; // Arbitrary baseline
        uint256 minerTimestamp = initialTimestamp + 15; // Miner manipulation range (typical 15s)

        // BEFORE: Capture pre-attack state
        console.log("--- BEFORE-Trigger State ---");
        uint256 preOpCount = testedContract.getUserOperationCount(testOperator);
        uint256 preLastTime = testedContract.lastOperationTime();
        console.log("Pre-Op Count:", preOpCount);
        console.log("Pre-Last Operation Time:", preLastTime);

        // Mine block with manipulated timestamp
        vm.warp(minerTimestamp);

        // Attack trigger
        console.log("--- Trigger: Perform Operation with Warped Timestamp ---");
        vm.prank(testOperator);
        testedContract.init(0, 0);

        // AFTER: Capture post-attack state
        console.log("--- AFTER-Trigger State ---");
        uint256 postOpCount = testedContract.getUserOperationCount(testOperator);
        uint256 postLastTime = testedContract.lastOperationTime();
        console.log("Post-Op Count:", postOpCount);
        console.log("Post-Last Operation Time:", postLastTime);

        // Compute differential state changes
        bool opCountChanged = (postOpCount == preOpCount + 1);
        bool lastTimeChanged = (postLastTime == minerTimestamp);
        vulnerabilityExists = opCountChanged && lastTimeChanged;

        console.log("State Change Results:");
        console.log("Operation Count changed:", opCountChanged ? "YES" : "NO");
        console.log("Last Time changed:", lastTimeChanged ? "YES" : "NO");

        // Verify state variables for test framework
        assertEq(postOpCount, preOpCount + 1);
        assertEq(postLastTime, minerTimestamp);
        
        // Test event emission
        vm.expectEmit(true, true, true, true);
        emit IntegerOverflowMappingSym1.OperationPerformed(
            testOperator, 
            0, 
            0, 
            minerTimestamp
        );
        
        // Perform another operation to verify event logging
        vm.prank(testOperator);
        testedContract.init(0, 0);

        // Final vulnerability verdict
        console.log("----------");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State successfully manipulated by attacker");
        } else {
            console.log("Vulnerability not Exist: State manipulation failed");
        }
    }
}