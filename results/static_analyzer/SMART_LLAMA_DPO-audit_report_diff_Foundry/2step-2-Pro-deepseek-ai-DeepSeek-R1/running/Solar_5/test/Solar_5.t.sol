// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/Solar.sol";

contract SolarTest is Test {
    Solar token;
    uint256 MAX_SUPPLY;

    address owner = address(0x1);
    address user1 = address(0x3);

    function setUp() public {
        vm.prank(owner);
        token = new Solar();
        MAX_SUPPLY = token.getMaxTotalSupply();
    }

    function testMaxSupplyEnforced() public {
        // First mint: valid (just below max supply)
        uint256 firstMintAmount = MAX_SUPPLY - 10;
        
        console2.log("--- BEFORE-Trigger Mint [1] ---");
        uint256 totalSupplyBefore1 = token.totalSupply();
        uint256 balanceBefore1 = token.balanceOf(user1);
        console2.log("Pre-mint: totalSupply:", totalSupplyBefore1, "| user1 balance:", balanceBefore1);

        console2.log("--- Trigger Mint [1] ---");
        vm.prank(owner);
        token.mint(user1, firstMintAmount);
        
        console2.log("--- AFTER-Trigger Mint [1] ---");
        uint256 totalSupplyAfter1 = token.totalSupply();
        uint256 balanceAfter1 = token.balanceOf(user1);
        console2.log("Post-mint: totalSupply:", totalSupplyAfter1, "| user1 balance:", balanceAfter1);
        
        uint256 deltaTotal1 = totalSupplyAfter1 - totalSupplyBefore1;
        uint256 deltaBalance1 = balanceAfter1 - balanceBefore1;
        console2.log("Delta comparison (expected %d):", firstMintAmount);
        console2.log("  totalSupply Δ:", deltaTotal1);
        console2.log("  user1 balance Δ:", deltaBalance1);

        // Second mint: 10 tokens
        console2.log("--- BEFORE-Trigger Mint [2] ---");
        uint256 totalSupplyBefore2 = token.totalSupply();
        uint256 balanceBefore2 = token.balanceOf(user1);
        console2.log("Pre-mint: totalSupply:", totalSupplyBefore2, "| user1 balance:", balanceBefore2);

        console2.log("--- Trigger Mint [2] ---");
        vm.prank(owner);
        token.mint(user1, 10);
        
        console2.log("--- AFTER-Trigger Mint [2] ---");
        uint256 totalSupplyAfter2 = token.totalSupply();
        uint256 balanceAfter2 = token.balanceOf(user1);
        console2.log("Post-mint: totalSupply:", totalSupplyAfter2, "| user1 balance:", balanceAfter2);
        
        uint256 deltaTotal2 = totalSupplyAfter2 - totalSupplyBefore2;
        uint256 deltaBalance2 = balanceAfter2 - balanceBefore2;
        console2.log("Delta comparison (expected 10):");
        console2.log("  totalSupply Δ:", deltaTotal2);
        console2.log("  user1 balance Δ:", deltaBalance2);

        // Third mint: should revert
        console2.log("--- BEFORE-Trigger Mint [3] ---");
        uint256 totalSupplyBefore3 = token.totalSupply();
        uint256 balanceBefore3 = token.balanceOf(user1);
        console2.log("Pre-mint: totalSupply:", totalSupplyBefore3, "| user1 balance:", balanceBefore3);

        console2.log("--- Trigger Mint [3] (expect revert) ---");
        vm.prank(owner);
        vm.expectRevert("ERC20: minting more than MaxTotalSupply");
        token.mint(user1, 1);
        
        console2.log("--- AFTER-Trigger Mint [3] ---");
        uint256 totalSupplyAfter3 = token.totalSupply();
        uint256 balanceAfter3 = token.balanceOf(user1);
        console2.log("Post-mint: totalSupply:", totalSupplyAfter3, "| user1 balance:", balanceAfter3);
        
        uint256 deltaTotal3 = totalSupplyAfter3 - totalSupplyBefore3;
        uint256 deltaBalance3 = balanceAfter3 - balanceBefore3;
        console2.log("Delta comparison (expected 0):");
        console2.log("  totalSupply Δ:", deltaTotal3);
        console2.log("  user1 balance Δ:", deltaBalance3);
        
        // Vulnerability verdict
        if (deltaTotal3 > 0 || deltaBalance3 > 0) {
            console2.log("Vulnerability Exists: Max supply bypassed with state change");
        } else {
            console2.log("Vulnerability not Exist: Max supply enforced");
        }
    }
}