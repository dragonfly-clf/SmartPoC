// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletTest is Test {
    Wallet wallet;
    address owner = address(0x1);
    address user1 = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        wallet = new Wallet();
        vm.stopPrank();

        // User1 deposits some ETH
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();
    }

    function testRefundAccessControlIssue() public {
        // Pre-state snapshot
        console.log("--- BEFORE-Trigger wallet.refund ---");
        uint256 walletBalancePre = address(wallet).balance;
        uint256 attackerBalancePre = attacker.balance;
        uint256 attackerInternalBalancePre = wallet.getBalance(attacker);
        
        console.log("Wallet ETH balance: %d", walletBalancePre);
        console.log("Attacker external balance: %d", attackerBalancePre);
        console.log("Attacker internal balance: %d", attackerInternalBalancePre);

        // Log the trigger action
        console.log("--- Trigger wallet.refund ---");
        vm.prank(attacker);
        wallet.refund();
        
        // Post-state snapshot
        console.log("--- AFTER-Trigger wallet.refund ---");
        uint256 walletBalancePost = address(wallet).balance;
        uint256 attackerBalancePost = attacker.balance;
        uint256 attackerInternalBalancePost = wallet.getBalance(attacker);
        
        console.log("Wallet ETH balance: %d", walletBalancePost);
        console.log("Attacker external balance: %d", attackerBalancePost);
        console.log("Attacker internal balance: %d", attackerInternalBalancePost);
        
        // Differential analysis
        console.log("--- VERDICT ---");
        bool walletDecrease = walletBalancePost < walletBalancePre;
        bool attackerGain = attackerBalancePost > attackerBalancePre;
        bool internalStable = (attackerInternalBalancePre == attackerInternalBalancePost);
        
        console.log(
            "State changes - Wallet reduced: %s, Attacker gained: %s, Internal balance unchanged: %s", 
            walletDecrease ? "YES" : "NO",
            attackerGain ? "YES" : "NO",
            internalStable ? "YES" : "NO"
        );
        
        // Vulnerability validation
        if (walletDecrease && attackerGain && internalStable && attackerInternalBalancePre == 0) {
            console.log("Vulnerability Exists: Unauthorized fund transfer detected");
        } else {
            console.log("Vulnerability not Exist: No unauthorized fund transfer occurred");
        }

        // Original assertions remain unchanged
        assertEq(address(wallet).balance, 1 ether, "Wallet balance should remain unchanged");
        assertEq(attacker.balance, attackerBalancePre, "Attacker balance should not increase");
    }

    function testLegitimateRefund() public {
        // Check initial balance
        uint256 initialBalance = address(wallet).balance;
        assertEq(initialBalance, 1 ether);

        // Legitimate user refunds
        vm.prank(user1);
        wallet.refund();

        // Verify funds returned to legitimate user
        assertEq(address(wallet).balance, 0, "Wallet should be empty after refund");
        assertEq(user1.balance, 1 ether, "User should receive their deposit back");
    }
}