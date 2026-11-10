// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

contract LogTimestampTest is Test {
    Log internal logContract;
    uint constant TEST_TIMESTAMP = 12345678;

    function setUp() public {
        logContract = new Log();
    }

    function test_StoresDeterministicTimestamp() public {
        vm.warp(TEST_TIMESTAMP);
        
        address testAddress = address(0x123);
        uint testValue = 1 ether;
        string memory testData = "Test data";
        
        console.log("--- BEFORE-Trigger Storage Inspection ---");
        console.log("Block timestamp set to:");
        console.logUint(TEST_TIMESTAMP);
        
        // Record storage changes
        vm.record();
        console.log("--- Trigger AddMessage ---");
        logContract.AddMessage(testAddress, testValue, testData);
        
        console.log("--- AFTER-Trigger Storage Inspection ---");
        // Get storage slots that were written
        (, bytes32[] memory writtenSlots) = vm.accesses(address(logContract));
        
        bool foundTimestamp;
        
        for (uint i; i < writtenSlots.length; ++i) {
            bytes32 value = vm.load(address(logContract), writtenSlots[i]);
            console.log("Storage slot:");
            console.logBytes32(writtenSlots[i]);
            console.log("Slot value:");
            console.logUint(uint(value));
            
            if (uint(value) == TEST_TIMESTAMP) {
                foundTimestamp = true;
                console.log("Timestamp FOUND in storage slot");
                break;
            }
        }
        
        console.log("--- Vulnerability Verification ---");
        if (foundTimestamp) {
            console.log("Vulnerability Exists: Deterministic timestamp stored in manipulated block.timestamp");
        } else {
            console.log("Vulnerability not Exist: Contract doesn't store manipulatable timestamps");
        }
    }
}