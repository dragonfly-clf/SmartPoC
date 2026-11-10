// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LionsLounge.sol";

contract FeeManipulationTest is Test {
    LionsLounge token;
    address owner = address(0xA);
    
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address factory = address(0xFaC70);
    address pair = address(0xDEAD);

    function setUp() public {
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(IDEXRouter.factory.selector),
            abi.encode(factory)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(IDEXRouter.WETH.selector),
            abi.encode(WBNB)
        );
        vm.mockCall(
            factory,
            abi.encodeWithSelector(IDEXFactory.createPair.selector),
            abi.encode(pair)
        );
        vm.prank(owner);
        token = new LionsLounge();
    }

    // Helper to compute buy fee percentage
    function computeBuyFeePercentage() internal view returns (uint256) {
        return token.buyLiquidityFee() + token.buyDevFee() + 
               token.buyBurnFee() + token.buyStakingFee() + 
               token.buyTreasuryFee();
    }

    // Helper to compute sell fee percentage
    function computeSellFeePercentage() internal view returns (uint256) {
        return token.sellLiquidityFee() + token.sellDevFee() + 
               token.sellBurnFee() + token.sellStakingFee() + 
               token.sellTreasuryFee();
    }

    function testCanSetBuyFeesAboveLimit() public {
        console.log("\n--- [Test: Buy Fees] ---");
        
        // Read & compute initial buy fee percentage
        uint256 initialBuyFeePercent = computeBuyFeePercentage();
        console.log("[BEFORE] Initial buy fee: %s%%", initialBuyFeePercent);

        // Execute critical function
        console.log("[TRIGGER] Calling setBuyFees(6,5,5,5,5,100)");
        vm.startPrank(owner);
        token.setBuyFees(6, 5, 5, 5, 5, 100);
        vm.stopPrank();

        // Read & compute new buy fee percentage
        uint256 newBuyFeePercent = computeBuyFeePercentage();
        console.log("[AFTER] New buy fee: %s%%", newBuyFeePercent);

        // Validate if fee exceeds 25%
        bool feeExceedsLimit = newBuyFeePercent > 25;
        console.log("[VERIFICATION] Fee exceeds 25%% limit: %s", feeExceedsLimit ? "YES" : "NO");

        // Final determination
        if (feeExceedsLimit) {
            console.log("Vulnerability Exists: Buy fee exceeds system limit");
        } else {
            console.log("Vulnerability not Exist: Buy fee control works");
        }
    }

    function testCanSetSellFeesAboveLimit() public {
        console.log("\n--- [Test: Sell Fees] ---");
        
        // Read & compute initial sell fee percentage
        uint256 initialSellFeePercent = computeSellFeePercentage();
        console.log("[BEFORE] Initial sell fee: %s%%", initialSellFeePercent);

        // Execute critical function
        console.log("[TRIGGER] Calling setSellFees(8,7,6,5,4,100)");
        vm.startPrank(owner);
        token.setSellFees(8, 7, 6, 5, 4, 100);
        vm.stopPrank();

        // Read & compute new sell fee percentage
        uint256 newSellFeePercent = computeSellFeePercentage();
        console.log("[AFTER] New sell fee: %s%%", newSellFeePercent);

        // Validate if fee exceeds 25%
        bool feeExceedsLimit = newSellFeePercent > 25;
        console.log("[VERIFICATION] Fee exceeds 25%% limit: %s", feeExceedsLimit ? "YES" : "NO");

        // Final determination
        if (feeExceedsLimit) {
            console.log("Vulnerability Exists: Sell fee exceeds system limit");
        } else {
            console.log("Vulnerability not Exist: Sell fee control works");
        }
    }
}