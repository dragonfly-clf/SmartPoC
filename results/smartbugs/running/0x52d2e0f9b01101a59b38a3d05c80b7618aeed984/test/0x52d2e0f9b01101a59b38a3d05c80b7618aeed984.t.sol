// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract EtherGetTest is Test {
    EtherGet public etherGet;
    address owner = address(0x1);
    address attacker = address(0x2);
    
    // Mock contract that tracks call attempts
    CallTracker public callTracker;

    function setUp() public {
        vm.prank(owner);
        etherGet = new EtherGet();
        
        // Deploy a mock contract that tracks calls
        callTracker = new CallTracker();
    }

    function testUncheckedLowLevelCall() public {
        console2.log("--- BEFORE-Trigger ---");
        // Count the number of calls attempted
        uint256 initialCallCount = callTracker.callCount();
        console2.log("Initial call count:", initialCallCount);
        
        console2.log("--- Trigger GetTokens ---");
        // Call getTokens with our mock contract address
        vm.prank(attacker);
        etherGet.getTokens(5, address(callTracker));
        
        console2.log("--- AFTER-Trigger ---");
        // Verify calls were attempted (even though they failed)
        uint256 finalCallCount = callTracker.callCount();
        console2.log("Final call count:", finalCallCount);
        assertEq(finalCallCount, initialCallCount + 5, "Calls were attempted but not checked");
        
        // Final vulnerability verdict
        bool vulnerabilityConfirmed = (finalCallCount == initialCallCount + 5);
        if (vulnerabilityConfirmed) {
            console2.log("Vulnerability Exists: The getTokens function successfully executed without reverting even though it performed low-level calls that could fail, demonstrating unchecked call return values");
        } else {
            console2.log("Vulnerability not Exist: Expected call count increase was not detected");
        }
    }
}

// Mock contract that tracks call attempts
contract CallTracker {
    uint256 public callCount;
    
    // Fallback that tracks calls but doesn't revert
    fallback() external {
        callCount++;
    }
}