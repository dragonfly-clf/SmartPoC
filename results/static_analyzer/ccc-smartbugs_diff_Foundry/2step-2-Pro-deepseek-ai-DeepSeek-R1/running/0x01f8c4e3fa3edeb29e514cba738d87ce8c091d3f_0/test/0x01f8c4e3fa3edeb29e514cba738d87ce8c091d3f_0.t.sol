// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

contract PERSONAL_BANKTest is Test {
    PERSONAL_BANK public bank;
    LogFile public logFile;
    address user = makeAddr("user");

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        bank = new PERSONAL_BANK();
        
        // Set up bank with log file
        bank.SetLogFile(address(logFile));
        
        // Fund user account
        vm.deal(user, 100 ether);
    }

    function testTimestampManipulation() public {
        console.log("--- BEFORE-Trigger First Deposit ---");
        uint256 normalTime = block.timestamp;
        console.log("Normal block time:", normalTime);

        // First deposit with normal timestamp
        vm.prank(user);
        bank.Deposit{value: 1 ether}();

        // Retrieve first log entry
        (address firstSender, , uint256 firstNum1, uint256 firstNum2) = logFile.History(0);
        console.log("First deposit log entry:");
        console.log("Sender:", firstSender);
        console.log("Value1:", firstNum1);
        console.log("Value2:", firstNum2);

        console.log("--- Trigger Warp and Second Deposit ---");
        // Manipulate timestamp
        uint256 manipulatedTime = 1000;
        console.log("Manipulated time set to:", manipulatedTime);
        vm.warp(manipulatedTime);
        
        // Second deposit at manipulated timestamp
        vm.prank(user);
        bank.Deposit{value: 1 ether}();

        console.log("--- AFTER-Trigger Second Deposit Log ---");
        // Retrieve second log entry
        (address secondSender, , uint256 secondNum1, uint256 secondNum2) = logFile.History(1);
        console.log("Second deposit log entry:");
        console.log("Sender:", secondSender);
        console.log("Value1:", secondNum1);
        console.log("Value2:", secondNum2);

        console.log("--- Differential Check ---");
        // Check if manipulated timestamp appears in log
        bool timestampManipulated = (secondNum1 == manipulatedTime) || 
                                   (secondNum2 == manipulatedTime);
                                   
        // Final vulnerability verdict
        if (timestampManipulated) {
            console.log("Vulnerability Exists: Attacker can manipulate block.timestamp to forge log entries");
        } else {
            console.log("Vulnerability not Exist: Log timestamps are immune to block.timestamp manipulation");
        }
    }
}