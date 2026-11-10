// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CLIMBToken.sol";

contract CLIMBTokenAuditTest is Test {
    CLIMBToken token;
    address public owner;
    address alice = address(0x1);
    address bob = address(0x2);
    uint256 constant amount = 100 * (10**8); // 100 tokens accounting for 8 decimals

    function setUp() public {
        owner = address(this);
        token = new CLIMBToken();
        vm.startPrank(owner);
        token.mint(alice, amount);
        vm.stopPrank();
    }

    // Test owner can arbitrarily set approvals for any account
    function test_owner_can_set_arbitrary_approvals() public {
        uint256 maliciousApproval = amount * 2; // Exceeds balance
        
        console.log("--- BEFORE-Trigger Allowance ---");
        uint256 aliceToBobAllowance = token.allowance(alice, bob);
        console.log("Initial allowance (Alice to Bob):", aliceToBobAllowance);
        
        console.log("--- Trigger ArbitraryApprove ---");
        vm.prank(owner);
        token.approve(alice, bob, maliciousApproval); // Use 3-arg approve
        
        console.log("--- AFTER-Trigger Allowance ---");
        uint256 newAlceToBobAllowance = token.allowance(alice, bob);
        console.log("Updated allowance (Alice to Bob):", newAlceToBobAllowance);
        
        // Differential validation verdict
        if (newAlceToBobAllowance == maliciousApproval) {
            console.log("Vulnerability Exists: Owner successfully set arbitrary approval");
        } else {
            console.log("Vulnerability not Exist: Owner failed to change approval");
        }

        // Maintain original assertion
        assertEq(
            newAlceToBobAllowance,
            maliciousApproval,
            "Owner can set arbitrary approvals"
        );
    }

    // Test owner can burn tokens from any account
    function test_owner_can_burn_user_tokens() public {
        uint256 burnAmount = amount / 2;
        uint256 initialAliceBalance = token.balanceOf(alice);
        
        vm.prank(owner);
        token.burn(alice, burnAmount);
        
        assertEq(
            token.balanceOf(alice),
            initialAliceBalance - burnAmount,
            "Owner can burn user tokens"
        );
    }
}