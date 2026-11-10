// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract LinkDaoTokenTest is Test {
    LINKDAO_Token token;
    address owner;
    
    function setUp() public {
        owner = address(this);
        token = new LINKDAO_Token();
    }

    function test_MintBeyondMaxSupplyReturnsTrue() public {
        // Record initial state
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 maxSupply = token.maxSupply();

        // Calculate amount that would exceed max supply (add 1 to overflow)
        uint256 exceedAmount;
        if (maxSupply > totalSupplyBefore) {
            exceedAmount = (maxSupply - totalSupplyBefore) + 1;
        } else {
            // If already at max supply, attempt to mint 1 token
            exceedAmount = 1;
        }

        // Log the state before
        console.log("--- BEFORE-Trigger ---");
        console.log("Total Supply (Before):", totalSupplyBefore);
        console.log("Owner Balance (Before):", ownerBalanceBefore);
        console.log("Max Supply:", maxSupply);
        console.log("Attempting to mint amount:", exceedAmount);

        console.log("--- Trigger Mint ---");
        bool mintResult = token.mint(exceedAmount);
        console.log("Mint Result (returned):", mintResult);

        console.log("--- AFTER-Trigger ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console.log("Total Supply (After):", totalSupplyAfter);
        console.log("Owner Balance (After):", ownerBalanceAfter);

        // Check differences
        uint256 supplyChange = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceChange = ownerBalanceAfter - ownerBalanceBefore;
        console.log("Change in Total Supply:", supplyChange);
        console.log("Change in Owner Balance:", balanceChange);

        // Vulnerability condition: mint returns true but state did not change.
        if (mintResult && supplyChange == 0 && balanceChange == 0) {
            console.log("Vulnerability Exists: Mint function returned true but state was unchanged (mint exceeding max supply failed as expected, but function returned true indicating success).");
        } else {
            console.log("Vulnerability not Exist: Either mint function returned false, or the state changed (mint was successful or partially successful).");
        }
    }
}