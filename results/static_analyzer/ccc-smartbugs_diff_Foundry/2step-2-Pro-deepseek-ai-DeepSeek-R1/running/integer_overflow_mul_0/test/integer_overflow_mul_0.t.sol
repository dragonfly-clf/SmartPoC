// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mul.sol";

contract IntegerOverflowMulTest is Test {
    IntegerOverflowMul public target;

    function setUp() public {
        target = new IntegerOverflowMul();
    }

    function test_IntegerOverflowInRunFunction() public {
        // Reset to initial state (assumed to set count to 1)
        target.resetCount();
        
        // Set count to highest possible value before overflow (2^255)
        target.run(2 ** 254);

        console.log("--- BEFORE-Trigger Operation ---");
        // Query and log pre-trigger count value
        uint256 preCount = target.count();
        console.log("Pre-count (expected: 2**255 as uint):", preCount);

        console.log("--- Trigger Operation: run(2) ---");
        // Execute multiplication causing overflow
        target.run(2);

        console.log("--- AFTER-Trigger Operation ---");
        // Query and log post-trigger count value
        uint256 postCount = target.count();
        console.log("Post-count (expected: 0 due to overflow):", postCount);

        // Validate state change: multiplication overflow should reset count to 0
        if (preCount == (2 ** 255) && postCount == 0) {
            console.log("Vulnerability Exists: Multiplication overflow resets count value to 0");
        } else {
            console.log("Vulnerability not Exist: Count not reset to 0 (overflow prevented)");
        }
    }
}