// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock timelock;
    address alice = address(0x100);
    address bob = address(0x101);
    uint256 constant LOCK_PERIOD = 1 weeks;

    function setUp() public {
        vm.deal(alice, 2 ether);
        vm.deal(bob, 2 ether);
        timelock = new TimeLock();
    }

    function testTimestampManipulationVulnerability() public {
        // ===== ALICE SCENARIO: Normal Flow ===== //
        vm.warp(1000);
        vm.prank(alice);
        timelock.deposit{value: 1 ether}();
        
        vm.warp(1000 + LOCK_PERIOD + 1);
        vm.prank(alice);
        timelock.withdraw();

        // ===== BOB SCENARIO: Vulnerability Test ===== //
        vm.warp(3000);
        vm.prank(bob);
        timelock.deposit{value: 1 ether}();
        uint256 initialLockTime = timelock.lockTime(bob);
        console.log("Bob's initial lock time: ", initialLockTime);
        
        // --- PRE-TRIGGER STATE --- //
        console.log("--- PRE-EXPLOIT STATE ---");
        uint256 bobBalancePre = bob.balance;
        uint256 contractBalancePre = address(timelock).balance;
        console.log("Bob balance (pre):     ", bobBalancePre);
        console.log("Contract balance (pre): ", contractBalancePre);
        
        // Early withdrawal attempt (should fail)
        vm.warp(3000 + LOCK_PERIOD - 1);
        vm.prank(bob);
        vm.expectRevert("Funds are still locked");
        timelock.withdraw();

        // --- TRIGGER: Manipulate timestamp to exact lock time --- //
        console.log("\n--- TRIGGER ATTACK ---");
        console.log("Manipulating to exact lock time: %s", initialLockTime);
        vm.warp(initialLockTime);

        // Record state before attack attempt
        console.log("\n--- ATTACK EXECUTION ---");
        uint256 bobBalanceBeforeAtk = bob.balance;
        uint256 contractBalanceBeforeAtk = address(timelock).balance;
        console.log("Bob balance (pre-atk):    ", bobBalanceBeforeAtk);
        console.log("Contract balance (pre-atk):", contractBalanceBeforeAtk);
        
        // Execute withdrawal at exact lock time (using low-level call)
        vm.prank(bob);
        (bool atkSuccess, ) = address(timelock).call(
            abi.encodeWithSignature("withdraw()")
        );
        console.log("Attack result: ", atkSuccess ? "SUCCESS" : "FAILURE");
        
        // --- POST-TRIGGER STATE --- //
        console.log("\n--- POST-EXPLOIT STATE ---");
        uint256 bobBalanceAfterAtk = bob.balance;
        uint256 contractBalanceAfterAtk = address(timelock).balance;
        console.log("Bob balance (post-atk):    ", bobBalanceAfterAtk);
        console.log("Contract balance (post-atk):", contractBalanceAfterAtk);
        
        // --- STATE COMPARISON --- //
        console.log("\n--- STATE CHANGE RESULTS ---");
        bool fundsMoved = (bobBalanceAfterAtk > bobBalanceBeforeAtk) &&
                          (contractBalanceAfterAtk < contractBalanceBeforeAtk);
        
        console.log("Balance change detected:", fundsMoved ? "YES" : "NO");
        
        // --- VULNERABILITY VERDICT --- //
        console.log("\n--- VULNERABILITY VERDICT ---");
        if (fundsMoved) {
            console.log("Vulnerability Exists: Withdrawal succeeded at exact lock time");
        } else {
            console.log("Vulnerability not Exist: Contract requires timestamp > lockTime");
        }
        
        // Cleanup: Normal withdrawal after lock period
        console.log("\n--- CLEANUP: NORMAL WITHDRAWAL ---");
        vm.warp(initialLockTime + 1);
        vm.prank(bob);
        timelock.withdraw();
        console.log("Bob final balance: ", bob.balance);
    }
}