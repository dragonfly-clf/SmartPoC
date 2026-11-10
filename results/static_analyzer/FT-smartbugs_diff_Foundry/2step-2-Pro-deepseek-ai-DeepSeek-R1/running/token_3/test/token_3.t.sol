// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenMintTest is Test {
    Token public token;
    address owner = address(0x1);
    uint256 public constant INITIAL_SUPPLY = 1000;
    uint256 public constant MINT_AMOUNT = 1e40; // Extremely large amount

    function setUp() public {
        vm.prank(owner);
        token = new Token(INITIAL_SUPPLY);
    }

    function test_UnlimitedMinting() public {
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console.log("Total supply before: %s", totalSupplyBefore);
        console.log("Owner balance before: %s", ownerBalanceBefore);

        console.log("--- Trigger Mint ---");
        vm.prank(owner);
        token.mint(MINT_AMOUNT);

        console.log("--- AFTER-Trigger Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("Total supply after: %s", totalSupplyAfter);
        console.log("Owner balance after: %s", ownerBalanceAfter);

        // Calculate expected values after mint
        uint256 expectedTotalSupply = totalSupplyBefore + MINT_AMOUNT;
        uint256 expectedOwnerBalance = ownerBalanceBefore + MINT_AMOUNT;
        
        // Compare actual vs expected state changes
        bool totalSupplyCorrect = (totalSupplyAfter == expectedTotalSupply);
        bool ownerBalanceCorrect = (ownerBalanceAfter == expectedOwnerBalance);
        bool vulnerabilityExists = totalSupplyCorrect && ownerBalanceCorrect;

        console.log("State comparison:");
        console.log("Total supply change: Actual %s vs Expected %s", 
                    totalSupplyAfter - totalSupplyBefore, MINT_AMOUNT);
        console.log("Owner balance change: Actual %s vs Expected %s", 
                    ownerBalanceAfter - ownerBalanceBefore, MINT_AMOUNT);
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Successfully minted 1e40 tokens without supply cap");
        } else {
            console.log("Vulnerability not Exist: Token supply constraints prevented unlimited minting");
        }
    }
}