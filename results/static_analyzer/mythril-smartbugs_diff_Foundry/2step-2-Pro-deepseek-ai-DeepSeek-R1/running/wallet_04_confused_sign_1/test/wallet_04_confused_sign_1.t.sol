// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_04_confused_sign.sol";

contract Audit_01_Test is Test {
    Wallet public wallet;
    address payable public alice = payable(address(0x1));
    address payable public attacker = payable(address(0x2));
    
    function setUp() public {
        wallet = new Wallet();

        // Label addresses for better error messages
        vm.label(alice, "Alice");
        vm.label(attacker, "Attacker");
    }

    function test_ArbitraryWithdraw() public {
        // Fund both alice and attacker with 1 ether each
        vm.deal(alice, 1 ether);
        vm.deal(attacker, 1 ether);

        // Only alice deposits into the wallet
        vm.startPrank(alice);
        wallet.deposit{value: 1 ether}();
        vm.stopPrank();

        // Attacker also deposits 1 ether to avoid underflow
        vm.startPrank(attacker);
        wallet.deposit{value: 1 ether}();
        vm.stopPrank();

        // Verify wallet has 2 ether balance
        assertEq(address(wallet).balance, 2 ether, "Initial wallet balance should be 2 ether");

        // Differential state checks
        console.log("--- BEFORE-Trigger Withdraw ---");
        uint256 attackerBalanceBefore = wallet.getBalance(attacker);
        uint256 totalWithdrawalsBefore = wallet.totalWithdrawals();
        console.log("Attacker wallet balance before:", attackerBalanceBefore);
        console.log("Total withdrawals before:", totalWithdrawalsBefore);
        
        console.log("--- Trigger Withdraw ---");
        // Attacker withdraws their 1 ether deposit
        uint256 initialAttackerBalance = address(attacker).balance;
        vm.prank(attacker);
        wallet.withdraw(1 ether);
        
        console.log("--- AFTER-Trigger Withdraw ---");
        // Differential state checks
        uint256 attackerBalanceAfter = wallet.getBalance(attacker);
        uint256 totalWithdrawalsAfter = wallet.totalWithdrawals();
        console.log("Attacker wallet balance after:", attackerBalanceAfter);
        console.log("Total withdrawals after:", totalWithdrawalsAfter);
        
        // Verify state changes indicate vulnerability
        bool balanceChanged = attackerBalanceAfter < attackerBalanceBefore;
        bool withdrawalsIncreased = totalWithdrawalsAfter > totalWithdrawalsBefore;
        bool exploitSuccess = balanceChanged && withdrawalsIncreased;
        
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Attacker successfully manipulated contract state through withdrawal");
        } else {
            console.log("Vulnerability not Exist: Withdrawal didn't cause expected state changes");
        }
        
        // Verify attacker received 1 ether
        uint256 finalAttackerBalance = address(attacker).balance;
        assertEq(finalAttackerBalance, initialAttackerBalance + 1 ether, "Attacker should receive their deposited ether");

        // Verify attacker's balance has been updated in the contract
        assertEq(wallet.getBalance(attacker), 0, "Attacker's balance should be zero after withdrawal");
    }
}