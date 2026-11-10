// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract CallRecorder {
    uint256 public callCount;

    fallback() external {
        callCount++;
    }
}

contract EtherGetTest is Test {
    EtherGet public etherGet;
    CallRecorder public callRecorder;

    function setUp() public {
        etherGet = new EtherGet();
        callRecorder = new CallRecorder();
    }

    // Test verifies arbitrary calls via getTokens()
    function test_ArbitraryCalls() public {
        uint256 numCalls = 3;
        
        console.log("--- BEFORE-Trigger ---");
        uint256 beforeCallCount = callRecorder.callCount();
        console.log("Initial call count: ", beforeCallCount);
        
        console.log("--- Trigger getTokens ---");
        etherGet.getTokens(numCalls, address(callRecorder));
        
        console.log("--- AFTER-Trigger ---");
        uint256 afterCallCount = callRecorder.callCount();
        console.log("Final call count: ", afterCallCount);
        
        uint256 actualCallCountIncrease = afterCallCount - beforeCallCount;
        console.log("Expected calls: %d | Actual calls: %d", numCalls, actualCallCountIncrease);
        
        // Vulnerability verdict logic
        if(actualCallCountIncrease == numCalls) {
            console.log("Vulnerability Exists: Unauthorized arbitrary calls executed successfully");
        } else {
            console.log("Vulnerability not Exist: Call count increase did not match expected value");
        }
        
        // Original test assertion (retained)
        assertEq(callRecorder.callCount(), numCalls);
    }
}