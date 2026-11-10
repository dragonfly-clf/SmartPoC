// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_04_confused_sign.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address owner = address(this);
    address user = address(0x1337);
    address user2 = address(0x2);   // Added second user

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 5 ether);
        vm.deal(user2, 5 ether);   // Fund user2
        wallet = new Wallet();
    }

    function test_VulnerableWithdrawal() public {
        // User1 deposits 1 ETH
        vm.prank(user);
        wallet.deposit{value: 1 ether}();
        
        // User2 deposits 1 ETH to fund contract
        vm.prank(user2);
        wallet.deposit{value: 1 ether}();
        
        // Verify initial user balance
        assertEq(wallet.getBalance(user), 1 ether, "User balance should be 1 ETH");
        
        // --- BEFORE-Trigger Withdrawal ---
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore = wallet.getBalance(user);
        uint256 contractBalanceBefore = address(wallet).balance;
        console.log("User balance (pre):", userBalanceBefore);
        console.log("Contract balance (pre):", contractBalanceBefore);
        
        // --- Trigger Withdrawal Attempt ---
        console.log("--- Trigger Withdrawal Attempt ---");
        // Expect arithmetic underflow reverts
        vm.expectRevert(stdError.arithmeticError);
        vm.prank(user);
        wallet.withdraw(2 ether);
        
        // --- AFTER-Trigger Withdrawal ---
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter = wallet.getBalance(user);
        uint256 contractBalanceAfter = address(wallet).balance;
        console.log("User balance (post):", userBalanceAfter);
        console.log("Contract balance (post):", contractBalanceAfter);
        
        // State comparison
        bool userBalanceUnchanged = (userBalanceBefore == userBalanceAfter);
        bool contractBalanceUnchanged = (contractBalanceBefore == contractBalanceAfter);
        bool isVulnerable = !(userBalanceUnchanged && contractBalanceUnchanged);
        
        console.log("User balance unchanged:", userBalanceUnchanged ? "Yes" : "No");
        console.log("Contract balance unchanged:", contractBalanceUnchanged ? "Yes" : "No");
        
        // Final vulnerability verdict
        if (isVulnerable) {
            console.log("Vulnerability Exists: Post-trigger state change detected");
        } else {
            console.log("Vulnerability not Exist: All balances remain unchanged");
        }
    }
}