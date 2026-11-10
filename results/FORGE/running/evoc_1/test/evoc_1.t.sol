// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EvocPlus.sol";

contract EvocPlusFeeTest is Test {
    EvocPlus token;
    uint256 constant MAX_FEE = 25;
    uint256 constant FEE_DENOMINATOR = 100;
    
    function setUp() public {
        // Fork Binance Smart Chain mainnet
        vm.createSelectFork("https://bsc-dataseed.binance.org/");
        
        // Deploy token contract - uses the real router available on the fork
        token = new EvocPlus();
        
        // Configure to avoid affecting test results
        token.setIsFeeExempt(address(this), true);
    }
    
    function test_setFeeDistributionExceedsLimit() public {
        emit log("--- BEFORE-Trigger State ---");
        uint256 totalFee = token.totalFee();
        uint256 liquidityFee = token.liquidityFee();
        uint256 reflectionFee = token.reflectionFee();
        uint256 marketingFee = token.marketingFee();
        uint256 burnFee = token.burnFee();
        uint256 buybackSellFee = token.buybackSellFee();
        emit log_named_uint("    totalFee (before):", totalFee);
        emit log_named_uint("    liquidityFee (before):", liquidityFee);
        emit log_named_uint("    reflectionFee (before):", reflectionFee);
        emit log_named_uint("    marketingFee (before):", marketingFee);
        emit log_named_uint("    burnFee (before):", burnFee);
        emit log_named_uint("    buybackSellFee (before):", buybackSellFee);

        emit log("--- Trigger: setFeeDistribution(6,6,6,6,6) ---");
        token.setFeeDistribution(6,6,6,6,6, FEE_DENOMINATOR);

        emit log("--- AFTER-Trigger State ---");
        uint256 newTotalFee = token.totalFee();
        uint256 newLiquidityFee = token.liquidityFee();
        uint256 newReflectionFee = token.reflectionFee();
        uint256 newMarketingFee = token.marketingFee();
        uint256 newBurnFee = token.burnFee();
        uint256 newBuybackSellFee = token.buybackSellFee();
        emit log_named_uint("    totalFee (after):", newTotalFee);
        emit log_named_uint("    liquidityFee (after):", newLiquidityFee);
        emit log_named_uint("    reflectionFee (after):", newReflectionFee);
        emit log_named_uint("    marketingFee (after):", newMarketingFee);
        emit log_named_uint("    burnFee (after):", newBurnFee);
        emit log_named_uint("    buybackSellFee (after):", newBuybackSellFee);

        // Vulnerability verdict
        if (newTotalFee > MAX_FEE) {
            emit log("Vulnerability Exists: totalFee set above MAX_FEE (25%)");
        } else {
            emit log("Vulnerability not Exist: totalFee within MAX_FEE limits");
        }
    }
    
    function test_setTransferBuyFeeExceedsLimit() public {
        emit log("--- BEFORE-Trigger State ---");
        uint256 totalBuyFee = token.totalBuyFee();
        uint256 totalFee = token.totalFee();
        uint256 liquidityFee = token.liquidityFee();
        emit log_named_uint("    totalBuyFee (before):", totalBuyFee);
        emit log_named_uint("    totalFee (before):", totalFee);
        emit log_named_uint("    liquidityFee (before):", liquidityFee);

        emit log("--- Trigger: setTransferBuyFee(0, 26) ---");
        token.setTransferBuyFee(0, 26);

        emit log("--- AFTER-Trigger State ---");
        uint256 newTotalBuyFee = token.totalBuyFee();
        uint256 newTotalFee = token.totalFee();
        uint256 newLiquidityFee = token.liquidityFee();
        emit log_named_uint("    totalBuyFee (after):", newTotalBuyFee);
        emit log_named_uint("    totalFee (after):", newTotalFee);
        emit log_named_uint("    liquidityFee (after):", newLiquidityFee);

        // Vulnerability verdict
        if (newTotalBuyFee > MAX_FEE) {
            emit log("Vulnerability Exists: totalBuyFee set above MAX_FEE (25%)");
        } else {
            emit log("Vulnerability not Exist: totalBuyFee within MAX_FEE limits");
        }
    }
    
    function test_setFeeSwapExceedsLimit() public {
        emit log("--- BEFORE-Trigger State ---");
        uint256 totalBuyFee = token.totalBuyFee();
        uint256 totalFee = token.totalFee();
        uint256 liquidityFee = token.liquidityFee();
        emit log_named_uint("    totalBuyFee (before):", totalBuyFee);
        emit log_named_uint("    totalFee (before):", totalFee);
        emit log_named_uint("    liquidityFee (before):", liquidityFee);

        emit log("--- Trigger: setFeeSwap(26, 0) ---");
        token.setFeeSwap(26, 0);

        emit log("--- AFTER-Trigger State ---");
        uint256 newTotalBuyFee = token.totalBuyFee();
        uint256 newTotalFee = token.totalFee();
        uint256 newLiquidityFee = token.liquidityFee();
        emit log_named_uint("    totalBuyFee (after):", newTotalBuyFee);
        emit log_named_uint("    totalFee (after):", newTotalFee);
        emit log_named_uint("    liquidityFee (after):", newLiquidityFee);

        // Vulnerability verdict
        if (newTotalBuyFee > MAX_FEE) {
            emit log("Vulnerability Exists: totalBuyFee set above MAX_FEE (25%)");
        } else {
            emit log("Vulnerability not Exist: totalBuyFee within MAX_FEE limits");
        }
    }
}