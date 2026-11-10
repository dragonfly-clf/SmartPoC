// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Caramel.sol";

contract CaramelPrivilegeEscalationTest is Test {
    Caramel token;
    address admin = address(0x5555);
    address attacker = address(0x3333);
    address victim = address(0x4444);
    
    uint256 constant INITIAL_SUPPLY = 50000 ether;
    uint256 constant LARGE_AMOUNT = 40000 ether;
    
    function setUp() public {
        vm.startPrank(admin);
        token = new Caramel();
        vm.stopPrank();
    }

    function testTransferBurnsTokens() public {
        // Mint tokens to attacker
        vm.prank(admin);
        token.mint(attacker, LARGE_AMOUNT);

        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 victimBalanceBefore = token.balanceOf(victim);
        console.log("Total Supply Before:  ", totalSupplyBefore);
        console.log("Attacker Balance Before:", attackerBalanceBefore);
        console.log("Victim Balance Before:  ", victimBalanceBefore);

        // Calculate expected values
        uint256 expectedBurn = (LARGE_AMOUNT * 2) / 100;
        uint256 expectedTransfer = LARGE_AMOUNT - expectedBurn;

        console.log("--- Trigger Transfer ---");
        vm.prank(attacker);
        token.transfer(victim, LARGE_AMOUNT);

        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 victimBalanceAfter = token.balanceOf(victim);
        console.log("Total Supply After:   ", totalSupplyAfter);
        console.log("Attacker Balance After: ", attackerBalanceAfter);
        console.log("Victim Balance After:   ", victimBalanceAfter);

        console.log("--- Differential Validation ---");
        // Calculate state changes
        uint256 actualBurn = totalSupplyBefore - totalSupplyAfter;
        uint256 victimIncrease = victimBalanceAfter - victimBalanceBefore;
        uint256 attackDecrease = attackerBalanceBefore - attackerBalanceAfter;

        // Log validation results directly without intermediate variables
        console.log("Burn Validation:       %s (Expected: %s, Actual: %s)", 
            (actualBurn == expectedBurn) ? "PASS" : "FAIL", expectedBurn, actualBurn);
        console.log("Victim Validation:     %s (Expected: %s, Actual: %s)", 
            (victimIncrease == expectedTransfer) ? "PASS" : "FAIL", expectedTransfer, victimIncrease);
        console.log("Attacker Validation:   %s (Expected: %s, Actual: %s)", 
            (attackDecrease == LARGE_AMOUNT) ? "PASS" : "FAIL", LARGE_AMOUNT, attackDecrease);

        // Final verdict
        if (actualBurn == expectedBurn && victimIncrease == expectedTransfer && attackDecrease == LARGE_AMOUNT) {
            console.log("Vulnerability not Exist: Token transfer burn mechanism functions as expected");
        } else {
            console.log("Vulnerability Exists: Unexpected token burning behavior detected in transfer");
        }
    }

    function testTransferFromBurnsTokens() public {
        // Mint tokens to attacker
        vm.prank(admin);
        token.mint(attacker, LARGE_AMOUNT);
        
        // Set approvals
        vm.prank(attacker);
        token.approve(victim, LARGE_AMOUNT);
        
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 victimBalanceBefore = token.balanceOf(victim);
        console.log("Total Supply Before:  ", totalSupplyBefore);
        console.log("Attacker Balance Before:", attackerBalanceBefore);
        console.log("Victim Balance Before:  ", victimBalanceBefore);

        // Calculate expected values
        uint256 expectedBurn = (LARGE_AMOUNT * 2) / 100;
        uint256 expectedTransfer = LARGE_AMOUNT - expectedBurn;

        console.log("--- Trigger TransferFrom ---");
        vm.prank(victim);
        token.transferFrom(attacker, victim, LARGE_AMOUNT);

        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 victimBalanceAfter = token.balanceOf(victim);
        console.log("Total Supply After:   ", totalSupplyAfter);
        console.log("Attacker Balance After: ", attackerBalanceAfter);
        console.log("Victim Balance After:   ", victimBalanceAfter);

        console.log("--- Differential Validation ---");
        // Calculate state changes
        uint256 actualBurn = totalSupplyBefore - totalSupplyAfter;
        uint256 victimIncrease = victimBalanceAfter - victimBalanceBefore;
        uint256 attackDecrease = attackerBalanceBefore - attackerBalanceAfter;

        // Log validation results directly
        console.log("Burn Validation:       %s (Expected: %s, Actual: %s)", 
            (actualBurn == expectedBurn) ? "PASS" : "FAIL", expectedBurn, actualBurn);
        console.log("Victim Validation:     %s (Expected: %s, Actual: %s)", 
            (victimIncrease == expectedTransfer) ? "PASS" : "FAIL", expectedTransfer, victimIncrease);
        console.log("Attacker Validation:   %s (Expected: %s, Actual: %s)", 
            (attackDecrease == LARGE_AMOUNT) ? "PASS" : "FAIL", LARGE_AMOUNT, attackDecrease);

        // Final verdict
        if (actualBurn == expectedBurn && victimIncrease == expectedTransfer && attackDecrease == LARGE_AMOUNT) {
            console.log("Vulnerability not Exist: Token transferFrom burn mechanism functions properly");
        } else {
            console.log("Vulnerability Exists: Abnormal token burning detected in transferFrom");
        }
    }

    function testBurningWithFractionalAmount() public {
        uint256 smallAmount = 99; // Will cause fractional burn
        vm.prank(admin);
        token.mint(attacker, smallAmount);

        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger FractionalTransfer ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 victimBalanceBefore = token.balanceOf(victim);
        console.log("Total Supply Before:  ", totalSupplyBefore);
        console.log("Attacker Balance Before:", attackerBalanceBefore);
        console.log("Victim Balance Before:  ", victimBalanceBefore);

        // Calculate expected values
        uint256 expectedBurn = (smallAmount * 2) / 100; // Will be 1 due to integer division
        uint256 expectedTransfer = smallAmount - expectedBurn;

        console.log("--- Trigger FractionalTransfer ---");
        vm.prank(attacker);
        token.transfer(victim, smallAmount);

        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger FractionalTransfer ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 victimBalanceAfter = token.balanceOf(victim);
        console.log("Total Supply After:   ", totalSupplyAfter);
        console.log("Attacker Balance After: ", attackerBalanceAfter);
        console.log("Victim Balance After:   ", victimBalanceAfter);

        console.log("--- Differential Validation ---");
        // Calculate state changes
        uint256 actualBurn = totalSupplyBefore - totalSupplyAfter;
        uint256 victimIncrease = victimBalanceAfter - victimBalanceBefore;
        uint256 attackDecrease = attackerBalanceBefore - attackerBalanceAfter;
        
        // Log validation without intermediate status variables
        console.log("Burn Validation:       %s (Expected: %s, Actual: %s)", 
            (actualBurn == expectedBurn) ? "PASS" : "FAIL", expectedBurn, actualBurn);
        console.log("Victim Validation:     %s (Expected: %s, Actual: %s)", 
            (victimIncrease == expectedTransfer) ? "PASS" : "FAIL", expectedTransfer, victimIncrease);
        console.log("Attacker Validation:   %s (Expected: %s, Actual: %s)", 
            (attackDecrease == smallAmount) ? "PASS" : "FAIL", smallAmount, attackDecrease);

        // Final verdict
        if (actualBurn == expectedBurn && victimIncrease == expectedTransfer && attackDecrease == smallAmount) {
            console.log("Vulnerability not Exist: Fractional token burning functions correctly");
        } else {
            console.log("Vulnerability Exists: Unexpected fractional token burning behavior");
        }
    }
}