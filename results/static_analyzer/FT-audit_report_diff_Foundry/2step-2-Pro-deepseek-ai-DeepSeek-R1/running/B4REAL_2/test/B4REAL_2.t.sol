// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/B4REAL.sol";

contract B4REALAccessControlTest is Test {
    B4REAL public token;
    address public deployer;
    address public attacker;

    // Properly computed role hashes
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function setUp() public {
        deployer = address(0x1);
        attacker = address(0xBAD);

        // Deploy token as deployer
        vm.startPrank(deployer);
        token = new B4REAL();
        vm.stopPrank();
    }

    function test_AttackerCannotGrantAdminRole() public {
        // BEFORE: Capture initial admin role status
        console.log("--- BEFORE-Trigger (grant admin) ---");
        bool hasAdminBefore = token.hasRole(ADMIN_ROLE, attacker);
        console.log("Attacker has ADMIN_ROLE? (before):", hasAdminBefore);

        assertFalse(
            token.hasRole(ADMIN_ROLE, attacker),
            "Attacker should not have admin role initially"
        );

        // TRIGGER: Attacker attempts to grant admin role
        console.log("--- Trigger GrantAdminRole ---");
        vm.startPrank(attacker);
        vm.expectRevert();
        token.grantRole(ADMIN_ROLE, attacker);
        vm.stopPrank();

        // AFTER: Verify admin role status unchanged
        console.log("--- AFTER-Trigger (grant admin) ---");
        bool hasAdminAfter = token.hasRole(ADMIN_ROLE, attacker);
        console.log("Attacker has ADMIN_ROLE? (after):", hasAdminAfter);

        // VERDICT: Determine if state changed
        if (hasAdminBefore == hasAdminAfter) {
            console.log("Vulnerability not Exist: Admin role state unchanged - access control intact");
        } else {
            console.log("Vulnerability Exists: Attacker successfully granted admin role");
        }

        assertFalse(
            token.hasRole(ADMIN_ROLE, attacker),
            "Attacker should not have admin role"
        );
    }

    function test_AttackerCannotRenounceOthersRoles() public {
        // BEFORE: Capture initial owner role status
        console.log("--- BEFORE-Trigger (renounce owner) ---");
        bool hasOwnerBefore = token.hasRole(OWNER_ROLE, deployer);
        console.log("Deployer has OWNER_ROLE? (before):", hasOwnerBefore);

        assertTrue(
            token.hasRole(OWNER_ROLE, deployer),
            "Deployer should have owner role initially"
        );

        // TRIGGER: Attacker attempts to renounce deployer's role
        console.log("--- Trigger RenounceOwnerRole ---");
        vm.startPrank(attacker);
        vm.expectRevert("AccessControl: can only renounce roles for self");
        token.renounceRole(OWNER_ROLE, deployer);
        vm.stopPrank();

        // AFTER: Verify owner role status unchanged
        console.log("--- AFTER-Trigger (renounce owner) ---");
        bool hasOwnerAfter = token.hasRole(OWNER_ROLE, deployer);
        console.log("Deployer has OWNER_ROLE? (after):", hasOwnerAfter);

        // VERDICT: Determine if state changed
        if (hasOwnerBefore == hasOwnerAfter) {
            console.log("Vulnerability not Exist: Owner role state unchanged - access control intact");
        } else {
            console.log("Vulnerability Exists: Attacker successfully renounced deployer's owner role");
        }

        assertTrue(
            token.hasRole(OWNER_ROLE, deployer),
            "Deployer should still have owner role"
        );
    }
}