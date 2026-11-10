// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address user = makeAddr("user");

    function setUp() public {
        wallet = new Wallet();
    }

    function testZeroAddressBalance() public {
        address zeroAddr = address(0);
        bool success;
        uint256 balance;

        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Preparing to query zero address balance");

        console2.log("--- Trigger Action ---");
        // Attempt query using try-catch
        try wallet.getBalance(zeroAddr) returns (uint256 _balance) {
            success = true;
            balance = _balance;
        } catch {
            success = false;
        }

        console2.log("--- AFTER-Trigger State ---");
        if (success) {
            console2.log("Outcome: Query succeeded without revert");
            console2.log("Returned balance:", balance);
        } else {
            console2.log("Outcome: Query reverted");
        }

        // Determine and print final verdict
        string memory verdict;
        if (success && balance == 0) {
            verdict = "Vulnerability Exists: Querying zero address balance does not revert and returns zero";
        } else if (success) {
            verdict = "Vulnerability not Exist: Query succeeded but returned non-zero balance";
        } else {
            verdict = "Vulnerability not Exist: Query reverted";
        }
        
        console2.log(verdict);
    }
}