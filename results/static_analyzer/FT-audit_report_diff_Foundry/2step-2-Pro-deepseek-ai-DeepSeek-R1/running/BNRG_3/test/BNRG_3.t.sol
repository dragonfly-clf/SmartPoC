// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BNRG.sol";

contract BNRGTest is Test {
    BNRG token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 initialSupply = 1000000 * (10**18); // Based on BEP-20 decimals
    address zeroAddress = address(0);

    function setUp() public {
        vm.startPrank(owner);
        token = new BNRG();
        token.mint(initialSupply); // Mint initial tokens to owner
        vm.stopPrank();
        
        // Unlock token transfers - critical step!
        vm.prank(owner);
        token.setRestrictionAmount(0);
        
        // Transfer some tokens to test user
        vm.prank(owner);
        token.transfer(user, initialSupply / 2);
    }

    function testTransferToZeroAddress() public {
        uint256 transferAmount = 100 * (10**18);

        // --- SNAPSHOT STATE BEFORE EXPLOIT ---
        console.log("--- BEFORE-TRIGGER STATE ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 zeroAddressBalanceBefore = token.balanceOf(zeroAddress);
        console.log("Owner balance:", ownerBalanceBefore);
        console.log("Zero address (burned tokens):", zeroAddressBalanceBefore);

        // --- PERFORM EXPLOIT ---
        console.log("");
        console.log("--- TRIGGERING EXPLOIT: Transfer to Zero Address ---");
        vm.prank(owner);
        token.transfer(zeroAddress, transferAmount);

        // --- SNAPSHOT STATE AFTER EXPLOIT ---
        console.log("");
        console.log("--- AFTER-TRIGGER STATE ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 zeroAddressBalanceAfter = token.balanceOf(zeroAddress);
        console.log("Owner balance:", ownerBalanceAfter);
        console.log("Zero address (burned tokens):", zeroAddressBalanceAfter);

        // --- VALIDATE EXPLOIT RESULTS ---
        console.log("");
        console.log("--- DIFFERENTIAL ANALYSIS ---");
        uint256 ownerDecrease = ownerBalanceBefore - ownerBalanceAfter;
        uint256 zeroAddressIncrease = zeroAddressBalanceAfter - zeroAddressBalanceBefore;
        bool ownerLostTokens = ownerDecrease == transferAmount;
        bool zeroAddressGainedTokens = zeroAddressIncrease == transferAmount;
        bool vulnerabilityExploited = ownerLostTokens && zeroAddressGainedTokens;
        
        console.log("Owner balance decrease (expected: %s, actual: %s)", transferAmount, ownerDecrease);
        console.log("Zero address increase (expected: %s, actual: %s)", transferAmount, zeroAddressIncrease);
        console.log("Vulnerable state:", vulnerabilityExploited ? "EXPLOITED" : "NOT EXPLOITED");
        
        // --- FINAL VERDICT ---
        console.log("");
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Transfer to zero address successfully burned tokens");
        } else {
            console.log("Vulnerability not Exist: Transfer to zero address failed to burn tokens properly");
        }
    }
}