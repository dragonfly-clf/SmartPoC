// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/Play2Burn.sol";

contract Play2BurnTest is Test {
    Play2Burn token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockPair = address(0x456);
    address mockWETH = address(0x789);
    address mockFactory = address(0x123);

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory pair creation
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy contract as owner
        vm.startPrank(owner);
        token = new Play2Burn();
        vm.stopPrank();
    }

    function test_HighFeeSettings() public {
        console2.log("--- BEFORE-Trigger Fees ---");
        
        // Query initial buy fee components using tuple destructuring
        (uint256 initialBuyLiquidityFee, 
         uint256 initialBuyMarketingFee,
         uint256 initialBuyRewardFee,
         uint256 initialBuyTaxFee) = token.buyFee();
         
        console2.log("Initial Buy Fees:");
        console2.log("  LiquidityFee: %d", initialBuyLiquidityFee);
        console2.log("  MarketingFee: %d", initialBuyMarketingFee);
        console2.log("  RewardFee: %d", initialBuyRewardFee);
        console2.log("  TaxFee: %d", initialBuyTaxFee);
        
        // Query initial sell fee components using tuple destructuring
        (uint256 initialSellLiquidityFee, 
         uint256 initialSellMarketingFee,
         uint256 initialSellRewardFee,
         uint256 initialSellTaxFee) = token.sellFee();
         
        console2.log("Initial Sell Fees:");
        console2.log("  LiquidityFee: %d", initialSellLiquidityFee);
        console2.log("  MarketingFee: %d", initialSellMarketingFee);
        console2.log("  RewardFee: %d", initialSellRewardFee);
        console2.log("  TaxFee: %d", initialSellTaxFee);

        console2.log("--- Trigger High Fees ---");
        // Owner sets fees to maximum (25 each, 100% total fee)
        vm.prank(owner);
        token.setBuyFee(25, 25, 25, 25);

        vm.prank(owner);
        token.setSellFee(25, 25, 25, 25);

        console2.log("--- AFTER-Trigger Fees ---");
        
        // Query final buy fee components
        (uint256 finalBuyLiquidityFee, 
         uint256 finalBuyMarketingFee,
         uint256 finalBuyRewardFee,
         uint256 finalBuyTaxFee) = token.buyFee();
         
        console2.log("Final Buy Fees:");
        console2.log("  LiquidityFee: %d", finalBuyLiquidityFee);
        console2.log("  MarketingFee: %d", finalBuyMarketingFee);
        console2.log("  RewardFee: %d", finalBuyRewardFee);
        console2.log("  TaxFee: %d", finalBuyTaxFee);
        
        // Query final sell fee components
        (uint256 finalSellLiquidityFee, 
         uint256 finalSellMarketingFee,
         uint256 finalSellRewardFee,
         uint256 finalSellTaxFee) = token.sellFee();
         
        console2.log("Final Sell Fees:");
        console2.log("  LiquidityFee: %d", finalSellLiquidityFee);
        console2.log("  MarketingFee: %d", finalSellMarketingFee);
        console2.log("  RewardFee: %d", finalSellRewardFee);
        console2.log("  TaxFee: %d", finalSellTaxFee);

        // Verify all fee components were set to 25
        bool buyFeeExploited = 
            finalBuyLiquidityFee == 25 &&
            finalBuyMarketingFee == 25 &&
            finalBuyRewardFee == 25 &&
            finalBuyTaxFee == 25;
            
        bool sellFeeExploited =
            finalSellLiquidityFee == 25 &&
            finalSellMarketingFee == 25 &&
            finalSellRewardFee == 25 &&
            finalSellTaxFee == 25;
        
        // Final vulnerability determination
        if (buyFeeExploited && sellFeeExploited) {
            console2.log("\nVULNERABILITY CONFIRMED: Owner set all fees to 25% (100% total)");
            console2.log("Vulnerability Exists: Fee validation missing allowing total fees exceeding limit");
        } else {
            console2.log("\nSAFE IMPLEMENTATION: Fee limits restrict values within acceptable range");
            console2.log("Vulnerability not Exist: Contract prevents setting fees above safety limits");
        }
    }
}