// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_04_confused_sign.sol";

contract WalletTest is Test {
    Wallet wallet;
    address private owner = vm.addr(1);
    address private user = vm.addr(2);
    address private attacker = vm.addr(3);

    function setUp() public {
        vm.prank(owner);
        wallet = new Wallet();
        
        // Fund user and contract
        vm.deal(user, 1 ether);
        vm.deal(address(wallet), 1 ether);
    }

    function test_migrateToDrainByMaliciousOwner() public {
        uint256 initialAttackerBalance = attacker.balance;
        uint256 contractBalance = address(wallet).balance;

        console.log("--- BEFORE-Trigger ---");
        console.log("Contract balance: %s", contractBalance);
        console.log("Attacker balance: %s", initialAttackerBalance);

        console.log("--- Trigger migrateTo(attacker) ---");
        // Owner drains funds to attacker address
        vm.prank(owner);
        wallet.migrateTo(attacker);

        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = attacker.balance;

        console.log("Contract balance: %s", contractBalanceAfter);
        console.log("Attacker balance: %s", attackerBalanceAfter);

        // Check state change for vulnerability existence
        bool fundsDrained = contractBalanceAfter == 0 && 
                           attackerBalanceAfter == initialAttackerBalance + contractBalance;

        if (fundsDrained) {
            console.log("Vulnerability Exists: Owner successfully drained contract funds to attacker");
        } else {
            console.log("Vulnerability not Exist: Contract funds not drained to attacker");
        }

        // Original assertions for test verification
        assertEq(address(wallet).balance, 0, "Contract balance should be zero");
        assertEq(
            attacker.balance, 
            initialAttackerBalance + contractBalance, 
            "Attacker should receive funds"
        );
    }
}