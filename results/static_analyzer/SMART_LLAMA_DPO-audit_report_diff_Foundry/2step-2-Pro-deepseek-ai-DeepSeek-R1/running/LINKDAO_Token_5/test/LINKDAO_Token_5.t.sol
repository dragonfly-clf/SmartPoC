// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract LINKDAO_ApproveRaceConditionTest is Test {
    LINKDAO_Token public token;
    address public owner;
    address public user;
    address public attacker;
    
    bool public vulnerabilityExists = true;
    string public vulnerabilityReason;
    
    function setUp() public {
        owner = address(this);
        user = address(0x1);
        attacker = address(0x2);
        
        // Deploy the token - owner gets all pre-mined supply
        token = new LINKDAO_Token();
        
        // Get token decimals
        uint8 decimals = token.decimals();
        uint256 tokenAmount = 1000 * (10 ** uint256(decimals));
        
        // Transfer tokens from owner to user
        token.transfer(user, tokenAmount);
    }

    function test_ApproveRaceConditionVulnerability() public {
        // Get token decimals
        uint8 decimals = token.decimals();
        uint256 tokenUnit = 10 ** uint256(decimals);
        uint256 approvalAmount = 100 * tokenUnit;
        uint256 transferAmount = 100 * tokenUnit;
        uint256 zeroAllowanceAmount = 0;
        uint256 smallTransfer = 1 * tokenUnit;

        // Initial state before any actions
        uint256 initialUserBalance = token.balanceOf(user);
        uint256 initialAttackerBalance = token.balanceOf(attacker);
        console.log("### Initial State ###");
        console.log("User balance:", initialUserBalance);
        console.log("Attacker balance:", initialAttackerBalance);
        console.log("Allowance:", token.allowance(user, attacker));

        // 1. User approves attacker to spend tokens
        console.log("\n[Action 1] User approves attacker");
        vm.prank(user);
        token.approve(attacker, approvalAmount);

        console.log("### Post-Approval State ###");
        console.log("Allowance after approval:", token.allowance(user, attacker));
        require(token.allowance(user, attacker) == approvalAmount, "Approval failed");

        // 2. Attacker spends approved amount
        console.log("\n[Action 2] Attacker transfers approved amount");
        uint256 preTransferAllowance = token.allowance(user, attacker);
        uint256 preTransferUserBalance = token.balanceOf(user);
        uint256 preTransferAttackerBalance = token.balanceOf(attacker);
        
        console.log("--- PRE-TRANSFER STATE ---");
        console.log("Allowance before transfer:", preTransferAllowance);
        console.log("User balance before transfer:", preTransferUserBalance);
        console.log("Attacker balance before transfer:", preTransferAttackerBalance);

        vm.prank(attacker);
        token.transferFrom(user, attacker, transferAmount);
        
        console.log("--- POST-TRANSFER STATE ---");
        console.log("Allowance after transfer:", token.allowance(user, attacker));
        console.log("User balance after transfer:", token.balanceOf(user));
        console.log("Attacker balance after transfer:", token.balanceOf(attacker));
        
        // Validate transfer occurred correctly
        require(
            token.balanceOf(user) == preTransferUserBalance - transferAmount,
            "User balance not decreased"
        );
        require(
            token.balanceOf(attacker) == preTransferAttackerBalance + transferAmount,
            "Attacker balance not increased"
        );
        require(
            token.allowance(user, attacker) == preTransferAllowance - transferAmount,
            "Allowance not reduced"
        );

        // 3. User reduces allowance to zero after noticing suspicious activity
        console.log("\n[Action 3] User resets allowance to 0");
        uint256 preResetBalance = token.balanceOf(user);
        uint256 preResetAttackerBalance = token.balanceOf(attacker);
        
        vm.prank(user);
        token.approve(attacker, zeroAllowanceAmount);
        
        console.log("### Post-Reset State ###");
        console.log("Allowance after reset:", token.allowance(user, attacker));
        console.log("User balance after reset:", token.balanceOf(user));
        console.log("Attacker balance after reset:", token.balanceOf(attacker));
        
        // Validate reset occurred
        require(
            token.allowance(user, attacker) == zeroAllowanceAmount,
            "Allowance reset failed"
        );
        require(
            token.balanceOf(user) == preResetBalance,
            "User balance changed during reset"
        );
        require(
            token.balanceOf(attacker) == preResetAttackerBalance,
            "Attacker balance changed during reset"
        );

        // 4. Validate that attacker attempt fails
        console.log("\n[Action 4] Attacker attempts transfer after reset");
        uint256 preAttemptAllowance = token.allowance(user, attacker);
        uint256 preAttemptUserBalance = token.balanceOf(user);
        uint256 preAttemptAttackerBalance = token.balanceOf(attacker);
        
        console.log("--- PRE-ATTEMPT STATE ---");
        console.log("Allowance before attempt:", preAttemptAllowance);
        console.log("User balance before attempt:", preAttemptUserBalance);
        console.log("Attacker balance before attempt:", preAttemptAttackerBalance);
        
        vm.prank(attacker);
        vm.expectRevert("BEP20: transfer amount exceeds allowance");
        token.transferFrom(user, attacker, smallTransfer);
        
        console.log("--- POST-ATTEMPT STATE (REVERT) ---");
        console.log("Allowance after attempt:", token.allowance(user, attacker));
        console.log("User balance after attempt:", token.balanceOf(user));
        console.log("Attacker balance after attempt:", token.balanceOf(attacker));
        
        // Validate state remains unchanged
        require(
            token.allowance(user, attacker) == preAttemptAllowance,
            "Allowance changed after failed attempt"
        );
        require(
            token.balanceOf(user) == preAttemptUserBalance,
            "User balance changed after failed attempt"
        );
        require(
            token.balanceOf(attacker) == preAttemptAttackerBalance,
            "Attacker balance changed after failed attempt"
        );

        // If we reach this point, all protections worked as expected
        vulnerabilityExists = false;
        vulnerabilityReason = "Token correctly handles allowance reset and prevents transfers";
    }
    
    // Final vulnerability verdict
    function tearDown() public {
        if (vulnerabilityExists) {
            console.log("\nVulnerability Exist: Token potentially allows transfers after allowance reset");
        } else {
            console.log("\nVulnerability not Exist: Token correctly handles allowance reset and prevents transfers");
        }
    }
}