// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x0cbe050f75bc8f8c2d6c0d249fea125fd6e1acc9.sol";

contract CallerTimestampTest is Test {
    Caller public caller;
    address public constant TEST_ADDRESS = address(0xABCD);

    function setUp() public {
        caller = new Caller();
    }

    function test_MinerCanManipulateTimestamp() public {
        bool firstCallSuccess = false;
        bool secondCallSuccess = false;
        
        console.log("--- BEFORE-First Trigger ---");
        uint256 originalTimestamp = block.timestamp;
        uint256 timestampepoch1 = originalTimestamp + 100 seconds;
        console.log("Original timestamp:", originalTimestamp);
        console.log("Attempting to warp to:", timestampepoch1);

        console.log("--- Trigger First Call ---");
        vm.warp(timestampepoch1);
        vm.recordLogs();
        caller.callAddress(TEST_ADDRESS);
        
        Vm.Log[] memory logs = vm.getRecordedLogs();
        uint256 timestampEvent1 = abi.decode(logs[0].data, (uint256));
        
        console.log("--- AFTER-First Trigger ---");
        console.log("Recorded timestamp in event:", timestampEvent1);
        firstCallSuccess = (timestampEvent1 == timestampepoch1);
        console.log("First timestamp manipulation:", firstCallSuccess ? "SUCCESS" : "FAILED");

        console.log("--- BEFORE-Second Trigger ---");
        uint256 timestampepoch2 = originalTimestamp + 300 seconds;
        console.log("Attempting to warp to:", timestampepoch2);

        console.log("--- Trigger Second Call ---");
        vm.warp(timestampepoch2);
        vm.recordLogs();
        caller.callAddress(TEST_ADDRESS);
        
        logs = vm.getRecordedLogs();
        uint256 timestampEvent2 = abi.decode(logs[0].data, (uint256));
        
        console.log("--- AFTER-Second Trigger ---");
        console.log("Recorded timestamp in event:", timestampEvent2);
        secondCallSuccess = (timestampEvent2 == timestampepoch2);
        console.log("Second timestamp manipulation:", secondCallSuccess ? "SUCCESS" : "FAILED");

        // Final vulnerability verdict
        if (firstCallSuccess && secondCallSuccess) {
            console.log("Vulnerability Exists: Miner was able to manipulate block.timestamp in both calls");
        } else {
            console.log("Vulnerability not Exist: Block.timestamp manipulation failed in one or both calls");
        }
    }
}