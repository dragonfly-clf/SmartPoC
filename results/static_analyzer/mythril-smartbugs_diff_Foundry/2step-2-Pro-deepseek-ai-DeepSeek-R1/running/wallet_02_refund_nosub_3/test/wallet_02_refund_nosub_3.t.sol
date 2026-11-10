// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletTest is Test {
    Wallet wallet;
    address user = address(0x69);

    function setUp() public {
        wallet = new Wallet();
        vm.deal(user, 2 ether);
    }

    function test_totalDepositOverflow() public {
        // Set totalDeposits to max-1 (simulate pre-existing large deposits)
        vm.store(address(wallet), bytes32(uint256(2)), bytes32(type(uint256).max - 1));
        
        console.log("--- BEFORE-Trigger Deposit ---");
        console.log("Total Deposits (initial):", wallet.totalDeposits());
        console.log("User ETH Balance (initial):", user.balance);
        
        console.log("--- Trigger Deposit ---");
        bool success;
        vm.startPrank(user);
        try wallet.deposit{value: 2 ether}() {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger Deposit ---");
        console.log("Total Deposits (updated):", wallet.totalDeposits());
        console.log("User ETH Balance (updated):", user.balance);

        if (success) {
            console.log("Vulnerability Exists: Deposit succeeded despite totalDeposit overflow");
        } else {
            console.log("Vulnerability not Exist: Overflow protection works (deposit reverted)");
        }
    }
}