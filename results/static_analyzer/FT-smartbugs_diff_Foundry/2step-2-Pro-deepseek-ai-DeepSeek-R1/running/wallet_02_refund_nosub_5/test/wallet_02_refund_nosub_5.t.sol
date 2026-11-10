// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletTest is Test {
    Wallet wallet;
    address constant ZERO_ADDRESS = address(0);
    address creator;
    MaliciousContract maliciousReceiver;

    function setUp() public {
        creator = makeAddr("creator");
        vm.prank(creator);
        wallet = new Wallet();
        
        // Fund the contract
        vm.deal(address(wallet), 5 ether);
        assertEq(address(wallet).balance, 5 ether, "initial balance");
    }

    // Test zero address migration vulnerability
    function test_MigrateToZeroAddressBurnsFunds() public {
        console.log("--- BEFORE-Trigger Migration ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 targetBalanceBefore = ZERO_ADDRESS.balance;
        console.log("Wallet balance before: %s", walletBalanceBefore);
        console.log("Target balance before: %s", targetBalanceBefore);

        console.log("--- Trigger Migration to Zero Address ---");
        vm.prank(creator);
        wallet.migrateTo(ZERO_ADDRESS);

        console.log("--- AFTER-Trigger Migration ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 targetBalanceAfter = ZERO_ADDRESS.balance;
        console.log("Wallet balance after: %s", walletBalanceAfter);
        console.log("Target balance after: %s", targetBalanceAfter);

        bool vulnerabilityExists = (walletBalanceAfter == 0) && 
            (targetBalanceAfter == targetBalanceBefore);
        console.log("Vulnerability state: %s", vulnerabilityExists ? "EXISTS" : "DOES NOT EXIST");
        console.log(vulnerabilityExists ? 
            "Vulnerability Exists: Migrating to zero address burned funds without balance change at target" : 
            "Vulnerability not Exist: Funds not burned as expected");

        // Original assertion
        assertEq(address(wallet).balance, 0, "funds not burned");
    }

    // Test self-address migration vulnerability - should revert
    function test_MigrateToSelfAddressReverts() public {
        address target = address(wallet);
        
        console.log("--- BEFORE-Trigger Migration ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 targetBalanceBefore = target.balance;
        console.log("Wallet balance before: %s", walletBalanceBefore);
        console.log("Target balance before: %s", targetBalanceBefore);

        console.log("--- Trigger Migration to Self Address ---");
        vm.prank(creator);
        vm.expectRevert();
        wallet.migrateTo(target);

        console.log("--- AFTER-Trigger Migration ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 targetBalanceAfter = target.balance;
        console.log("Wallet balance after: %s", walletBalanceAfter);
        console.log("Target balance after: %s", targetBalanceAfter);

        bool vulnerabilityExists = (walletBalanceAfter != walletBalanceBefore) || 
            (targetBalanceAfter != targetBalanceBefore);
        console.log("Vulnerability state: %s", vulnerabilityExists ? "EXISTS" : "DOES NOT EXIST");
        console.log(vulnerabilityExists ? 
            "Vulnerability Exists: State changed unexpectedly after revert" : 
            "Vulnerability not Exist: Migration to self reverted successfully with unchanged balances");

        // Original assertion
        assertEq(address(wallet).balance, 5 ether, "funds should remain after revert");
    }

    // Test migration to malicious contract vulnerability (non-zero, non-self) succeeds
    function test_MigrateToMaliciousContractSucceeds() public {
        maliciousReceiver = new MaliciousContract();
        address target = address(maliciousReceiver);
        
        console.log("--- BEFORE-Trigger Migration ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 targetBalanceBefore = target.balance;
        console.log("Wallet balance before: %s", walletBalanceBefore);
        console.log("Target balance before: %s", targetBalanceBefore);

        console.log("--- Trigger Migration to Malicious Contract ---");
        vm.prank(creator);
        wallet.migrateTo(target);

        console.log("--- AFTER-Trigger Migration ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 targetBalanceAfter = target.balance;
        console.log("Wallet balance after: %s", walletBalanceAfter);
        console.log("Target balance after: %s", targetBalanceAfter);

        bool vulnerabilityExists = (walletBalanceAfter == 0) && 
            (targetBalanceAfter == walletBalanceBefore);
        console.log("Vulnerability state: %s", vulnerabilityExists ? "EXISTS" : "DOES NOT EXIST");
        console.log(vulnerabilityExists ? 
            "Vulnerability Exists: Funds successfully migrated to malicious contract" : 
            "Vulnerability not Exist: Funds not transferred successfully");

        // Original assertion
        assertEq(address(maliciousReceiver).balance, 5 ether, "funds not received");
    }
}

contract MaliciousContract {
    receive() external payable {}
}