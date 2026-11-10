// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract TimestampManipulationTest is Test {
    IntegerOverflowMappingSym1 public targetContract;
    address public constant TEST_USER = address(0x123);

    function setUp() public {
        targetContract = new IntegerOverflowMappingSym1();
    }

    function testTimestampManipulation() public {
        console.log("--- BEFORE-Trigger Operation ---");
        uint256 initialTime = targetContract.lastOperationTime();
        console.log("Initial lastOperationTime: %d", initialTime);

        uint256 baseTimestamp = block.timestamp;
        uint256 futureTimestamp = baseTimestamp + 10000;

        console.log("--- Trigger TimestampManipulation ---");
        // Miner manipulates the timestamp to a future value
        vm.warp(futureTimestamp);
        
        // Perform operation with manipulated timestamp
        vm.prank(TEST_USER);
        targetContract.init(1, 1); // Arbitrary values for k and v

        console.log("--- AFTER-Trigger Operation ---");
        uint256 updatedTime = targetContract.lastOperationTime();
        console.log("Updated lastOperationTime: %d", updatedTime);

        bool vulnerabilityExists = (initialTime == 0 && updatedTime == futureTimestamp);
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Timestamp was successfully manipulated to future value");
        } else {
            console.log("Vulnerability not Exist: Timestamp manipulation failed - expected %d but got %d", futureTimestamp, updatedTime);
        }
    }
}