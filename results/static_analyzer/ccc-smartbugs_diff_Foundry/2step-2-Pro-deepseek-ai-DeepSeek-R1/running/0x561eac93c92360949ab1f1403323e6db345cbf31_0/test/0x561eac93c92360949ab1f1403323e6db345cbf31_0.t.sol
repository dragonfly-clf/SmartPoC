// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract TimestampManipulationTest is Test {
    BANK_SAFE public bank;
    LogFile public logFile;
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        bank = new BANK_SAFE();

        // Configure BANK_SAFE with LogFile
        bank.SetLogFile(address(logFile));

        // Set user balance
        vm.deal(user, 1 ether);
    }

    function test_timestampManipulation() public {
        vm.startPrank(user);

        console.log("--- BEFORE-Trigger State ---");
        console.log("Current block.timestamp: %s", block.timestamp);
        console.log("User ETH balance: %s", address(user).balance);
        console.log("Bank contract ETH balance: %s", address(bank).balance);

        uint256 initialTimestamp = block.timestamp;
        uint256 newTimestamp = initialTimestamp + 100 days;

        console.log("--- Trigger ---");
        console.log("Warping block.timestamp by 100 days to %s", newTimestamp);
        vm.warp(newTimestamp);
        
        bool depositSuccess = false;
        try bank.Deposit{value: 0.5 ether}() {
            depositSuccess = true;
        } catch Error(string memory reason) {
            console.log("Error: Deposit failed with reason: %s", reason);
        } catch (bytes memory) {
            console.log("Error: Deposit failed with low-level error");
        }

        console.log("--- AFTER-Trigger State ---");
        console.log("Current block.timestamp: %s", block.timestamp);
        console.log("User ETH balance: %s", address(user).balance);
        console.log("Bank contract ETH balance: %s", address(bank).balance);

        // Final vulnerability verdict logic
        if (depositSuccess && block.timestamp == newTimestamp) {
            console.log("Vulnerability Exists: Successfully deposited under manipulated timestamp");
        } else if (!depositSuccess) {
            console.log("Vulnerability not Exist: Deposit reverted under manipulated timestamp");
        } else {
            console.log("Vulnerability not Exist: Deposit succeeded but timestamp manipulation failed");
        }

        vm.stopPrank();
    }
}