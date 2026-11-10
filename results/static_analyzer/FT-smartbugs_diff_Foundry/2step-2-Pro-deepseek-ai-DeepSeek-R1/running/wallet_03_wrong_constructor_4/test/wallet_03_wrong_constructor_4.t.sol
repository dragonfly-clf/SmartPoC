// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract WalletMigrateTest is Test {
    Wallet public wallet;
    address constant OWNER = address(0xDEAD);
    address constant USER = address(0xADD);
    uint256 constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        // Deploy the wallet contract
        wallet = new Wallet();
        
        // Initialize wallet to set creator
        wallet.initWallet();
        
        // Give USER some ETH
        vm.deal(USER, DEPOSIT_AMOUNT);
    }

    function test_migrateToZeroAddress() public {
        // Deposit funds to the wallet
        vm.prank(USER);
        wallet.deposit{value: DEPOSIT_AMOUNT}();
        
        // Verify wallet balance
        assertEq(address(wallet).balance, DEPOSIT_AMOUNT);
        
        // Differential verification setup
        console.log("--- BEFORE-Trigger State ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 zeroAddressBalanceBefore = address(0).balance;
        console.log("Wallet ETH balance:", walletBalanceBefore);
        console.log("Zero address ETH balance:", zeroAddressBalanceBefore);

        console.log("--- Trigger Migration ---");
        // Migrate funds to zero address as owner
        vm.prank(address(this));
        wallet.migrateTo(address(0));
        console.log(
            "Function: migrateTo(address(0))",
            "\nMigrated funds:", DEPOSIT_AMOUNT
        );

        console.log("--- AFTER-Trigger State ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 zeroAddressBalanceAfter = address(0).balance;
        console.log("Wallet ETH balance:", walletBalanceAfter);
        console.log("Zero address ETH balance:", zeroAddressBalanceAfter);

        // Compare state changes
        console.log("--- State Changes ---");
        uint256 walletChange = walletBalanceBefore - walletBalanceAfter;
        uint256 zeroAddressChange = zeroAddressBalanceAfter - zeroAddressBalanceBefore;
        
        console.log("Wallet ETH change:", walletChange);
        console.log("Zero address ETH change:", zeroAddressChange);
        
        // Vulnerability verification
        if (walletBalanceAfter == 0 && 
            walletChange == DEPOSIT_AMOUNT && 
            zeroAddressChange == DEPOSIT_AMOUNT) 
        {
            console.log("Verdict: Wallet funds fully migrated to zero address");
            console.log("Vulnerability Exists: Funds can be migrated to zero address");
        } else {
            console.log("Verdict: Unbalanced wallet migration detected");
            console.log("Vulnerability not Exist: Failed to migrate funds to zero address");
        }
    }
}