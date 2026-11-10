// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowAccessControlTest is Test {
    IntegerOverflowSingleTransaction public target;
    address public deployer = makeAddr("deployer");
    address public newOwner = makeAddr("newOwner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        target = new IntegerOverflowSingleTransaction();
    }

    function test_NonOwnerCannotResetCounter() public {
        console.log("--- BEFORE-Trigger resetCounter ---");
        // Record current state
        address currentOwnerBefore = target.owner();
        uint currentCountBefore = target.count();
        console.log("Owner before:", currentOwnerBefore);
        console.log("Count before:", currentCountBefore);

        console.log("--- Trigger resetCounter (as attacker) ---");
        // Attempt the reset
        vm.prank(attacker);
        vm.expectRevert("Only owner can reset counter");
        target.resetCounter();

        console.log("--- AFTER-Trigger resetCounter ---");
        // Record state after
        address currentOwnerAfter = target.owner();
        uint currentCountAfter = target.count();
        console.log("Owner after:", currentOwnerAfter);
        console.log("Count after:", currentCountAfter);

        // Verify state unchanged
        bool stateUnchanged = (currentOwnerAfter == currentOwnerBefore) && (currentCountAfter == currentCountBefore);
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: State unchanged after unauthorized resetCounter");
        } else {
            console.log("Vulnerability Exists: Unauthorized resetCounter changed state");
        }
    }
    
    function test_NonOwnerCannotTransferOwnership() public {
        console.log("--- BEFORE-Trigger transferOwnership ---");
        // Record current state
        address currentOwnerBefore = target.owner();
        uint currentCountBefore = target.count();
        console.log("Owner before:", currentOwnerBefore);
        console.log("Count before:", currentCountBefore);

        console.log("--- Trigger transferOwnership (as attacker) ---");
        // Attempt ownership transfer
        vm.prank(attacker);
        vm.expectRevert("Only owner can transfer ownership");
        target.transferOwnership(attacker);

        console.log("--- AFTER-Trigger transferOwnership ---");
        // Record state after
        address currentOwnerAfter = target.owner();
        uint currentCountAfter = target.count();
        console.log("Owner after:", currentOwnerAfter);
        console.log("Count after:", currentCountAfter);

        // Verify state unchanged
        bool stateUnchanged = (currentOwnerAfter == currentOwnerBefore) && (currentCountAfter == currentCountBefore);
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: State unchanged after unauthorized transferOwnership");
        } else {
            console.log("Vulnerability Exists: Unauthorized transferOwnership changed state");
        }
    }
    
    function test_OwnerCanTransferOwnership() public {
        bool vulnerabilityDetected = false;
        
        console.log("====== Phase 1: Ownership transfer ======");
        // Sub-phase 1: Verify initial state
        console.log("[1] --- BEFORE transferOwnership ---");
        address ownerBefore = target.owner();
        uint countBefore = target.count();
        console.log("Initial owner:", ownerBefore);
        console.log("Initial count:", countBefore);

        console.log("[1] --- Trigger transferOwnership ---");
        // Transfer ownership
        vm.prank(deployer);
        target.transferOwnership(newOwner);

        console.log("[1] --- AFTER transferOwnership ---");
        address ownerAfterTransfer = target.owner();
        uint countAfterTransfer = target.count();
        console.log("Owner after transfer:", ownerAfterTransfer);
        console.log("Count after transfer:", countAfterTransfer);

        if (ownerAfterTransfer != newOwner || countAfterTransfer != countBefore) {
            console.log("[1] Vulnerability: Unexpected state changes in transferOwnership");
            vulnerabilityDetected = true;
        }

        console.log("====== Phase 2: Reset by new owner ======");
        console.log("[2] --- BEFORE resetCounter ---");
        uint countBeforeReset = target.count();
        console.log("Count before reset:", countBeforeReset);

        console.log("[2] --- Trigger resetCounter ---");
        // New owner resets counter
        vm.prank(newOwner);
        target.resetCounter();

        console.log("[2] --- AFTER resetCounter ---");
        uint countAfterReset = target.count();
        console.log("Count after reset:", countAfterReset);

        if (countAfterReset != 0) {
            console.log("[2] Vulnerability: Counter not reset to 0");
            vulnerabilityDetected = true;
        }

        console.log("====== Phase 3: Old owner privilege check ======");
        console.log("[3] --- BEFORE old owner reset ---");
        uint countBeforeOldOwnerReset = target.count();
        console.log("Count before:", countBeforeOldOwnerReset);

        console.log("[3] --- Trigger resetCounter (as old owner) ---");
        // Original owner tries to reset
        vm.prank(deployer);
        vm.expectRevert("Only owner can reset counter");
        target.resetCounter();

        console.log("[3] --- AFTER old owner reset ---");
        uint countAfterOldOwnerReset = target.count();
        console.log("Count after:", countAfterOldOwnerReset);

        if (countAfterOldOwnerReset != countBeforeOldOwnerReset) {
            console.log("[3] Vulnerability: Count changed after unauthorized reset");
            vulnerabilityDetected = true;
        }

        // Final verdict
        if (vulnerabilityDetected) {
            console.log("Vulnerability Exists: Unauthorized access and/or state changes detected");
        } else {
            console.log("Vulnerability not Exist: All access controls enforced correctly");
        }
    }
}