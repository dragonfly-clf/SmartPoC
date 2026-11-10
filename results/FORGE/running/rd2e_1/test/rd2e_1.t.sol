// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RD2E.sol";

contract RD2E_Mint_Test is Test {
    RD2E public token;
    address public owner = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        vm.prank(owner);
        token = new RD2E();
    }

    function test_OwnerCanArbitrarilyMintTokens() public {
        // Record initial states before any mint
        console.log("--- BEFORE-Trigger First Mint ---");
        uint initialOwnerBalance0 = token.balanceOf(owner);
        uint initialUserBalance0 = token.balanceOf(user);
        uint initialTotalSupply0 = token.totalSupply();
        console.log("Initial owner balance:", initialOwnerBalance0);
        console.log("Initial user balance:", initialUserBalance0);
        console.log("Initial total supply:", initialTotalSupply0);

        // Take mint action to owner
        console.log("--- Trigger Mint (100 tokens to owner) ---");
        vm.startPrank(owner);
        token.mint(owner, 100);
        vm.stopPrank();

        // Record state after first mint
        console.log("--- AFTER-Trigger First Mint ---");
        uint postOwnerBalance1 = token.balanceOf(owner);
        uint postUserBalance1 = token.balanceOf(user);
        uint postTotalSupply1 = token.totalSupply();
        console.log("Owner balance after first mint:", postOwnerBalance1);
        console.log("User balance after first mint:", postUserBalance1);
        console.log("Total supply after first mint:", postTotalSupply1);

        // Get difference
        uint ownerDiff1 = postOwnerBalance1 - initialOwnerBalance0;
        uint supplyDiff1 = postTotalSupply1 - initialTotalSupply0;
        console.log("Change in owner balance:", ownerDiff1);
        console.log("Change in total supply:", supplyDiff1);
        console.log("Verification: First mint transfer %s", (ownerDiff1 == 100 && supplyDiff1 == 100) ? "SUCCESS" : "FAIL");

        // Record state before second mint
        console.log("--- BEFORE-Trigger Second Mint ---");
        uint preOwnerBalance1 = postOwnerBalance1;
        uint preUserBalance1 = postUserBalance1;
        uint preTotalSupply1 = postTotalSupply1;
        console.log("Owner balance before second mint:", preOwnerBalance1);
        console.log("User balance before second mint:", preUserBalance1);
        console.log("Total supply before second mint:", preTotalSupply1);

        // Take mint action to user
        console.log("--- Trigger Mint (200 tokens to user) ---");
        vm.prank(owner);
        token.mint(user, 200);

        // Record state after second mint
        console.log("--- AFTER-Trigger Second Mint ---");
        uint postOwnerBalance2 = token.balanceOf(owner);
        uint postUserBalance2 = token.balanceOf(user);
        uint postTotalSupply2 = token.totalSupply();
        console.log("Owner balance after second mint:", postOwnerBalance2);
        console.log("User balance after second mint:", postUserBalance2);
        console.log("Total supply after second mint:", postTotalSupply2);

        // Get difference
        uint userDiff2 = postUserBalance2 - preUserBalance1;
        uint supplyDiff2 = postTotalSupply2 - preTotalSupply1;
        console.log("Change in user balance:", userDiff2);
        console.log("Change in total supply:", supplyDiff2);
        console.log("Verification: Second mint transfer %s", (userDiff2 == 200 && supplyDiff2 == 200) ? "SUCCESS" : "FAIL");

        // Final verification check
        bool vulnerabilityExists = 
            (ownerDiff1 == 100) && (supplyDiff1 == 100) &&
            (userDiff2 == 200) && (supplyDiff2 == 200);
            
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can arbitrarily mint tokens without supply restrictions");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions are properly enforced");
        }
    }

    function test_NonOwnerCannotMint() public {
        // Non-owner should fail to mint tokens
        vm.startPrank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(user, 100);
        vm.stopPrank();
    }
}