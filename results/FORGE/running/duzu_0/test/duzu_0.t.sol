// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol"; // Import console2
import "../src/DUZU_Coin.sol";

contract DUZUMintingTest is Test {
    DUZU_Coin token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    uint256 constant INITIAL_SUPPLY = 1000 ether;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        
        token = new DUZU_Coin{value: 1 ether}(
            address(0xDEAD), // DUZU_target
            "TestToken",     // DUZU_name
            "TT",            // DUZU_symbol
            18,              // DUZU_decimals
            INITIAL_SUPPLY   // DUZU_initial
        );
    }

    function test_unprivilegedMinting() public {
        uint256 mintAmount = 5000 ether;
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 totalSupplyBefore = token.totalSupply();
        console2.log("Owner balance before minting:", ownerBalanceBefore);
        console2.log("Total supply before minting:", totalSupplyBefore);
        
        console2.log("--- Trigger Minting ---");
        vm.prank(owner);
        token.mint(owner, mintAmount);
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 totalSupplyAfter = token.totalSupply();
        console2.log("Owner balance after minting:", ownerBalanceAfter);
        console2.log("Total supply after minting:", totalSupplyAfter);
        
        bool balanceIncreased = (ownerBalanceAfter == ownerBalanceBefore + mintAmount);
        bool supplyIncreased = (totalSupplyAfter == totalSupplyBefore + mintAmount);
        
        if (balanceIncreased && supplyIncreased) {
            console2.log("Vulnerability Exists: Arbitrary token minting by owner is possible");
        } else {
            console2.log("Vulnerability not Exist: Minting operation did not change state as expected");
        }
    }
}