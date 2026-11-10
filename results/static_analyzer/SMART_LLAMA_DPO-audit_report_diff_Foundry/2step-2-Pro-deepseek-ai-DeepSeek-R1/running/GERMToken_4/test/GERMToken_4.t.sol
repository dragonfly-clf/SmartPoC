// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GERMToken.sol";

contract GERMTokenPrivilegeTest is Test {
    GERMToken token;
    address owner = address(0x1);
    address recipient = address(0x2);
    uint256 constant HUGE_AMOUNT = 1e30; // Arbitrarily large token amount

    function setUp() public {
        // Deploy the contract as the owner
        vm.prank(owner);
        token = new GERMToken();
    }

    function testOwnerCanMintArbitraryAmount() public {
        // Record initial state BEFORE mint
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 initialRecipientBalance = token.balanceOf(recipient);
        uint256 initialSupply = token.totalSupply();
        console.log("Recipient balance before:", initialRecipientBalance);
        console.log("Total supply before:", initialSupply);

        console.log("--- Trigger Mint ---");
        // Owner mints huge amount to recipient
        vm.prank(owner);
        token.mint(recipient, HUGE_AMOUNT);
        
        // Record final state AFTER mint
        console.log("--- AFTER-Trigger Mint ---");
        uint256 finalRecipientBalance = token.balanceOf(recipient);
        uint256 finalSupply = token.totalSupply();
        console.log("Recipient balance after:", finalRecipientBalance);
        console.log("Total supply after:", finalSupply);

        // Differential validation
        bool mintSucceeded = (finalRecipientBalance == initialRecipientBalance + HUGE_AMOUNT) 
                          && (finalSupply == initialSupply + HUGE_AMOUNT);
        
        if (mintSucceeded) {
            console.log("Vulnerability Exists: Owner successfully minted arbitrary tokens");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions are effective");
        }
        assertTrue(mintSucceeded, "Minting should succeed without restrictions");
    }

    function testOwnerCanSelfMint() public {
        // Record initial state BEFORE mint
        console.log("--- BEFORE-Trigger Self Mint ---");
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialSupply = token.totalSupply();
        console.log("Owner balance before:", initialOwnerBalance);
        console.log("Total supply before:", initialSupply);

        console.log("--- Trigger Self Mint ---");
        // Owner mints to themselves
        vm.prank(owner);
        token.mint(HUGE_AMOUNT);
        
        // Record final state AFTER mint
        console.log("--- AFTER-Trigger Self Mint ---");
        uint256 finalOwnerBalance = token.balanceOf(owner);
        uint256 finalSupply = token.totalSupply();
        console.log("Owner balance after:", finalOwnerBalance);
        console.log("Total supply after:", finalSupply);

        // Differential validation
        bool mintSucceeded = (finalOwnerBalance == initialOwnerBalance + HUGE_AMOUNT) 
                          && (finalSupply == initialSupply + HUGE_AMOUNT);
        
        if (mintSucceeded) {
            console.log("Vulnerability Exists: Owner successfully self-minted arbitrary tokens");
        } else {
            console.log("Vulnerability not Exist: Self-minting restrictions are effective");
        }
        assertTrue(mintSucceeded, "Self-minting should succeed without restrictions");
    }
}