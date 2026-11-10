// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

contract LogFilePredictableTimestampTest is Test {
    PERSONAL_BANK public bank;
    LogFile public logContract;
    address public user = address(0x123);

    function setUp() public {
        // Deploy LogFile contract
        logContract = new LogFile();
        
        // Deploy PERSONAL_BANK and configure it
        bank = new PERSONAL_BANK();
        bank.SetLogFile(address(logContract));
        bank.SetMinSum(0);
    }

    function testPredictableTimestampInLog() public {
        // Fund user with enough ether
        vm.deal(user, 1 ether);

        // Set predictable timestamp
        uint fixedTimestamp = 1000;
        vm.warp(fixedTimestamp);

        console.log("--- TRIGGER OPERATION ---");
        // Execute deposit to trigger log entry
        vm.prank(user);
        bank.Deposit{value: 0.1 ether}();

        // Check first 10 storage slots for the fixed timestamp value
        bool foundTimestamp = false;
        for (uint slot = 0; slot < 10; slot++) {
            bytes32 loaded = vm.load(address(logContract), bytes32(slot));
            if (uint256(loaded) == fixedTimestamp) {
                foundTimestamp = true;
                break;
            }
        }

        // Exploitation verdict
        if (foundTimestamp) {
            console.log("Vulnerability Exists: Predictable timestamp found in log storage");
        } else {
            console.log("Vulnerability not Exist: Predictable timestamp not found in log storage");
        }

        assertTrue(foundTimestamp, "Predictable timestamp not found in log storage");
    }
}