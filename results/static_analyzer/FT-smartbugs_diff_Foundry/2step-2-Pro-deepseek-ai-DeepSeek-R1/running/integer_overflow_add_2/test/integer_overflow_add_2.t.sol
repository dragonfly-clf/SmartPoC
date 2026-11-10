// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import "../src/integer_overflow_add.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd public counter;
    
    function setUp() public {
        counter = new IntegerOverflowAdd();
    }

    function test_integerOverflowVulnerability() public {
        // Set initial state to max possible value by manipulating storage
        uint256 countSlot = 0; // count variable is stored at slot 0
        vm.store(
            address(counter),
            bytes32(countSlot),
            bytes32(type(uint256).max - 1)
        );

        console2.log("--- BEFORE-Trigger count ---");
        uint256 countBefore = counter.count();
        console2.log("Count before run(2):", countBefore);
        require(countBefore == type(uint256).max - 1, "Initial condition not set");

        console2.log("--- Trigger run(2) ---");
        counter.run(2);

        console2.log("--- AFTER-Trigger count ---");
        uint256 countAfter = counter.count();
        console2.log("Count after run(2):", countAfter);

        if (countAfter == 0) {
            console2.log("State Change: Vulnerability exploited (wrapped to 0)");
            console2.log("Vulnerability Exists: Integer overflow successfully triggered when adding to near-max value");
        } else {
            console2.log("State Change: Vulnerability not exploited (expected 0, actual %s)", countAfter);
            console2.log("Vulnerability not Exist: Integer overflow did not occur as expected");
        }
    }
}