// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract SpyLogFile {
    uint256 public lastTime;
    
    function AddMessage(address, uint, string memory) public {
        lastTime = block.timestamp;
    }
}

contract AddMessageTimestampTest is Test {
    DEP_BANK public bank;
    SpyLogFile public spy;

    function setUp() public {
        spy = new SpyLogFile();
        bank = new DEP_BANK();
        bank.SetLogFile(address(spy));
    }

    function test_AddMessageUsesCurrentTimestamp() public {
        uint256 testTimestamp = 1700000000;
        vm.warp(testTimestamp);

        console2.log("--- BEFORE-Trigger Deposit ---");
        uint256 lastTimeBefore = spy.lastTime();
        console2.log("SpyLogFile.lastTime before deposit:", lastTimeBefore);

        console2.log("--- Trigger Deposit ---");
        // Deposit to trigger LogFile.AddMessage
        vm.deal(address(this), 1 ether);
        bank.Deposit{value: 1 ether}();

        console2.log("--- AFTER-Trigger Deposit ---");
        uint256 lastTimeAfter = spy.lastTime();
        console2.log("SpyLogFile.lastTime after deposit:", lastTimeAfter);

        // Check vulnerability conditions
        bool timestampChanged = (lastTimeAfter != lastTimeBefore);
        bool timestampMatchesExpected = (lastTimeAfter == testTimestamp);
        bool vulnerabilityExists = timestampChanged && timestampMatchesExpected;

        console2.log("State changed?", timestampChanged ? "YES" : "NO");
        console2.log("Timestamp set correctly?", timestampMatchesExpected ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: AddMessage uses block.timestamp which can be manipulated via vm.warp");
        } else {
            console2.log("Vulnerability not Exist: Block.timestamp was not changed as expected");
        }
    }
}