// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaf51e761510c1a11bf48dd87c0307ac8a8c8a4f.sol";

contract ETHVaultTimestampTest is Test {
    ETH_VAULT public vault;
    Log public logger;

    address user = makeAddr("user");
    uint256 depositAmount;

    // Helper function to count log entries
    function countLogs() internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < 100; i++) {
            try logger.History(i) {
                count++;
            } catch {
                break;
            }
        }
        return count;
    }
    
    // Helper to convert string to uint for timestamp comparison
    function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }

    function setUp() public {
        // Deploy contracts
        logger = new Log();
        vault = new ETH_VAULT(address(logger));
        uint256 minDeposit = vault.MinDeposit();
        depositAmount = minDeposit + 1; // Ensure deposit exceeds minDeposit

        // Fund user with sufficient ether
        vm.deal(user, depositAmount * 2);
    }

    function test_TimestampManipulation() public {
        // Use positive future timestamps instead of past dates
        uint256 futureTime = block.timestamp + 1 days;

        // Setup deposit parameters
        vm.startPrank(user);
        vault.Deposit{value: depositAmount}();
        vm.stopPrank();

        console.log("--- BEFORE-Trigger Log Check ---");
        uint256 logsBefore = countLogs();
        console.log("Number of log entries BEFORE CashOut:", logsBefore);
        require(logsBefore > 0, "No logs exist yet");

        // Get last log entry data (correct 4-field destructuring)
        (, string memory dateStringBefore, , ) = logger.History(logsBefore - 1);
        uint256 timeBefore = stringToUint(dateStringBefore);
        console.log("Parsed timestamp BEFORE CashOut:", timeBefore);

        // Setup for cashout with future timestamp
        vm.warp(futureTime); // Set to future time

        vm.startPrank(user);
        console.log("--- Trigger CashOut ---");
        uint256 initialUserBalance = user.balance;
        vault.CashOut(depositAmount);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Log Check ---");
        uint256 logsAfter = countLogs();
        // Ensure new log was created
        require(logsAfter > logsBefore, "No new log entry was created");
        console.log("Number of log entries AFTER CashOut:", logsAfter);

        // Get new last log entry data
        (, string memory dateStringAfter, , ) = logger.History(logsAfter - 1);
        uint256 timeAfter = stringToUint(dateStringAfter);
        console.log("Parsed timestamp AFTER CashOut:", timeAfter);

        // Verify state changes
        assertEq(vault.balances(user), 0, "Vault balance should be zero after cashout");
        console.log("User balance after cashout:", user.balance);

        // Check if timestamp was manipulated
        bool isTimestampManipulated = (timeAfter == futureTime);
        console.log("Timestamps equal futureTime?", isTimestampManipulated ? "YES" : "NO");

        // Final vulnerability verdict
        if (isTimestampManipulated) {
            console.log("Vulnerability Exists: Log recorded future timestamp successfully");
        } else {
            console.log("Vulnerability not Exist: Log did not record future timestamp");
        }
    }
}