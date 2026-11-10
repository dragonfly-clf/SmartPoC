// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract BabyApeCoinMintTest is Test {
    BabyApeCoin token;
    address owner = address(0x123);

    function setUp() public {
        vm.prank(owner);
        token = new BabyApeCoin();
    }

    function testOwnerCanMint() public {
        uint256 mintAmount = 1000 ether;
        
        // Pre-trigger state capture
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialZeroBalance = token.balanceOf(address(0));
        
        console.log("Initial Total Supply:", initialTotalSupply);
        console.log("Initial Owner Balance:", initialOwnerBalance);
        console.log("Initial Zero Address Balance:", initialZeroBalance);
        
        // Vulnerability trigger action
        console.log("--- Trigger Mint Operation ---");
        vm.prank(owner);
        token.mint(owner, mintAmount);
        
        // Post-trigger state capture
        console.log("--- AFTER-Trigger State ---");
        uint256 newTotalSupply = token.totalSupply();
        uint256 newOwnerBalance = token.balanceOf(owner);
        uint256 newZeroBalance = token.balanceOf(address(0));
        
        console.log("New Total Supply:", newTotalSupply);
        console.log("New Owner Balance:", newOwnerBalance);
        console.log("New Zero Address Balance:", newZeroBalance);
        
        // Vulnerability verification
        console.log("--- Vulnerability Verification ---");
        bool totalSupplyChanged = (newTotalSupply == initialTotalSupply + mintAmount);
        bool ownerBalanceChanged = (newOwnerBalance == initialOwnerBalance + mintAmount);
        bool zeroBalanceUnchanged = (newZeroBalance == initialZeroBalance);
        bool vulnerabilityExists = totalSupplyChanged && ownerBalanceChanged && zeroBalanceUnchanged;

        console.log("Total Supply Verified:", totalSupplyChanged ? "Passed" : "Failed");
        console.log("Owner Balance Verified:", ownerBalanceChanged ? "Passed" : "Failed");
        console.log("Zero Balance Unchanged Verified:", zeroBalanceUnchanged ? "Passed" : "Failed");
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can arbitrarily mint new tokens without restrictions");
        } else {
            console.log("Vulnerability not Exist: Token minting either failed or resulted in unexpected state changes");
            if (!totalSupplyChanged) {
                console.log("Reason: Total supply not increased by mint amount");
            }
            if (!ownerBalanceChanged) {
                console.log("Reason: Owner balance not increased by mint amount");
            }
            if (!zeroBalanceUnchanged) {
                console.log("Reason: Zero address balance changed unexpectedly");
            }
            fail("Vulnerability verification failed");
        }
    }
}