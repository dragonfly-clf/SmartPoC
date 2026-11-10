// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyTest is Test {
    Wheely public token;
    address public owner = makeAddr("owner");
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** DECIMALS);
    address public constant FEE_ADDRESS = address(0);

    function setUp() public {
        vm.prank(owner);
        token = new Wheely("WheelyToken", "WHEEL", DECIMALS, INITIAL_SUPPLY, FEE_ADDRESS);
    }

    function test_OwnerCanMintArbitraryTokens() public {
        // Capture initial state before minting
        uint256 preTotalSupply = token.totalSupply();
        uint256 preOwnerBalance = token.balanceOf(owner);
        
        console.log("--- BEFORE-Trigger Mint ---");
        console.log("Total supply:", preTotalSupply);
        console.log("Owner balance:", preOwnerBalance);
        
        uint256 mintAmount = 1000 * (10 ** DECIMALS);
        console.log("--- Trigger Mint ---");
        
        // Perform critical action: owner mints tokens
        vm.prank(owner);
        token.mint(mintAmount);
        
        // Capture state after minting
        console.log("--- AFTER-Trigger Mint ---");
        uint256 postTotalSupply = token.totalSupply();
        uint256 postOwnerBalance = token.balanceOf(owner);
        console.log("Total supply:", postTotalSupply);
        console.log("Owner balance:", postOwnerBalance);
        
        // Calculate actual changes
        uint256 actualSupplyChange = postTotalSupply - preTotalSupply;
        uint256 actualOwnerBalanceChange = postOwnerBalance - preOwnerBalance;
        
        console.log("Actual supply change:", actualSupplyChange);
        console.log("Actual owner balance change:", actualOwnerBalanceChange);
        console.log("Expected changes:", mintAmount);
        
        // Vulnerability verdict
        if (actualSupplyChange == mintAmount && actualOwnerBalanceChange == mintAmount) {
            console.log("Vulnerability Exists: Owner can mint arbitrary tokens, diluting holder value");
        } else {
            console.log("Vulnerability not Exist: Token minting constraints work as expected");
        }
    }
}