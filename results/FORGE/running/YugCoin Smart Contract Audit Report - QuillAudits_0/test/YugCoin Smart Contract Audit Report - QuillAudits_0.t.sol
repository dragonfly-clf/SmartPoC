// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YUG.sol";

contract YUGInfiniteMintTest is Test {
    YUG public token;
    address public owner;
    
    uint256 public constant MINT_AMOUNT = 1e18; // 1 token
    uint256 public constant LARGE_MINT_AMOUNT = 10e18; // 10 tokens
    
    function setUp() public {
        // Use a fork of BSC mainnet
        vm.createSelectFork("https://bsc-dataseed.binance.org/");

        owner = address(this);
        
        // Deploy the token contract - owner is automatically excluded from fees
        token = new YUG();
        
        // Verify setup
        assertEq(token.owner(), owner, "Test contract should be token owner");
    }
    
    function testOwnerCanMintUnlimitedTokens() public {
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 initialSupply = token.totalSupply();
        uint256 initialOwnerBalance = token.balanceOf(owner);
        console.log("Initial total supply: %s tokens", initialSupply);
        console.log("Initial owner balance: %s tokens", initialOwnerBalance);
        console.log("---------------------------");
        
        console.log("-- Trigger Mint 1 --");
        token.mint(owner, MINT_AMOUNT);
        console.log("Minted: 1 token");
        console.log("--------------------");
        
        console.log("-- Trigger Mint 2 --");
        token.mint(owner, LARGE_MINT_AMOUNT);
        console.log("Minted: 10 tokens");
        console.log("--------------------");
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 finalSupply = token.totalSupply();
        uint256 finalOwnerBalance = token.balanceOf(owner);
        console.log("Final total supply: %s tokens", finalSupply);
        console.log("Final owner balance: %s tokens", finalOwnerBalance);
        
        uint256 totalMinted = MINT_AMOUNT + LARGE_MINT_AMOUNT;
        uint256 supplyIncrease = finalSupply - initialSupply;
        uint256 ownerBalanceIncrease = finalOwnerBalance - initialOwnerBalance;
        console.log("Total minted: %s tokens", totalMinted);
        console.log("Net supply increase: %s tokens", supplyIncrease);
        console.log("Owner balance increase: %s tokens", ownerBalanceIncrease);
        
        bool vulnerabilityExists = (supplyIncrease == totalMinted) && 
                                   (ownerBalanceIncrease == totalMinted);
                                   
        if (vulnerabilityExists) {
            console.log("Vulnerability Status: EXISTS - Owner can mint unlimited tokens without supply cap");
        } else {
            console.log("Vulnerability Status: DOES NOT EXIST - Minting is limited by contract constraints");
        }
    }
}