// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mul.sol";

contract IntegerOverflowMulTest is Test {
    IntegerOverflowMul public targetContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        targetContract = new IntegerOverflowMul();
    }

    // Test that non-owner cannot reset count
    function test_NonOwnerCannotReset() public {
        // Before - verify initial state
        console.log("--- BEFORE-Trigger resetCount ---");
        uint256 beforeCount = targetContract.count();
        console.log("Count before reset attempt:", beforeCount);

        console.log("--- Trigger resetCount by non-owner ---");
        // Non-owner resetCount call - should revert
        vm.prank(attacker);
        vm.expectRevert("Only owner can reset");
        targetContract.resetCount();

        // After - verify state unchanged
        console.log("--- AFTER-Trigger resetCount ---");
        uint256 afterCount = targetContract.count();
        console.log("Count after reset attempt:", afterCount);
        
        // Verification and final verdict
        if (beforeCount == afterCount) {
            console.log("Vulnerability not Exist: Non-owner could not reset count as expected");
        } else {
            console.log("Vulnerability Exists: Non-owner successfully reset count");
        }
    }

    // Test that owner can reset count (normal operation)
    function test_OwnerCanReset() public {
        // Before - verify initial state
        console.log("--- BEFORE-Trigger resetCount ---");
        uint256 beforeCount = targetContract.count();
        console.log("Count before reset:", beforeCount);

        console.log("--- Trigger resetCount by owner ---");
        // Owner resetCount call - should succeed
        vm.prank(owner);
        targetContract.resetCount();

        // After - verify state changed to 2
        console.log("--- AFTER-Trigger resetCount ---");
        uint256 afterCount = targetContract.count();
        console.log("Count after reset:", afterCount);
        
        // Verification and final verdict
        if (afterCount == 2) {
            console.log("Vulnerability not Exist: Owner successfully reset count to 2 as required");
        } else {
            console.log("Vulnerability Exists: Reset count failed or set to wrong value");
        }
    }

    // Test that compromised owner key still has access
    function test_CompromisedOwnerCanReset() public {
        // Before - verify initial state
        console.log("--- BEFORE-Trigger resetCount ---");
        uint256 beforeCount = targetContract.count();
        console.log("Count before reset:", beforeCount);

        console.log("--- Trigger resetCount by compromised owner ---");
        // Compromised owner call - should work same as owner
        address compromisedOwner = owner;
        vm.prank(compromisedOwner);
        targetContract.resetCount();

        // After - verify state changed to 2
        console.log("--- AFTER-Trigger resetCount ---");
        uint256 afterCount = targetContract.count();
        console.log("Count after reset:", afterCount);
        
        // Verification and final verdict
        if (afterCount == 2) {
            console.log("Vulnerability not Exist: Compromised owner successfully reset count as expected");
        } else {
            console.log("Vulnerability Exists: Reset count failed after key compromise");
        }
    }
}