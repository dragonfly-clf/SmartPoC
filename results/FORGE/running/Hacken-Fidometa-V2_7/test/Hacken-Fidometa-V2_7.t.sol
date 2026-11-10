// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FeeOverflowTest is Test {
    Fidometa token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address recipient = makeAddr("recipient");
    uint256 decimals;
    uint256 maxFee;
    uint256 transferAmount;

    function setUp() public {
        vm.startPrank(owner);
        token = new Fidometa();
        vm.stopPrank();
        
        decimals = token.decimals();
        maxFee = 100 * 10 ** decimals;
        
        // Grant user tokens and calculate safe transfer amount
        uint256 userAmount = 1 * 10 ** decimals;
        transferAmount = userAmount / 10; // 0.1 token
        
        vm.prank(owner);
        token.transfer(user, userAmount);
    }

    function testFeeOverflowRevertsTransfer() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        // Get initial balances
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console2.log("User balance Before:    ", userBalanceBefore);
        console2.log("Recipient balance Before:", recipientBalanceBefore);

        // Normal transfer (should succeed)
        console2.log("Performing pre-fee transfer...");
        vm.prank(user);
        token.transfer(recipient, transferAmount);

        // Capture state after pre-fee transfer
        uint256 userBalanceMid = token.balanceOf(user);
        uint256 recipientBalanceMid = token.balanceOf(recipient);
        console2.log("User balance After:     ", userBalanceMid);
        console2.log("Recipient balance After: ", recipientBalanceMid);
        console2.log("Pre-trigger transfer SUCCESS");

        console2.log("\n--- Trigger SetHighFees ---");
        // Owner sets all fees to 100%
        vm.startPrank(owner);
        token.setCommunityCharge(maxFee);
        token.setEcoSysFee(maxFee);
        token.setSurcharge1(maxFee);
        token.setSurcharge2(maxFee);
        token.setSurcharge3(maxFee);
        vm.stopPrank();
        console2.log("All fees set to 100%");

        console2.log("\n--- AFTER-Trigger Transfer ---");
        // Get balances before attempted transfer
        uint256 userPreTransfer = token.balanceOf(user);
        uint256 recipientPreTransfer = token.balanceOf(recipient);
        console2.log("User balance Before:    ", userPreTransfer);
        console2.log("Recipient balance Before:", recipientPreTransfer);

        // Attempt transfer (expected to revert)
        console2.log("Attempting transfer with 500% fees...");
        vm.prank(user);
        vm.expectRevert();
        token.transfer(recipient, transferAmount);

        // Capture state after attempted transfer
        uint256 userPostTransfer = token.balanceOf(user);
        uint256 recipientPostTransfer = token.balanceOf(recipient);
        console2.log("User balance After:     ", userPostTransfer);
        console2.log("Recipient balance After: ", recipientPostTransfer);

        // Verify state unchanged (due to revert)
        bool balancesUnchanged = (userPreTransfer == userPostTransfer) && 
                                (recipientPreTransfer == recipientPostTransfer);
        console2.log("Balances unchanged?    ", balancesUnchanged ? "YES" : "NO");
        console2.log("Post-trigger transfer REVERTED");

        // Vulnerability verdict
        if(balancesUnchanged) {
            console2.log("\nVulnerability Exists: Transfer reverts after setting fees to 100%, indicating fee overflow blocking transfers");
        } else {
            console2.log("\nVulnerability not Exist: Transfer succeeded despite 500% total fees");
        }
    }
}