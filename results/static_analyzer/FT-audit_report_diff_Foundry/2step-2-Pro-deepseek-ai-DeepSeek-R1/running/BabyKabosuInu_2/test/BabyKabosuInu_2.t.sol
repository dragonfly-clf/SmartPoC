// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/BabyKabosuInu.sol";

contract BabyKabosuInuFeeTest is Test {
    BabyKabosuInu public token;
    address public owner = address(0x1);

    function setUp() public {
        // Setup mock router and factory addresses
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address factoryAddress = address(0x1234567890123456789012345678901234567890);
        address wethAddress = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address pairAddress = address(0x456);

        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddress)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(wethAddress)
        );
        vm.mockCall(
            factoryAddress,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddress)
        );

        vm.startPrank(owner);
        token = new BabyKabosuInu();
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        // Record initial fee states
        console2.log("--- BEFORE-Trigger Fees State ---");
        uint256 initBuyEcosystem = token._ecosystemFee();
        uint256 initBuyMarketing = token._marketingFee();
        uint256 initBuyReward = token._rewardFee();
        uint256 initBuyLiquidity = token._liquidityFee();
        uint256 initBuyTax = token._taxFee();
        console2.log("Initial Buy Ecosystem Fee:", initBuyEcosystem);
        console2.log("Initial Buy Marketing Fee:", initBuyMarketing);
        console2.log("Initial Buy Reward Fee:", initBuyReward);
        console2.log("Initial Buy Liquidity Fee:", initBuyLiquidity);
        console2.log("Initial Buy Tax Fee:", initBuyTax);

        uint256 initSellEcosystem = token._SellecosystemFee();
        uint256 initSellMarketing = token._SellmarketingFee();
        uint256 initSellReward = token._SellrewardFee();
        uint256 initSellLiquidity = token._SelllLiquidityFee();
        uint256 initSellTax = token._SelltaxFee();
        console2.log("Initial Sell Ecosystem Fee:", initSellEcosystem);
        console2.log("Initial Sell Marketing Fee:", initSellMarketing);
        console2.log("Initial Sell Reward Fee:", initSellReward);
        console2.log("Initial Sell Liquidity Fee:", initSellLiquidity);
        console2.log("Initial Sell Tax Fee:", initSellTax);
        
        // Set trigger values (520 = 5.2%)
        uint256 feeValue = 520;
        console2.log("--- Trigger: setBuyFee/setSellFee with 520 (5.2% each) ---");
        
        // Change fees
        vm.prank(owner);
        token.setBuyFee(feeValue, feeValue, feeValue, feeValue, feeValue);
        vm.prank(owner);
        token.setSellFee(feeValue, feeValue, feeValue, feeValue, feeValue);

        // Capture final state
        console2.log("--- AFTER-Trigger Fees State ---");
        uint256 finalBuyEcosystem = token._ecosystemFee();
        uint256 finalBuyMarketing = token._marketingFee();
        uint256 finalBuyReward = token._rewardFee();
        uint256 finalBuyLiquidity = token._liquidityFee();
        uint256 finalBuyTax = token._taxFee();
        console2.log("Final Buy Ecosystem Fee:", finalBuyEcosystem);
        console2.log("Final Buy Marketing Fee:", finalBuyMarketing);
        console2.log("Final Buy Reward Fee:", finalBuyReward);
        console2.log("Final Buy Liquidity Fee:", finalBuyLiquidity);
        console2.log("Final Buy Tax Fee:", finalBuyTax);
        
        uint256 finalSellEcosystem = token._SellecosystemFee();
        uint256 finalSellMarketing = token._SellmarketingFee();
        uint256 finalSellReward = token._SellrewardFee();
        uint256 finalSellLiquidity = token._SelllLiquidityFee();
        uint256 finalSellTax = token._SelltaxFee();
        console2.log("Final Sell Ecosystem Fee:", finalSellEcosystem);
        console2.log("Final Sell Marketing Fee:", finalSellMarketing);
        console2.log("Final Sell Reward Fee:", finalSellReward);
        console2.log("Final Sell Liquidity Fee:", finalSellLiquidity);
        console2.log("Final Sell Tax Fee:", finalSellTax);

        // Verify vulnerability
        bool vulnerabilityExists = true;
        
        // Validate buy fees changed to 520
        vulnerabilityExists = vulnerabilityExists &&
            (finalBuyEcosystem == feeValue) &&
            (finalBuyMarketing == feeValue) &&
            (finalBuyReward == feeValue) &&
            (finalBuyLiquidity == feeValue) &&
            (finalBuyTax == feeValue);
            
        // Validate sell fees changed to 520
        vulnerabilityExists = vulnerabilityExists &&
            (finalSellEcosystem == feeValue) &&
            (finalSellMarketing == feeValue) &&
            (finalSellReward == feeValue) &&
            (finalSellLiquidity == feeValue) &&
            (finalSellTax == feeValue);
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Fees successfully set above 25% limit (26% total)");
        } else {
            console2.log("Vulnerability not Exist: Fee values unchanged or not set to 520");
        }
    }
}