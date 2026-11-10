// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract FrontRunningTest is Test {
    ERC20 token;
    address alice = address(0x1);
    address bob = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        vm.startPrank(alice);
        token = new ERC20(1000 ether);
        vm.stopPrank();
    }

    function testFrontRunningApproval() public {
        // Alice approves Bob to spend 100 tokens
        vm.prank(alice);
        token.approve(bob, 100);

        // Verify initial allowance
        assertEq(token.allowance(alice, bob), 100);
        
        // Differential validation - capture state BEFORE attack
        console.log("--- BEFORE-Trigger FrontRunningApproval ---");
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        uint256 attackerBefore = token.balanceOf(attacker);
        uint256 allowanceBefore = token.allowance(alice, bob);
        console.log("Alice balance:", aliceBefore);
        console.log("Bob balance:", bobBefore);
        console.log("Attacker balance:", attackerBefore);
        console.log("Allowance (Alice->Bob):", allowanceBefore);

        console.log("--- Trigger FrontRunningApproval ---");
        // Attacker front-runs by transferring tokens before Bob can
        vm.prank(bob);
        token.transferFrom(alice, attacker, 100);

        // Differential validation - capture state AFTER attack
        console.log("--- AFTER-Trigger FrontRunningApproval ---");
        uint256 aliceAfter = token.balanceOf(alice);
        uint256 bobAfter = token.balanceOf(bob);
        uint256 attackerAfter = token.balanceOf(attacker);
        uint256 allowanceAfter = token.allowance(alice, bob);
        console.log("Alice balance:", aliceAfter);
        console.log("Bob balance:", bobAfter);
        console.log("Attacker balance:", attackerAfter);
        console.log("Allowance (Alice->Bob):", allowanceAfter);
        
        // Check state changes
        bool attackSuccess = (attackerAfter - attackerBefore == 100) &&
                             (aliceBefore - aliceAfter == 100) &&
                             (bobAfter == bobBefore) &&
                             (allowanceAfter == 0);
        
        if (attackSuccess) {
            console.log("Vulnerability Exists: Front-run attack succeeded in stealing tokens through allowance");
        } else {
            console.log("Vulnerability not Exist: Front-run attack failed to produce expected state changes");
        }

        // Verify post-attack state
        assertEq(token.balanceOf(attacker), 100);
        assertEq(token.allowance(alice, bob), 0);

        // Bob tries to use original allowance but fails
        vm.prank(bob);
        vm.expectRevert();
        token.transferFrom(alice, bob, 100);
    }

    function testFrontRunningTransfer() public {
        // Alice sends Bob some tokens
        vm.prank(alice);
        token.transfer(bob, 100);
        
        // Differential validation - capture state BEFORE attack
        console.log("--- BEFORE-Trigger FrontRunningTransfer ---");
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        uint256 attackerBefore = token.balanceOf(attacker);
        console.log("Alice balance:", aliceBefore);
        console.log("Bob balance:", bobBefore);
        console.log("Attacker balance:", attackerBefore);

        console.log("--- Trigger FrontRunningTransfer ---");
        // Attacker front-runs with higher gas transaction
        vm.prank(alice);
        token.transfer(attacker, 100);

        // Differential validation - capture state AFTER attack
        console.log("--- AFTER-Trigger FrontRunningTransfer ---");
        uint256 aliceAfter = token.balanceOf(alice);
        uint256 bobAfter = token.balanceOf(bob);
        uint256 attackerAfter = token.balanceOf(attacker);
        console.log("Alice balance:", aliceAfter);
        console.log("Bob balance:", bobAfter);
        console.log("Attacker balance:", attackerAfter);
        
        // Check state changes
        bool attackSuccess = (attackerAfter - attackerBefore == 100) &&
                             (aliceBefore - aliceAfter == 100) &&
                             (bobAfter == bobBefore);
        
        if (attackSuccess) {
            console.log("Vulnerability Exists: Front-run transfer succeeded with higher gas transaction");
        } else {
            console.log("Vulnerability not Exist: Front-run transfer failed to produce expected state changes");
        }

        // Verify final balances
        assertEq(token.balanceOf(attacker), 100);
        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(alice), 1000 ether - 200);
    }
}