// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowSingleTransaction public demo;

    function setUp() public {
        demo = new IntegerOverflowSingleTransaction();
    }

    function testOverflowMulLocalOnly() public {
        // Set up state required for overflow attack
        demo.overflowaddtostate(1);
        demo.overflowmultostate(2**128);

        console.log("--- BEFORE-Trigger Operation ---");
        console.log("No state snapshot required (differential verification not applicable)");

        console.log("--- Trigger Operation: overflowmulocalonly(2**128 + 1) ---");
        bool success;
        try demo.overflowmulocalonly(2**128 + 1) {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger Operation ---");
        console.log("Operation outcome: %s", success ? "SUCCESS (no revert)" : "REVERT");

        // Final vulnerability verdict
        if (success) {
            console.log("Vulnerability Exists: Transaction succeeded without revert (unchecked integer overflow)");
        } else {
            console.log("Vulnerability not Exist: Transaction reverted as expected");
        }
    }
}