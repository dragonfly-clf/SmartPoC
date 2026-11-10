// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JOKECOMMUNITY.sol";

contract JOKECOMMUNITYTest is Test {
    JOKECOMMUNITY public token;
    address owner = address(0xABCD);
    address alice = address(0x1);
    address bob = address(0x2);
    
    function setUp() public {
        // Create fork of BSC (requires BSC_RPC_URL in .env)
        string memory rpcUrl = vm.envOr("BSC_RPC_URL", string("https://bsc-dataseed.binance.org/"));
        vm.createSelectFork(rpcUrl);

        vm.startPrank(owner);
        token = new JOKECOMMUNITY();
        token.transferUnlock(); // Enable transfers
        token.setSwapAndLiquifyEnabled(false); // Disable liquidity features
        
        // Transfer initial tokens to Alice
        uint256 amount = token.totalSupply() / 10;
        token.transfer(alice, amount);
        vm.stopPrank();
    }

    function testZeroMaxTxBlocksTransfers() public {
        uint256 transferAmount = 1;
        
        console.log("--- PRE-TRIGGER Transfer ---");
        console.log("State Before Transfer:");
        console.log("Alice Balance:", token.balanceOf(alice));
        console.log("Bob Balance:", token.balanceOf(bob));
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        
        // Pre-trigger transfer
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        
        console.log("\nState After Pre-Trigger Transfer:");
        console.log("Alice Balance:", token.balanceOf(alice));
        console.log("Bob Balance:", token.balanceOf(bob));
        
        // Calculate actual transfer amount (considering possible fees)
        uint256 aliceDiff = aliceBalanceBefore - token.balanceOf(alice);
        uint256 bobDiff = token.balanceOf(bob) - bobBalanceBefore;
        console.log("\nActual transfer amount from Alice:", aliceDiff);
        console.log("Actual received amount by Bob:", bobDiff);

        console.log("\n--- TRIGGER ACTION ---");
        // Owner sets max transaction to 0%
        console.log("Executing: token.setMaxTxPercent(0)");
        vm.prank(owner);
        token.setMaxTxPercent(0);
        
        console.log("\nMaxTxAmount after trigger:", token._maxTxAmount());
        
        console.log("\n--- POST-TRIGGER Transfer Attempt ---");
        console.log("State Before Transfer Attempt:");
        console.log("Alice Balance:", token.balanceOf(alice));
        console.log("Bob Balance:", token.balanceOf(bob));
        uint256 aliceBalanceAttemptBefore = token.balanceOf(alice);
        uint256 bobBalanceAttemptBefore = token.balanceOf(bob);
        
        // Attempt transfer that should fail
        console.log("\nAttempting Transfer (expect revert)...");
        vm.prank(alice);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(bob, transferAmount);
        
        console.log("\nState After Blocked Transfer:");
        console.log("Alice Balance:", token.balanceOf(alice));
        console.log("Bob Balance:", token.balanceOf(bob));
        
        // Verify balances unchanged
        bool blocked = (token.balanceOf(alice) == aliceBalanceAttemptBefore) &&
                       (token.balanceOf(bob) == bobBalanceAttemptBefore);
        
        console.log("\nTransfer blocked:", blocked ? "SUCCESS" : "FAIL");
        
        console.log("\n--- VERIFY OWNER TRANSFER ---");
        // Ensure owner can still transfer
        uint256 ownerAmount = token.balanceOf(owner) / 10;
        uint256 aliceBalanceBeforeOwnerTx = token.balanceOf(alice);
        
        vm.prank(owner);
        token.transfer(alice, ownerAmount);
        
        bool ownerTxSuccess = token.balanceOf(alice) == aliceBalanceBeforeOwnerTx + ownerAmount;
        console.log("Owner transfer successful:", ownerTxSuccess ? "YES" : "NO");
        
        console.log("\n--- VERDICT ---");
        if (blocked && ownerTxSuccess) {
            console.log("Vulnerability Exists: Non-owner transfers blocked while owner transfers work");
        } else {
            console.log("Vulnerability not Exist: Transfer restrictions not applied correctly");
        }
    }
}