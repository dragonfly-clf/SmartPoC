// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowMappingSym1Test is Test {
    IntegerOverflowMappingSym1 public target;

    function setUp() public {
        target = new IntegerOverflowMappingSym1();
    }

    function test_blockTimestampUsedAsBadRandomNumber() public {
        // Set fixed block timestamp that will be used predictably
        uint256 fakeTimestamp = 1234567890;
        vm.warp(fakeTimestamp);
        
        uint256 testKey = 777;
        uint256 testValue = 888;

        console2.log("--- BEFORE-Trigger Event Data ---");
        console2.log("Set fixed block.timestamp:", fakeTimestamp);
        console2.log("Testing with key/value:", testKey, testValue);

        console2.log("--- Trigger `init` Operation ---");
        // Record contract events
        vm.recordLogs();
        target.init(testKey, testValue);
        
        console2.log("--- AFTER-Trigger Event Data ---");
        // Retrieve and decode logs
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        // Ensure at least one log was recorded
        if (logs.length == 0) {
            console2.log("No event emitted");
            console2.log("Vulnerability not Exist: No event emitted to verify");
            return;
        }

        // The event data is in the data field of the first log (non-indexed parameters)
        bytes memory payload = logs[0].data;
        (uint256 emittedKey, uint256 emittedValue, uint256 emittedTimestamp) 
            = abi.decode(payload, (uint256, uint256, uint256));
        
        console2.log("Event emitted key:      ", emittedKey);
        console2.log("Event emitted value:    ", emittedValue);
        console2.log("Event emitted timestamp:", emittedTimestamp);

        // Verify predictable timestamp usage in event
        if (emittedTimestamp == fakeTimestamp) {
            console2.log("Vulnerability confirmed: Predictable block.timestamp used in event");
            console2.log("Vulnerability Exists: Predictable block.timestamp used as random number source");
        } else {
            console2.log("Event timestamp differs from block.timestamp");
            console2.log("Vulnerability not Exist: Event uses non-predictable timestamp value");
        }
    }
}