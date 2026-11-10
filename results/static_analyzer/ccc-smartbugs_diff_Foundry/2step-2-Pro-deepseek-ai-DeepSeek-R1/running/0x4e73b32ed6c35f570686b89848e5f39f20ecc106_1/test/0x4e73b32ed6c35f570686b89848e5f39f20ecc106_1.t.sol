// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract LogFile_Test is Test {
    PRIVATE_ETH_CELL private ethCell;
    LogFile private logFile;
    address testSender = address(0xABCD);

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        ethCell = new PRIVATE_ETH_CELL();
        
        // Setup log file
        ethCell.SetLogFile(address(logFile));
    }

    function test_AddMessageUsesPredictableTimestamp() public {
        uint256 testValue = 1 ether;
        bool hasInitialLogs = false;

        console2.log("--- BEFORE-Trigger Deposit ---");
        // Check initial log status
        try logFile.History(0) returns (address, string memory, uint256, uint256) {
            console2.log("Warning: Initial log entries exist");
            hasInitialLogs = true;
        } catch {
            console2.log("No initial logs found");
        }
        uint256 initialTimestamp = block.timestamp;
        console2.log("Current block timestamp:", initialTimestamp);
        
        console2.log("--- Trigger Deposit ---");
        vm.deal(testSender, testValue);
        vm.prank(testSender);
        ethCell.Deposit{value: testValue}();
        
        console2.log("--- AFTER-Trigger Deposit ---");
        bool vulnerabilityExists = false;
        string memory reason;

        if (hasInitialLogs) {
            reason = "Initial logs present, verification skipped";
        } else {
            try logFile.History(0) returns (address, string memory, uint256 newEntryTime, uint256) {
                console2.log("Actual log timestamp:", newEntryTime);
                console2.log("Expected timestamp:", initialTimestamp);
                
                if (newEntryTime == initialTimestamp) {
                    vulnerabilityExists = true;
                    reason = "Log timestamp equals predictable block.timestamp";
                    console2.log("VULNERABLE: Recorded timestamp matches block timestamp!");
                } else {
                    reason = "Log timestamp differs from block timestamp";
                    console2.log("Timestamp mismatch - not vulnerable");
                }
            } catch {
                reason = "No new logs created post-deposit";
                console2.log(reason);
            }
        }

        vulnerabilityExists 
            ? console2.log("Vulnerability Exists:", reason)
            : console2.log("Vulnerability not Exist:", reason);
    }
}