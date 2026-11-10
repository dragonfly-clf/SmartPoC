// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract TimestampPredictabilityTest is Test {
    ACCURAL_DEPOSIT public accrualDeposit;
    MockLog public mockLog;

    function setUp() public {
        // Deploy contracts
        mockLog = new MockLog();
        accrualDeposit = new ACCURAL_DEPOSIT();
        
        // Configure log
        accrualDeposit.SetLogFile(address(mockLog));
    }

    function test_TimestampPredictable() public {
        uint depositAmount = 1 ether;
        address testUser = address(0x123);
        uint fixedTimestamp = 100_000;

        console2.log("--- BEFORE-Trigger ---");
        uint timestampBefore = mockLog.lastTime();
        console2.log("MockLog timestamp before deposit:", timestampBefore);

        // Set fixed timestamp
        vm.warp(fixedTimestamp);
        
        console2.log("--- Trigger Deposit ---");
        // Perform deposit
        vm.deal(testUser, depositAmount);
        vm.prank(testUser);
        accrualDeposit.Deposit{value: depositAmount}();

        console2.log("--- AFTER-Trigger ---");
        uint timestampAfter = mockLog.lastTime();
        console2.log("MockLog timestamp after deposit:", timestampAfter);

        // Compare the timestamp before/after and check exploit success
        if (timestampAfter == fixedTimestamp) {
            console2.log("Vulnerability Exists: The log timestamp was successfully manipulated to the predicted value");
        } else {
            console2.log("Vulnerability not Exist: The timestamp value was not manipulated as expected");
        }
    }
}

contract MockLog {
    address public lastSender;
    uint public lastTime;
    uint public lastVal;
    string public lastData;

    function AddMessage(address _adr, uint _val, string memory _data) public {
        lastTime = block.timestamp;
        lastSender = _adr;
        lastVal = _val;
        lastData = _data;
    }

    function getLastMsg() public view returns (uint timestamp, uint val, string memory data) {
        return (lastTime, lastVal, lastData);
    }
}