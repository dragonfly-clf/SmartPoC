// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KOFATOKEN.sol";

contract SafeMathHelper {
    function tryAdd(uint256 a, uint256 b) public pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
}

contract KOFAOverflowTest is Test {
    SafeMathHelper mathHelper;

    function setUp() public {
        mathHelper = new SafeMathHelper();
    }

    function test_TryAddOverflow() public {
        uint256 max = type(uint256).max;
        bool hasVulnerability = false;
        
        console.log("=============== Overflow Test Case ===============");
        
        // Test 1: Overflow case (max + 1)
        console.log("--- BEFORE-Trigger tryAdd (Overflow Case) ---");
        console.log("Input : a = %s, b = 1", max);
        
        console.log("--- Trigger tryAdd (Overflow) ---");
        (bool success, uint256 result) = mathHelper.tryAdd(max, 1);
        
        console.log("--- AFTER-Trigger tryAdd (Overflow) ---");
        console.log("Output: success = %s, result = %s", success, result);
        
        if (success == false && result == 0) {
            console.log("Result: Correct overflow detection");
        } else {
            console.log("Result: Overflow NOT detected");
            hasVulnerability = true;
        }
        
        console.log("\n=============== Non-Overflow Test Case ===============");
        
        // Test 2: Non-overflow case (max - 1 + 1)
        console.log("--- BEFORE-Trigger tryAdd (Non-Overflow Case) ---");
        console.log("Input : a = %s, b = 1", max-1);
        
        console.log("--- Trigger tryAdd (Non-Overflow) ---");
        (success, result) = mathHelper.tryAdd(max - 1, 1);
        
        console.log("--- AFTER-Trigger tryAdd (Non-Overflow) ---");
        console.log("Output: success = %s, result = %s", success, result);
        
        if (success == true && result == max) {
            console.log("Result: Correct non-overflow operation");
        } else {
            console.log("Result: Non-overflow operation failed");
            hasVulnerability = true;
        }
        
        // Final vulnerability verdict
        if (hasVulnerability) {
            console.log("\nVulnerability Exists: Invalid overflow handling in arithmetic operation");
        } else {
            console.log("\nVulnerability not Exist: Arithmetic overflow correctly handled");
        }
    }
}