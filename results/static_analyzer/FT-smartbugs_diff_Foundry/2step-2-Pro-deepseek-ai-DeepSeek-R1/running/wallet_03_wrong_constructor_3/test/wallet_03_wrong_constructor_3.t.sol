// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        wallet = new Wallet();
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_depositWithdraw() public {
        // Deposit from user1
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();
        
        // Valid withdrawal
        vm.prank(user1);
        wallet.withdraw(0.5 ether);
        
        // Verify balance deduction
        assertEq(wallet.getBalance(user1), 0.5 ether, "Post-withdrawal balance incorrect");
    }

    function test_withdrawExceedingBalance_Reverts() public {
        // Setup user2 deposit
        vm.prank(user2);
        wallet.deposit{value: 1 ether}();
        
        console2.log("--- BEFORE-Trigger (user2 balance) ---");
        uint256 beforeBalance = wallet.getBalance(user2);
        console2.log("Balance of user2:", beforeBalance);
        
        console2.log("--- Trigger Withdraw (1.5 ether) ---");
        bool success;
        vm.startPrank(user2);
        try wallet.withdraw(1.5 ether) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger (user2 balance) ---");
        uint256 afterBalance = wallet.getBalance(user2);
        console2.log("Balance of user2:", afterBalance);
        
        // Vulnerability verification
        if (success && afterBalance > beforeBalance) {
            console2.log("Vulnerability Exists: Underflow caused balance to become abnormally large");
        } else if (success) {
            console2.log("Vulnerability not Exist: Withdrawal succeeded without balance underflow");
        } else {
            console2.log("Vulnerability not Exist: Withdrawal reverted as expected");
        }
    }
}