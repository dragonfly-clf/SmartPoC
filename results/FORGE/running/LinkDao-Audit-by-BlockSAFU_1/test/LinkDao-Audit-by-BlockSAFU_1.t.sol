// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract LinkDaoTokenTest is Test {
    LINKDAO_Token token;
    address owner;

    function setUp() public {
        token = new LINKDAO_Token();
        owner = token.owner();
    }

    function testMintBeyondMaxSupply() public {
        // Switch to owner account
        vm.startPrank(owner);

        // Get current parameters
        uint256 maxSupply = token.maxSupply();
        uint256 totalSupply = token.totalSupply();
        uint256 remainingMintAmount = maxSupply - totalSupply;

        // First mint fills remaining supply
        if (remainingMintAmount > 0) {
            token.mint(remainingMintAmount);
        }

        // Verify we're at max supply
        assertEq(token.totalSupply(), maxSupply, "Should be at max supply");

        // Differential state checks setup
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 preMintSupply = token.totalSupply();
        uint256 preMintOwnerBalance = token.balanceOf(owner);
        console.log("Pre-mint total supply:", preMintSupply);
        console.log("Pre-mint owner balance:", preMintOwnerBalance);

        console.log("--- Trigger: token.mint(1) ---");

        // Test minting beyond max supply
        bool mintResult = token.mint(1);
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 postMintSupply = token.totalSupply();
        uint256 postMintOwnerBalance = token.balanceOf(owner);
        console.log("Post-mint total supply:", postMintSupply);
        console.log("Post-mint owner balance:", postMintOwnerBalance);

        // Check incorrect return value (issue)
        assertTrue(mintResult, "Mint should return true even when failing");
        
        // Verify supply remains unchanged (state inconsistency)
        assertEq(
            token.totalSupply(),
            maxSupply,
            "Supply increased despite mint failure"
        );

        // Vulnerability validation logic
        bool stateUnchanged = (postMintSupply == preMintSupply) &&
            (postMintOwnerBalance == preMintOwnerBalance);

        // Final vulnerability verdict
        if (mintResult && stateUnchanged) {
            console.log("Vulnerability Exists: Mint returns true without state changes when minting beyond max supply");
        } else {
            console.log("Vulnerability not Exist: Expected state change not present or incorrect return value");
        }

        vm.stopPrank();
    }
}