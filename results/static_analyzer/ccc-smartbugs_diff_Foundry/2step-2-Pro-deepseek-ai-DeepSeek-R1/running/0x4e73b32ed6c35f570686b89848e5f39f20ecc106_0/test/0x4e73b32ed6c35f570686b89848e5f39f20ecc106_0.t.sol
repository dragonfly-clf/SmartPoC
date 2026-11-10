// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract TimestampManipulationTest is Test {
    PRIVATE_ETH_CELL public cell;
    
    // Mock LogFile contract to track messages
    MockLogFile public mockLog;
    
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    uint256 constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        // Deploy mock log and target contract
        mockLog = new MockLogFile();
        cell = new PRIVATE_ETH_CELL();
        
        // Connect mock log to ETH cell
        cell.SetLogFile(address(mockLog));
        
        // Fund users
        vm.deal(user1, DEPOSIT_AMOUNT);
        vm.deal(user2, DEPOSIT_AMOUNT);
    }

    function test_timestampManipulation() public {
        // Deposit at timestamp 1000
        vm.warp(1000);
        vm.prank(user1);
        cell.Deposit{value: DEPOSIT_AMOUNT}();
        
        // Get last log entry
        MockLogFile.LogMessage[] memory logs = mockLog.getAllMessages();
        assertEq(logs.length, 1, "Should have 1 log entry");
        assertEq(logs[0].Time, 1000, "First timestamp should be 1000");
        assertEq(logs[0].Data, "Put", "Log data should be 'Put'");

        // Deposit at manipulated timestamp (900s into future)
        vm.warp(1900);
        vm.prank(user2);
        cell.Deposit{value: DEPOSIT_AMOUNT}();
        
        // Get updated logs
        logs = mockLog.getAllMessages();
        assertEq(logs.length, 2, "Should have 2 log entries");
        assertEq(logs[1].Time, 1900, "Second timestamp should be 1900");
        assertEq(logs[1].Data, "Put", "Log data should be 'Put'");

        // Final vulnerability verdict
        console.log("Vulnerability Exists: Contract recorded manipulated block.timestamp value (1900)");
    }
}

contract MockLogFile {
    struct LogMessage {
        address Sender;
        uint256 Time;
        uint256 Val;
        string Data;
    }
    
    LogMessage[] private history;
    LogMessage public lastMsg;
    
    function AddMessage(address _adr, uint _val, string memory _data) public {
        lastMsg.Sender = _adr;
        lastMsg.Time = block.timestamp;
        lastMsg.Val = _val;
        lastMsg.Data = _data;
        history.push(lastMsg);
    }
    
    function getAllMessages() public view returns (LogMessage[] memory) {
        return history;
    }
}