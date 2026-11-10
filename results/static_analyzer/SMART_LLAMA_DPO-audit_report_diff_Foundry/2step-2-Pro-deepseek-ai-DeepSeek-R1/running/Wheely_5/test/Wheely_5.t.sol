// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyFeeTest is Test {
    Wheely token;
    address owner = address(0x1);
    address user = address(0x2);
    address feeAddress = address(0x9);
    address recipient = address(0x3);

    function setUp() public {
        // Deploy token as owner
        vm.startPrank(owner);
        token = new Wheely("Test Token", "TST", 18, 1000, feeAddress);
        vm.stopPrank();

        // Transfer initial tokens from owner to user with proper authorization
        uint initialAmount = 100 * 10 ** token.decimals();
        vm.prank(owner);
        token.transfer(user, initialAmount);
    }

    function testZeroValueTransferBypassFee() public {
        console.log("--- BEFORE-Trigger State ---");
        uint userBalanceBefore = token.balanceOf(user);
        uint recipientBalanceBefore = token.balanceOf(recipient);
        uint feeBalanceBefore = token.balanceOf(feeAddress);
        console.log("User balance:", userBalanceBefore);
        console.log("Recipient balance:", recipientBalanceBefore);
        console.log("Fee balance:", feeBalanceBefore);

        console.log("--- Trigger Action: Zero Value Transfer ---");
        vm.prank(user);
        token.transfer(recipient, 0);

        console.log("--- AFTER-Trigger State ---");
        uint userBalanceAfter = token.balanceOf(user);
        uint recipientBalanceAfter = token.balanceOf(recipient);
        uint feeBalanceAfter = token.balanceOf(feeAddress);
        console.log("User balance:", userBalanceAfter);
        console.log("Recipient balance:", recipientBalanceAfter);
        console.log("Fee balance:", feeBalanceAfter);

        console.log("--- Differential Check ---");
        bool userChanged = userBalanceAfter != userBalanceBefore;
        bool recipientChanged = recipientBalanceAfter != recipientBalanceBefore;
        bool feeChanged = feeBalanceAfter != feeBalanceBefore;
        bool changesDetected = userChanged || recipientChanged || feeChanged;
        
        if (!changesDetected) {
            console.log("State unchanged - Vulnerability exists: Zero transfer bypasses fee");
        } else {
            console.log("State changed - Vulnerability not exist: Zero transfer incurred fee");
        }
    }

    function testTinyAmountTransferBypassFee() public {
        uint testAmount = 1; // 1 wei
        
        console.log("--- BEFORE-Trigger State ---");
        uint userBalanceBefore = token.balanceOf(user);
        uint recipientBalanceBefore = token.balanceOf(recipient);
        uint feeBalanceBefore = token.balanceOf(feeAddress);
        console.log("User balance:", userBalanceBefore);
        console.log("Recipient balance:", recipientBalanceBefore);
        console.log("Fee balance:", feeBalanceBefore);

        console.log("--- Trigger Action: Tiny Amount Transfer (%s wei) ---", testAmount);
        vm.prank(user);
        token.transfer(recipient, testAmount);

        console.log("--- AFTER-Trigger State ---");
        uint userBalanceAfter = token.balanceOf(user);
        uint recipientBalanceAfter = token.balanceOf(recipient);
        uint feeBalanceAfter = token.balanceOf(feeAddress);
        console.log("User balance:", userBalanceAfter);
        console.log("Recipient balance:", recipientBalanceAfter);
        console.log("Fee balance:", feeBalanceAfter);

        console.log("--- Differential Check ---");
        uint expectedRecipientGain = testAmount;
        uint expectedFee = 0;
        bool feeBypassed = true;
        
        // Check if balances changed unexpectedly
        if (userBalanceAfter != userBalanceBefore - testAmount) {
            feeBypassed = false;
        }
        if (recipientBalanceAfter != recipientBalanceBefore + expectedRecipientGain) {
            feeBypassed = false;
        }
        if (feeBalanceAfter != feeBalanceBefore + expectedFee) {
            feeBypassed = false;
        }
        
        if (feeBypassed) {
            console.log("Vulnerability exists: Tiny amount fee bypass detected");
        } else {
            console.log("Vulnerability not exist: Fee was properly charged");
        }
    }
}