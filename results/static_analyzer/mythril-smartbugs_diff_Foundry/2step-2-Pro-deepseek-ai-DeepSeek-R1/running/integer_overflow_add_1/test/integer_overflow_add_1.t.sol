// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_add.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd public integerOverflowAdd;

    function setUp() public {
        integerOverflowAdd = new IntegerOverflowAdd();
    }

    function testRunOverflow() public {
        // First operation: make initial state change
        integerOverflowAdd.run(type(uint256).max);
        
        console.log("--- BEFORE-Trigger Overflow ---");
        uint256 countBefore = integerOverflowAdd.count();
        console.log("Count state before overflow operation:", countBefore);

        console.log("--- Trigger Overflow Operation (run(1)) ---");
        // Second operation: attempt to overflow count
        integerOverflowAdd.run(1);
        
        console.log("--- AFTER-Trigger Overflow ---");
        uint256 countAfter = integerOverflowAdd.count();
        console.log("Count state after overflow operation:", countAfter);
        
        // Check for overflow condition: count wrapped to 0 (only possible if started from max)
        bool overflowOccurred = (countAfter == 0 && countBefore == type(uint256).max);
        console.log("Overflow occurred (from max to 0):", overflowOccurred ? "YES" : "NO");
        
        // Third operation: additional call to maintain test flow
        integerOverflowAdd.run(1);
        
        // Maintain original PoC assertion
        assertEq(integerOverflowAdd.getUserOperationCount(address(this)), 3);
        
        // Vulnerability verdict based on overflow check
        if (overflowOccurred) {
            console.log("Vulnerability Exists: Integer overflow successful");
        } else {
            console.log("Vulnerability not Exist: Integer overflow not confirmed");
        }
    }
}