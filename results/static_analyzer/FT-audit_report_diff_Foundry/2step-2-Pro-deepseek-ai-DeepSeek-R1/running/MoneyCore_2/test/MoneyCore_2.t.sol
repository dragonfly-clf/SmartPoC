// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoneyCore.sol";

contract MoneyCoreTest is Test {
    MoneyCore public token;
    address owner = makeAddr("owner");
    address controlRole = makeAddr("control");
    address attacker = makeAddr("attacker");
    
    bytes32 constant CONTROL_ROLE = keccak256("CONTROL_ROLE");

    function setUp() public {
        vm.startPrank(owner);
        token = new MoneyCore(1000, owner);
        token.grantRole(CONTROL_ROLE, controlRole);
        vm.stopPrank();
    }

    function testWithdrawAccessControl() public {
        uint256 withdrawAmount = 100 ether;
        
        console.log("--- BEFORE-Trigger (Unauthorized Withdraw) ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        console.log("Attacker balance (before): %s", attackerBalanceBefore);
        console.log("Contract balance (before): %s", contractBalanceBefore);

        console.log("--- Trigger: Unauthorized Withdraw ---");
        vm.prank(attacker);
        vm.expectRevert();
        token.withDraw(attacker, withdrawAmount);
        
        console.log("--- AFTER-Trigger (Unauthorized Withdraw) ---");
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        console.log("Attacker balance (after): %s", attackerBalanceAfter);
        console.log("Contract balance (after): %s", contractBalanceAfter);
        
        bool unauthorizedSuccess = (attackerBalanceAfter - attackerBalanceBefore == withdrawAmount) &&
                                  (contractBalanceBefore - contractBalanceAfter == withdrawAmount);
        console.log("Unauthorized withdrawal success: %s", unauthorizedSuccess ? "Yes" : "No");

        // --- Control Role Withdraw ---
        console.log("--- BEFORE-Trigger (Authorized Withdraw) ---");
        uint256 controlBalanceBefore = token.balanceOf(controlRole);
        contractBalanceBefore = token.balanceOf(address(token)); // Refresh contract balance
        console.log("Control balance (before): %s", controlBalanceBefore);
        console.log("Contract balance (before): %s", contractBalanceBefore);

        console.log("--- Trigger: Authorized Withdraw ---");
        vm.prank(controlRole);
        token.withDraw(controlRole, withdrawAmount);
        
        console.log("--- AFTER-Trigger (Authorized Withdraw) ---");
        uint256 controlBalanceAfter = token.balanceOf(controlRole);
        contractBalanceAfter = token.balanceOf(address(token));
        console.log("Control balance (after): %s", controlBalanceAfter);
        console.log("Contract balance (after): %s", contractBalanceAfter);
        
        bool authorizedSuccess = (controlBalanceAfter - controlBalanceBefore == withdrawAmount) &&
                                (contractBalanceBefore - contractBalanceAfter == withdrawAmount);
        console.log("Authorized withdrawal success: %s", authorizedSuccess ? "Yes" : "No");
        
        // Final verdict
        if (unauthorizedSuccess) {
            console.log("Vulnerability Exists: Attacker successfully performed unauthorized withdrawal");
        } else if (authorizedSuccess) {
            console.log("Vulnerability not Exist: Access control works as intended");
        } else {
            console.log("Vulnerability Exists: Withdraw function fails for authorized roles");
        }
    }
}