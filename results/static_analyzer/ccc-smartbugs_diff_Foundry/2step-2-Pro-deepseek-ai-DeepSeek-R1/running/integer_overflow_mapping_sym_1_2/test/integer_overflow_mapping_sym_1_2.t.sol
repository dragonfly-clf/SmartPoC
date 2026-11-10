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
    
    function test_IntegerUnderflowVulnerability() public {
        uint256 testKey = 1;
        uint256 testValue = 1;

        console.log("--- BEFORE-Trigger getMapValue ---");
        uint256 beforeValue = testContract.getMapValue(testKey);
        console.log("Value for key %s before trigger: %s", testKey, beforeValue);

        console.log("--- Trigger init ---");
        testContract.init(testKey, testValue);

        console.log("--- AFTER-Trigger getMapValue ---");
        uint256 afterValue = testContract.getMapValue(testKey);
        uint256 expectedValue = type(uint256).max;
        console.log("Value for key %s after trigger: %s", testKey, afterValue);

        bool vulnerable = (beforeValue == 0 && afterValue == expectedValue);
        if (vulnerable) {
            console.log("Vulnerability confirmed: Integer underflow occurred");
            console.log("Vulnerability Exists: Integer underflow from 0 to max value");
        } else {
            console.log("State unchanged or invalid overflow detected");
            console.log("Vulnerability not Exist: No integer underflow occurred");
        }

        assertEq(afterValue, expectedValue, "Integer underflow vulnerability");
    }
}