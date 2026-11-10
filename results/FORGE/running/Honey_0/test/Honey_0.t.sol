// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/honeyToken.sol";

contract HoneyTokenMintBurnTest is Test {
    honeyToken token;
    address owner;
    address nonExcludedUser = address(0x100);
    address excludedUser = address(0x200);
    uint256 constant INITIAL_SUPPLY = 1000000 * 1e18;

    function setUp() public {
        owner = address(this);
        token = new honeyToken(
            "Honey Token",
            "HNY",
            18, // decimals
            1000000, // supply (1 million tokens)
            0, 0, 0, // txFee, burnFee, charityFee
            address(0), // FeeAddress
            owner // tokenOwner
        );
    }

    function test_MintToExcludedAccountFails() public {
        // Setup: Exclude account
        vm.prank(owner);
        token.excludeAccount(excludedUser);
        
        // Pre-state snapshot
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 initialBalance = token.balanceOf(excludedUser);
        uint256 initialTotalSupply = token.totalSupply();
        console.log("Excluded user balance:", initialBalance);
        console.log("Total supply:", initialTotalSupply);

        // Trigger operation
        uint256 mintAmount = 10 ether;
        console.log("--- Trigger Mint ---");
        console.log("Minting %s tokens to excluded account", mintAmount);
        vm.prank(owner);
        token.mint(excludedUser, mintAmount);

        // Post-state snapshot
        console.log("--- AFTER-Trigger Mint ---");
        uint256 postMintBalance = token.balanceOf(excludedUser);
        uint256 postTotalSupply = token.totalSupply();
        console.log("Excluded user balance:", postMintBalance);
        console.log("Total supply:", postTotalSupply);

        // Compare state changes
        console.log("--- Verification ---");
        if (postMintBalance == initialBalance && postTotalSupply == initialTotalSupply + mintAmount) {
            console.log("No balance change for excluded account");
            console.log("Total supply increased as expected");
            console.log("Vulnerability not Exist: Excluded account balance unchanged (correct behavior)");
        } else {
            console.log("Unexpected state changes occurred");
            console.log("Vulnerability Exists: Excluded account balance modified");
        }
    }

    function test_MintToNonExcludedAccountGetsZero() public {
        // Pre-state snapshot
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 initialBalance = token.balanceOf(nonExcludedUser);
        uint256 initialTotalSupply = token.totalSupply();
        console.log("Non-excluded user balance:", initialBalance);
        console.log("Total supply:", initialTotalSupply);

        // Trigger operation
        uint256 mintAmount = 10 ether;
        console.log("--- Trigger Mint ---");
        console.log("Minting %s tokens to non-excluded account", mintAmount);
        vm.prank(owner);
        token.mint(nonExcludedUser, mintAmount);

        // Post-state snapshot
        console.log("--- AFTER-Trigger Mint ---");
        uint256 postMintBalance = token.balanceOf(nonExcludedUser);
        uint256 postTotalSupply = token.totalSupply();
        console.log("Non-excluded user balance:", postMintBalance);
        console.log("Total supply:", postTotalSupply);

        // Compare state changes
        console.log("--- Verification ---");
        if (postMintBalance == 0 && postTotalSupply == initialTotalSupply + mintAmount) {
            console.log("Non-excluded user received 0 tokens");
            console.log("Total supply increased as expected");
            console.log("Vulnerability Exists: Minting failed for non-excluded account");
        } else if (postMintBalance == mintAmount) {
            console.log("Non-excluded user received full tokens");
            console.log("Vulnerability not Exist: Normal mint operation succeeded");
        } else {
            console.log("Vulnerability Exists: Unexpected token accounting behavior");
        }
    }
}