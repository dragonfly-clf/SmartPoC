// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DinoXInuContract.sol";

contract TestTotalSupplyDiversion is Test {
    DinoXInuContract token;
    address constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    address constant owner = address(0x1); // Dedicated EOA owner address
    
    function setUp() public {
        vm.startPrank(owner); // Deploy token as owner EOA
        token = new DinoXInuContract();
        vm.stopPrank();
    }

    function testManualBurnAccounting() public {
        // Precompute burn amount
        uint256 decimals = token.decimals();
        uint256 burnAmount = 1000 * (10 ** decimals);
        
        console.log("--- BEFORE-Trigger state ---");
        // Capture pre-burn state
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialDeadBalance = token.balanceOf(deadWallet);
        
        // Log initial state
        console.log("Initial Total Supply:    %s", initialTotalSupply);
        console.log("Initial Owner Balance:   %s", initialOwnerBalance);
        console.log("Initial Dead Balance:    %s", initialDeadBalance);
        
        console.log("--- Trigger action: manualBurn ---");
        // Execute burn as owner via prank
        vm.prank(owner);
        token.manualBurn(burnAmount);
        console.log("Executed burnAmount: %s", burnAmount);
        
        console.log("--- AFTER-Trigger state ---");
        // Capture post-burn state
        uint256 newTotalSupply = token.totalSupply();
        uint256 newOwnerBalance = token.balanceOf(owner);
        uint256 newDeadBalance = token.balanceOf(deadWallet);
        uint256 totalBalances = newOwnerBalance + newDeadBalance;
        
        // Log post-state
        console.log("New Total Supply:       %s", newTotalSupply);
        console.log("New Owner Balance:      %s", newOwnerBalance);
        console.log("New Dead Balance:       %s", newDeadBalance);
        
        // Compute changes
        uint256 supplyChange = initialTotalSupply - newTotalSupply;
        uint256 ownerChange = initialOwnerBalance - newOwnerBalance;
        uint256 deadChange = newDeadBalance - initialDeadBalance;
        
        // Log differential comparisons
        console.log("Total Supply Change:    %s (expected %s)", supplyChange, burnAmount);
        console.log("Owner Balance Change:   %s (expected %s)", ownerChange, 2 * burnAmount);
        console.log("Dead Wallet Change:     %s (expected %s)", deadChange, burnAmount);
        console.log("Total Balances:         %s (matches total supply: %s)", totalBalances, (totalBalances == newTotalSupply ? "YES" : "NO"));
        
        // Vulnerability validation conditions
        bool vulnerabilityExists = 
            (supplyChange == burnAmount) &&
            (ownerChange == 2 * burnAmount) &&
            (deadChange == burnAmount) &&
            (totalBalances == newTotalSupply);
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: ManualBurn causes double token reduction for owner");
        } else {
            console.log("Vulnerability not Exist: Expected accounting behavior preserved");
        }
    }
}