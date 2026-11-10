// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEXIMintTest is Test {
    DEXI token;
    address owner = address(this);

    function setUp() public {
        token = new DEXI();
    }

    function testMintBreaksSupplyPercentageAfterBurn() public {
        // Set fixed timestamp to target year
        vm.warp(1672531200); // Jan 1, 2023

        console.log("--- BEFORE-Trigger Minting Process ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 yearMintedBefore = token._yearMintedAmount(2023);
        console.log("Initial State:");
        console.log("  totalSupply: ", totalSupplyBefore);
        console.log("  yearMinted (2023): ", yearMintedBefore);

        // Execute first mint action
        console.log("--- Trigger: First Mint ---");
        uint256 firstMint = (totalSupplyBefore * 500) / 10000 / 2; // 2.5% of initial
        token.mint(owner, firstMint);

        console.log("--- AFTER-Trigger First Mint (Pre-Burn State) ---");
        uint256 supplyAfterMint = token.totalSupply();
        uint256 yearMintedAfterFirst = token._yearMintedAmount(2023);
        console.log("Post-First-Mint State:");
        console.log("  totalSupply: ", supplyAfterMint);
        console.log("  yearMinted (2023): ", yearMintedAfterFirst);

        // Execute burn action
        console.log("--- Trigger: Burn ---");
        uint256 burnAmount = supplyAfterMint / 2;
        token.burn(owner, burnAmount);

        console.log("--- AFTER-Trigger Burn (Pre-Second-Mint State) ---");
        uint256 supplyAfterBurn = token.totalSupply();
        uint256 yearMintedAfterBurn = token._yearMintedAmount(2023);
        console.log("Post-Burn State:");
        console.log("  totalSupply: ", supplyAfterBurn);
        console.log("  yearMinted (2023): ", yearMintedAfterBurn);

        // Execute second mint action
        console.log("--- Trigger: Second Mint ---");
        uint256 secondMint = firstMint; // same as first portion
        token.mint(owner, secondMint);

        console.log("--- AFTER-Trigger Second Mint ---");
        uint256 finalSupply = token.totalSupply();
        uint256 yearMintedAfterSecond = token._yearMintedAmount(2023);
        console.log("Final State:");
        console.log("  totalSupply: ", finalSupply);
        console.log("  yearMinted (2023): ", yearMintedAfterSecond);

        // Vulnerability verification
        uint256 allowedPercentageAmount = (finalSupply * 5) / 100;
        uint256 totalMintedInYear = yearMintedAfterSecond;
        
        console.log("--- Verification ---");
        console.log("Allowed 5 percent of final supply: ", allowedPercentageAmount);
        console.log("Actual minted in 2023:             ", totalMintedInYear);
        
        bool vulnerabilityExists = totalMintedInYear > allowedPercentageAmount;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Burn operation reduces total supply without adjusting minting limits, allowing inflation beyond 5%");
        } else {
            console.log("Vulnerability not Exist: Burn operation correctly resets minting limits, maintaining inflation below 5%");
        }

        assertGt(
            totalMintedInYear, 
            allowedPercentageAmount,
            "Minted tokens exceeded 5% of current supply"
        );
    }
}