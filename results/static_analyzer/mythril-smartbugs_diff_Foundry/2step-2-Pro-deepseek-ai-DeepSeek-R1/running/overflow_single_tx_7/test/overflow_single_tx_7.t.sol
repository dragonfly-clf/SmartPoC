// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowUnderflowTest is Test {
    IntegerOverflowSingleTransaction target;

    function setUp() public {
        target = new IntegerOverflowSingleTransaction();
    }

    function test_underflowlocalonly_Underflow() public {
        console2.log("--- BEFORE-Trigger ---");
        console2.log("State: No state change expected. Function call in progress.");

        console2.log("--- Trigger Call ---");
        bool success;
        try target.underflowlocalonly(1) {
            success = true;
        } catch (bytes memory) {
            success = false;
        }
        
        console2.log("--- AFTER-Trigger ---");
        
        if (success) {
            console2.log("Vulnerability Exists: Local underflow occurred without revert, indicating unsafe arithmetic");
        } else {
            console2.log("Vulnerability not Exist: The function reverted when underflow occurred, which is safe");
        }
    }
}