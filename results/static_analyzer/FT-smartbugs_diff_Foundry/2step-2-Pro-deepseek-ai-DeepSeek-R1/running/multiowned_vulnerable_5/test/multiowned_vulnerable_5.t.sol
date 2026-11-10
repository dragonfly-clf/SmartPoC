// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/multiowned_vulnerable.sol";

contract Audit_Test is Test {
    TestContract public multiOwnable;
    address public owner;
    address public alice;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        vm.prank(owner);
        multiOwnable = new TestContract();
    }

    function test_RootCanDeleteThemselves() public {
        // Add a secondary owner
        vm.prank(owner);
        multiOwnable.newOwner(alice);
        
        console.log("--- BEFORE-Trigger ---");
        uint256 ownerStateBefore = multiOwnable.owners(owner);
        console.log("Owner status before deletion (non-zero is valid):", ownerStateBefore);
        
        console.log("");
        console.log("--- Trigger: deleteOwner(owner) ---");
        vm.prank(owner);
        multiOwnable.deleteOwner(owner);
        
        console.log("");
        console.log("--- AFTER-Trigger ---");
        uint256 ownerStateAfter = multiOwnable.owners(owner);
        console.log("Owner status after deletion (non-zero is valid):", ownerStateAfter);
        
        console.log("");
        console.log("--- Additional Check: Attempt owner action ---");
        bool actionReverted = false;
        vm.prank(owner);
        try multiOwnable.deleteOwner(alice) {
            // Call did not revert - this is undesirable in exploit scenario
            actionReverted = false;
        } catch {
            // Call reverted - owner lost privileges
            actionReverted = true;
        }
        
        console.log("Action to delete Alice reverted? %s", actionReverted ? "Yes" : "No");
        
        // Vulnerability exists if: owner was removed (state=0) and lost privileges (revert occurred)
        bool vulnerabilityExists = (ownerStateAfter == 0) && actionReverted;
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Root owner successfully deleted themselves and lost privileges");
        } else {
            console.log("Vulnerability not Exist: Either deletion failed or owner retained privileges");
        }
    }
}