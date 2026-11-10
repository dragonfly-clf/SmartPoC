// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/xenoX.sol";

contract XenoXFeesTest is Test {
    xenoX token;
    address owner = vm.addr(1);
    address constant PANCAKE_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Mock PancakeSwap router and factory calls
        address mockFactory = address(0x123456);
        address mockWETH = address(0xdead);
        address mockPair = address(0xabcd);
        
        // Mock router factory() and WETH() calls
        vm.mockCall(
            PANCAKE_ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            PANCAKE_ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token with owner
        vm.startPrank(owner);
        token = new xenoX();
        vm.stopPrank();
    }

    function test_SetIndividualFeesAbove25Percent() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        uint256 initialBuyFee = token.getBuyFee();
        console.log("Initial Buy Fee (%%):", initialBuyFee);

        console.log("--- Trigger SetIndividualFeesAbove25Percent ---");
        // Set a fee component to 26% (above 25%)
        vm.prank(owner);
        token.setBuyTaxFeePercent(26);
        
        // Set another fee component to 26%
        vm.prank(owner);
        token.setBuyLiquidityFeePercent(26);
        
        // Set dev fee to 26%
        vm.prank(owner);
        token.setBuydevFeePercent(26);

        console.log("--- AFTER-Trigger Fee State ---");
        uint256 finalBuyFee = token.getBuyFee();
        console.log("Final Buy Fee (%%):", finalBuyFee);

        bool feeExceeded = finalBuyFee > 25;
        console.log("Fee check:", feeExceeded 
            ? "SUCCESS >25%, Vulnerability Exists" 
            : "FAILED <=25%, Vulnerability not Exist"
        );

        // Final verdict
        if(feeExceeded) {
            console.log("Vulnerability Exists: Buy fee successfully set above 25%%");
        } else {
            console.log("Vulnerability not Exist: Buy fee capped at/below 25%%");
        }
    }

    function test_SetCombinedFeesAbove25Percent() public {
        console.log("--- BEFORE-Trigger Fee States ---");
        uint256 initialBuyFee = token.getBuyFee();
        uint256 initialSellFee = token.getSellFee();
        console.log("Initial Buy Fee (%%):", initialBuyFee);
        console.log("Initial Sell Fee (%%):", initialSellFee);

        console.log("--- Trigger SetCombinedFeesAbove25Percent ---");
        // Set fees to 10% each for total 30%
        vm.startPrank(owner);
        token.setBuyTaxFeePercent(10);
        token.setBuyLiquidityFeePercent(10);
        token.setBuydevFeePercent(10);
        vm.stopPrank();
        
        // Also test sell fees
        vm.startPrank(owner);
        token.setSellTaxFeePercent(10);
        token.setSellLiquidityFeePercent(10);
        token.setSelldevFeePercent(10);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee States ---");
        uint256 finalBuyFee = token.getBuyFee();
        uint256 finalSellFee = token.getSellFee();
        console.log("Final Buy Fee (%%):", finalBuyFee);
        console.log("Final Sell Fee (%%):", finalSellFee);

        bool buyFeeExceeded = finalBuyFee > 25;
        bool sellFeeExceeded = finalSellFee > 25;
        bool vulnerabilityExists = buyFeeExceeded || sellFeeExceeded;

        console.log("Buy fee check:", buyFeeExceeded ? ">25%)" : "<=25%");
        console.log("Sell fee check:", sellFeeExceeded ? ">25%)" : "<=25%");
        console.log("Vulnerability condition:", vulnerabilityExists
            ? "Fees exceeded -> Exists" 
            : "Within limits -> not Exist"
        );

        // Final verdict
        if(vulnerabilityExists) {
            console.log("Vulnerability Exists: Combined buy/sell fees set above 25%%");
        } else {
            console.log("Vulnerability not Exist: Fees capped at/below 25%%");
        }
    }

    function test_SellFeesAbove25Percent() public {
        console.log("--- BEFORE-Trigger Fee State ---");
        uint256 initialSellFee = token.getSellFee();
        console.log("Initial Sell Fee (%%):", initialSellFee);

        console.log("--- Trigger SellFeesAbove25Percent ---");
        // Set sell fee components to 26% each
        vm.startPrank(owner);
        token.setSellTaxFeePercent(26);
        token.setSellLiquidityFeePercent(26);
        token.setSelldevFeePercent(26);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fee State ---");
        uint256 finalSellFee = token.getSellFee();
        console.log("Final Sell Fee (%%):", finalSellFee);

        bool feeExceeded = finalSellFee > 25;
        console.log("Fee check:", feeExceeded 
            ? "SUCCESS >25%, Vulnerability Exists" 
            : "FAILED <=25%, Vulnerability not Exist"
        );

        // Final verdict
        if(feeExceeded) {
            console.log("Vulnerability Exists: Sell fee successfully set above 25%%");
        } else {
            console.log("Vulnerability not Exist: Sell fee capped at/below 25%%");
        }
    }
}