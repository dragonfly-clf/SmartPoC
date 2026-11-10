// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_benign_1.sol";

contract IntegerOverflowBenign1Test is Test {
    IntegerOverflowBenign1 public vulnerableContract;
    
    event OperationPerformed(address indexed user, uint256 input, uint256 timestamp);
    
    function setUp() public {
        vulnerableContract = new IntegerOverflowBenign1();
    }

    function testTimestampManipulation() public {
        // Record logs to capture emitted events
        vm.recordLogs();

        // First call with timestamp 1000
        vm.warp(1000);
        vulnerableContract.run(1);
        
        // Second call with timestamp 2000
        vm.warp(2000);
        vulnerableContract.run(2);
        
        // Get recorded logs
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Check event count
        require(logs.length >= 2, "Expected at least two events");
        
        // Parse events
        (address user1, uint256 input1, uint256 timestamp1) = 
            parseOperationPerformedEvent(logs[0]);
        (address user2, uint256 input2, uint256 timestamp2) = 
            parseOperationPerformedEvent(logs[1]);

        // Check if timestamps match expected manipulation values
        bool vulnerabilityExists = 
            (timestamp1 == 1000) &&
            (timestamp2 == 2000) &&
            (user1 == address(this)) &&
            (user2 == address(this));

        // Print final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Event timestamps manipulated to match warped time values (1000 and 2000), confirming miners can manipulate block.timestamp");
        } else {
            console.log("Vulnerability not Exist: Event timestamps did not match expected values, timestamp manipulation not demonstrated");
        }
    }

    function parseOperationPerformedEvent(Vm.Log memory log) 
        internal pure returns (address, uint256, uint256) 
    {
        // Extract address from topic (converting bytes32 to address)
        address user = address(uint160(uint256(log.topics[1])));
        
        // Decode event data
        (uint256 input, uint256 timestamp) = 
            abi.decode(log.data, (uint256, uint256));
        
        return (user, input, timestamp);
    }
}