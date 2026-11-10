// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BullsRunToken.sol";

contract BullsRunExceedFeeLimitTest is Test {
    BullsRunToken token;
    address owner = address(1);
    
    function setUp() public {
        // Setup mocks for external dependencies
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x123456);
        address mockPair = address(0x654321);
        
        // Mock router factory call
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSignature("factory()"), 
            abi.encode(mockFactory)
        );
        
        // Mock createPair function
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"), 
            abi.encode(mockPair)
        );
        
        // Deploy token as owner
        vm.startPrank(owner);
        token = new BullsRunToken();
        vm.stopPrank();
    }

    function testFeeExceeds25Percent() public {
        console.log("--- BEFORE setFees ---");
        // Record initial fee parameters
        uint256 liquidityFeeBefore = token.liquidityFee();
        uint256 reflectionFeeBefore = token.reflectionFee();
        uint256 marketingFeeBefore = token.marketingFee();
        uint256 feeDenominatorBefore = token.feeDenominator();
        uint256 devFeeBefore = token.devFee();

        // Log initial state
        console.log("Liquidity Fee:", liquidityFeeBefore);
        console.log("Reflection Fee:", reflectionFeeBefore);
        console.log("Marketing Fee:", marketingFeeBefore);
        console.log("Dev Fee:", devFeeBefore);
        console.log("Fee Denominator:", feeDenominatorBefore);
        
        // Calculate initial total fee percentage including DevFee
        uint256 totalFeeBefore = liquidityFeeBefore + reflectionFeeBefore + marketingFeeBefore + devFeeBefore;
        uint256 totalFeePercentBefore = totalFeeBefore * 100 / feeDenominatorBefore;
        console.log("Total Fee Percentage:", totalFeePercentBefore, "%");

        // Trigger fee change
        console.log("--- TRIGGER setFees(10,10,10,100) ---");
        vm.startPrank(owner);
        token.setFees(10, 10, 10, 100);
        vm.stopPrank();

        console.log("--- AFTER setFees ---");
        // Record post-attack parameters
        uint256 liquidityFeeAfter = token.liquidityFee();
        uint256 reflectionFeeAfter = token.reflectionFee();
        uint256 marketingFeeAfter = token.marketingFee();
        uint256 feeDenominatorAfter = token.feeDenominator();
        uint256 devFeeAfter = token.devFee();
        uint256 totalFeeAfter = liquidityFeeAfter + reflectionFeeAfter + marketingFeeAfter + devFeeAfter;

        // Log new state
        console.log("Liquidity Fee:", liquidityFeeAfter);
        console.log("Reflection Fee:", reflectionFeeAfter);
        console.log("Marketing Fee:", marketingFeeAfter);
        console.log("Dev Fee:", devFeeAfter);
        console.log("Fee Denominator:", feeDenominatorAfter);

        // Calculate new total fee percentage including DevFee
        uint256 totalFeePercentAfter = totalFeeAfter * 100 / feeDenominatorAfter;
        console.log("Total Fee Percentage:", totalFeePercentAfter, "%");

        // Verify vulnerability
        console.log("--- VERIFICATION ---");
        bool feesExceedLimit = totalFeePercentAfter > 25;
        console.log("Fees exceed 25% limit:", feesExceedLimit ? "YES" : "NO");
        console.log(feesExceedLimit 
            ? "Vulnerability Exists: Owner can set fees above 25%" 
            : "Vulnerability not Exist: Fees are within 25% limit");
    }

    function testSellMultiplierExceedsLimit() public {
        console.log("--- BEFORE set_sell_multiplier ---");
        // Record initial multiplier
        uint256 sellMultiplierBefore = token.sellMultiplier();
        console.log("Initial Sell Multiplier:", sellMultiplierBefore);

        // Trigger multiplier change
        console.log("--- TRIGGER set_sell_multiplier(1000) ---");
        vm.startPrank(owner);
        token.set_sell_multiplier(1000);
        vm.stopPrank();

        console.log("--- AFTER set_sell_multiplier ---");
        // Record post-attack multiplier
        uint256 sellMultiplierAfter = token.sellMultiplier();
        console.log("Updated Sell Multiplier:", sellMultiplierAfter);

        // Verify vulnerability
        console.log("--- VERIFICATION ---");
        bool multiplierChanged = sellMultiplierAfter == 1000;
        bool exceedsRecommended = sellMultiplierAfter > 1;
        console.log("Multiplier set to 1000:", multiplierChanged ? "YES" : "NO");
        console.log("Exceeds recommended 1x multiplier:", exceedsRecommended ? "YES" : "NO");
        console.log(multiplierChanged 
            ? "Vulnerability Exists: Owner can set arbitrary sell multiplier" 
            : "Vulnerability not Exist: Sell multiplier unchanged");
    }
}