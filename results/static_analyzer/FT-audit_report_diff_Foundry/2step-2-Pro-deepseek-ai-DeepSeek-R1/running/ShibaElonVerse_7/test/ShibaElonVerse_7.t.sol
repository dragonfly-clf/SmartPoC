// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ShibaElonVerse.sol";

contract ShibaElonVerseFeeTest is Test {
    ShibaElonVerse token;
    
    function setUp() public {
        // Deploy token contract with real BSC interaction
        vm.createSelectFork("https://bsc-dataseed.binance.org/");
        token = new ShibaElonVerse();
    }

    function test_FeeManipulation() public {
        // Set buy fees to 2501 (25.01%)
        uint16 reward = 2501;
        uint16 marketing = 0;
        uint16 burn = 0;
        
        console.log("--- BEFORE-Trigger Fee State ---");
        (uint16 preBuyRewardFee, uint16 preBuyMarketingFee, ) = token.buyFee();
        (uint16 preSellRewardFee, uint16 preSellMarketingFee, ) = token.sellFee();
        console.log("BuyFees (Reward, Marketing): (%d, %d)", preBuyRewardFee, preBuyMarketingFee);
        console.log("SellFees (Reward, Marketing): (%d, %d)", preSellRewardFee, preSellMarketingFee);

        console.log("--- Trigger Fee Change ---");
        // Execute function calls - should NOT revert
        vm.prank(token.owner());
        token.setBuyFees(reward, marketing, burn);

        vm.prank(token.owner());
        token.setSellFees(reward, marketing, burn);

        console.log("--- AFTER-Trigger Fee State ---");
        (uint16 postBuyRewardFee, uint16 postBuyMarketingFee, ) = token.buyFee();
        (uint16 postSellRewardFee, uint16 postSellMarketingFee, ) = token.sellFee();
        console.log("BuyFees (Reward, Marketing): (%d, %d)", postBuyRewardFee, postBuyMarketingFee);
        console.log("SellFees (Reward, Marketing): (%d, %d)", postSellRewardFee, postSellMarketingFee);

        // Vulnerability validation
        bool feesChanged = 
            (postBuyRewardFee == reward && postBuyMarketingFee == marketing) &&
            (postSellRewardFee == reward && postSellMarketingFee == marketing);
        
        console.log("Differential Result:", 
            feesChanged ? "Fees modified successfully" : "Fees remain unchanged");

        if (feesChanged) {
            console.log("Vulnerability Exists: Fees can be set above 25% maximum threshold");
        } else {
            console.log("Vulnerability not Exist: Contract correctly restricts maximum fees");
        }
    }
}