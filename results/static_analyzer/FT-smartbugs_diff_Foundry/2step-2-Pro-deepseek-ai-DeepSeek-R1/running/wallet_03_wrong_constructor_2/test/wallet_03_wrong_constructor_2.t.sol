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

    function test_DepositZeroValue_Reverts() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("No state recorded (per differential analysis)");
        
        console.log("--- Trigger deposit with zero value ---");
        bool noRevert;
        vm.startPrank(user);
        try wallet.deposit{value: 0}() {
            noRevert = true;
        } catch {
            noRevert = false;
        }
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger ---");
        console.log("Transaction result:", noRevert ? "SUCCESS (no revert)" : "REVERT");
        
        // Final verdict output
        if (noRevert) {
            console.log("Vulnerability Exists: deposit() accepted zero value without reverting");
        } else {
            console.log("Vulnerability not Exist: deposit() reverted as expected");
        }
    }
}