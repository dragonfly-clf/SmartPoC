// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Added for console logging
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    MoBaToken token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 private constant INITIAL_TOKENS = 100;
    
    function setUp() public {
        vm.prank(owner);
        token = new MoBaToken("TestToken", "TT");
    }

    function test_DecimalsOperations() public {
        // State monitoring preamble
        console.log("--- BEFORE: Decimals Initial State ---");
        uint8 initialDecimals = token.decimals();
        console.log("Initial decimals:", initialDecimals);
        
        // Critical operation 1: Decimal check
        console.log("--- Trigger Operation: decimals() ---");
        uint8 dec = token.decimals();
        
        console.log("--- AFTER: Decimals After Check ---");
        console.log("Post-check decimals:", dec);

        // Token operation state
        console.log("--- BEFORE: Token Operation State ---");
        uint256 supplyBefore = token.totalSupply();
        uint256 userBalBefore = token.balanceOf(user);
        console.log("Pre-trigger supply:", supplyBefore);
        console.log("Pre-trigger user balance:", userBalBefore);

        // Mint tokens
        console.log("--- Trigger Operation: cross() mint ---");
        uint256 decimalsFactor = 10 ** dec;
        uint256 mintAmount = INITIAL_TOKENS * decimalsFactor;
        vm.prank(owner);
        token.cross(user, mintAmount);
        
        console.log("--- AFTER: After Mint ---");
        uint256 supplyAfterMint = token.totalSupply();
        uint256 userBalAfterMint = token.balanceOf(user);
        console.log("Post-mint supply:", supplyAfterMint);
        console.log("Post-mint user balance:", userBalAfterMint);

        // Burn tokens
        console.log("--- Trigger Operation: managerBurn() ---");
        uint256 burnAmount = (INITIAL_TOKENS / 2) * decimalsFactor;
        vm.prank(owner);
        token.managerBurn(user, burnAmount);

        // Final state verification
        console.log("--- AFTER: Final State ---");
        uint256 finalBalance = token.balanceOf(user);
        uint256 finalSupply = token.totalSupply();
        uint256 expectedBalance = (INITIAL_TOKENS / 2) * decimalsFactor;
        uint256 expectedSupply = (INITIAL_TOKENS / 2) * decimalsFactor;
        console.log("Final user balance:", finalBalance);
        console.log("Final total supply:", finalSupply);

        // Arithmetic consistency check
        bool dataConsistent = (finalBalance == expectedBalance) && 
                              (finalSupply == expectedSupply) && 
                              (dec == initialDecimals);
        
        // Vulnerability verdict
        if (dataConsistent) {
            console.log("Vulnerability not Exist: Arithmetic consistency maintained after operations");
        } else {
            console.log("Vulnerability Exists: Arithmetic inconsistency detected from decimal format vulnerability");
        }
    }
}