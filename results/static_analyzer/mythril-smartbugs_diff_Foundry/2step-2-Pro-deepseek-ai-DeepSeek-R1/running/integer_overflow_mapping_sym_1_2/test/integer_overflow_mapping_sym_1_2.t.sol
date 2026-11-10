// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowMappingSym1Test is Test {
    IntegerOverflowMappingSym1 public testContract;
    
    function setUp() public {
        testContract = new IntegerOverflowMappingSym1();
    }
    
    function test_ArithmeticUnderflow() public {
        uint256 key = 42;
        uint256 initialValue = 0;
        testContract.init(key, initialValue);

        console.log("--- BEFORE-Trigger State ---");
        uint256 beforeState = testContract.getMapValue(key);
        console.log("Mapping value for key %s before overflow operation:", key);
        console.log(beforeState);

        console.log("--- Trigger Underflow Operation ---");
        // Attempt to subtract 1 from 0 to cause underflow
        testContract.init(key, 1);

        console.log("--- AFTER-Trigger State ---");
        uint256 afterState = testContract.getMapValue(key);
        console.log("Mapping value for key %s after overflow operation:", key);
        console.log(afterState);

        bool vulnerabilityConfirmed = (afterState == type(uint256).max);
        if (vulnerabilityConfirmed) {
            console.log("Vulnerability Exists: Underflow triggered successfully causing value wrap-around");
        } else {
            console.log("Vulnerability not Exist: State remained unchanged after overflow operation");
        }

        assertEq(vulnerabilityConfirmed, true);
    }
}