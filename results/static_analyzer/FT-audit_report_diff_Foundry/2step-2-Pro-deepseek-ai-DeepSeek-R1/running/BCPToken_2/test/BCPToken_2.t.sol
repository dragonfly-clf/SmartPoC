// SPDX-License-Identifier: MIT
pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BCPToken.sol";

contract RoleRenunciationTest is Test {
    BCPToken token;
    address admin = address(0x1);
    address user = address(0x2);
    bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;

    function setUp() public {
        vm.startPrank(admin);
        token = new BCPToken("TestToken", "TST", 1000);
        vm.stopPrank();
    }

    // Test that a user can renounce role for themselves
    function testValidRoleRenunciation() public {
        // Grant admin role to user
        vm.prank(admin);
        token.grantRole(DEFAULT_ADMIN_ROLE, user);
        
        console.log("--- BEFORE-Trigger UserRole Status ---");
        bool hasRoleBefore = token.hasRole(DEFAULT_ADMIN_ROLE, user);
        console.log("User has role before:", hasRoleBefore);

        console.log("--- Trigger: User renounces own role ---");
        // User renounces admin role for themselves
        vm.prank(user);
        token.renounceRole(DEFAULT_ADMIN_ROLE, user);
        
        console.log("--- AFTER-Trigger UserRole Status ---");
        bool hasRoleAfter = token.hasRole(DEFAULT_ADMIN_ROLE, user);
        console.log("User has role after:", hasRoleAfter);

        // Verify status changed as expected
        assertFalse(hasRoleAfter, "User should no longer have role");
        console.log("Vulnerability not Exist: Role status changed correctly from true->false during valid renunciation");
    }

    // Test that a user cannot renounce roles for others
    function testInvalidRoleRenunciation() public {
        vm.prank(user);
        vm.expectRevert("AccessControl: can only renounce roles for self");
        token.renounceRole(DEFAULT_ADMIN_ROLE, admin);
    }
}