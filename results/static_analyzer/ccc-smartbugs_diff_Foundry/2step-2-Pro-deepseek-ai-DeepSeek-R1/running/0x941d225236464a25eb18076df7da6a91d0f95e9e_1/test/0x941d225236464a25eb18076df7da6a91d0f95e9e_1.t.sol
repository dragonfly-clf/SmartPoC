// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x941d225236464a25eb18076df7da6a91d0f95e9e.sol";

contract Log_PredictableTimestampTest is Test {
    Log public logContract;
    address public user = address(0x1);
    
    function setUp() public {
        logContract = new Log();
    }

    function test_AddMessageUsesPredictableTimestamp() public {
        console.log("--- BEFORE-Trigger State ---");
        uint initialTimestamp = block.timestamp;
        console.log("Initial block.timestamp: ", initialTimestamp);
        console.log("Initial History index 0 should not exist yet");

        console.log("--- Trigger Operation ---");
        uint testTimestamp = 12345678;
        console.log("Warping block.timestamp to: ", testTimestamp);
        vm.warp(testTimestamp);

        console.log("Adding message with test payload...");
        logContract.AddMessage(user, 0, "Test");

        console.log("--- AFTER-Trigger State ---");
        (address sender, string memory data, uint val, uint storedTimestamp) = logContract.History(0);
        console.log("Stored timestamp in history: ", storedTimestamp);
        
        // Final verdict determination
        if (storedTimestamp == testTimestamp) {
            console.log("VULNERABILITY CONFIRMED: Stored timestamp matches manipulated block.timestamp");
            console.log("Vulnerability Exists: Contract uses predictable block.timestamp as seed");
        } else {
            console.log("VULNERABILITY NOT CONFIRMED: Timestamp values do not match");
            console.log("Vulnerability not Exist: Contract does not use block.timestamp as expected");
            // Fail test if vulnerability condition not met
            revert("Vulnerability verification failed");
        }
    }
}