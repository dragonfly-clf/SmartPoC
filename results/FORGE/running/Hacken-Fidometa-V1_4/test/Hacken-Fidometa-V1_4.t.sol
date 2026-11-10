// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidoMetaTest is Test {
    Fidometa token;
    address owner = address(this);
    address holder = address(0x123);
    uint256 constant INITIAL_SUPPLY = 15_000_000_000 * 10**9; // Initial supply in tokens

    function setUp() public {
        // Deploy token
        token = new Fidometa();

        // Exclude holder from all fees
        token.excludeFromCommunityCharge(holder);
        token.excludedFromEcoSysFee(holder);
        token.excludedFromSurcharge1(holder);
        token.excludedFromSurcharge2(holder);
        token.excludedFromSurcharge3(holder);
        token.excludeFromReward(holder);

        // Transfer exactly 10% of initial supply to holder
        uint256 holderAmount = INITIAL_SUPPLY / 10;
        token.transfer(holder, holderAmount);
    }

    function testSupplyManipulation() public {
        // Pre-burn states
        uint256 initialSupply = token.totalSupply();
        uint256 initialHolderBalance = token.balanceOf(holder);
        assertEq(initialHolderBalance, INITIAL_SUPPLY / 10, "Initial holder balance not 10%");

        console2.log("--- BEFORE-Trigger (Pre-Burn) ---");
        console2.log("Total Supply: ", initialSupply);
        console2.log("Holder Balance: ", initialHolderBalance);
        uint256 initialHolderShare = (initialHolderBalance * 10_000) / initialSupply;
        console2.log("Holder Share (basis points):", initialHolderShare);

        // Burn 75% of tokens
        console2.log("--- Trigger Burn ---");
        uint256 burnAmount = (initialSupply * 75) / 100;
        token.burn(burnAmount);

        // Post-burn states
        console2.log("--- AFTER-Trigger (Post-Burn) ---");
        uint256 supplyAfterBurn = token.totalSupply();
        uint256 holderBalanceAfterBurn = token.balanceOf(holder);
        console2.log("Total Supply: ", supplyAfterBurn);
        console2.log("Holder Balance: ", holderBalanceAfterBurn);
        uint256 holderShareAfterBurn = (holderBalanceAfterBurn * 10_000) / supplyAfterBurn;
        console2.log("Holder Share (basis points):", holderShareAfterBurn);
        console2.log("Change from initial share: %s -> %s", initialHolderShare, holderShareAfterBurn);

        // Mint back burned tokens
        console2.log("--- Trigger Mint ---");
        token.mint(burnAmount);

        // Post-mint states
        console2.log("--- AFTER-Trigger (Post-Mint) ---");
        uint256 finalSupply = token.totalSupply();
        uint256 finalHolderBalance = token.balanceOf(holder);
        console2.log("Total Supply: ", finalSupply);
        console2.log("Holder Balance: ", finalHolderBalance);
        uint256 finalHolderShare = (finalHolderBalance * 10_000) / finalSupply;
        console2.log("Holder Share (basis points):", finalHolderShare);
        console2.log("Change from initial share: %s -> %s", initialHolderShare, finalHolderShare);

        // Verdict criteria
        bool burnChangedShare = holderShareAfterBurn > initialHolderShare;
        bool mintRestoredSupply = (finalSupply == initialSupply);
        bool mintRestoredShare = (finalHolderShare == initialHolderShare);

        // Vulnerability verdict
        if (burnChangedShare && mintRestoredSupply && mintRestoredShare) {
            console2.log("Vulnerability Exists: Owner can arbitrarily change supply through burn/mint operations, directly affecting holder percentage share");
        } else {
            console2.log("Vulnerability Not Exist: Supply manipulation test didn't produce expected state changes - Burn effect:%s Restore effect:%s/%s",
                burnChangedShare, mintRestoredSupply, mintRestoredShare);
        }
    }
}