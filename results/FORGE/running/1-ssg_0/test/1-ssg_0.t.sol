// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperSquidGame.sol";

contract SuperSquidGameTest is Test {
    SuperSquidGame token;
    address owner = address(0xABCD);
    
    // Mock addresses for Uniswap components
    address constant ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockFactory = address(0x111);
    address mockWETH = address(0x222);
    address mockPair = address(0x333);

    function setUp() public {
        // Mock the Uniswap router factory function
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(mockFactory)
        );
        
        // Mock the Uniswap router WETH function
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(mockWETH)
        );
        
        // Mock the Uniswap factory createPair function
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(mockPair)
        );

        // Deploy the contract with mocked dependencies
        vm.startPrank(owner);
        token = new SuperSquidGame(owner);
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        uint256 excessiveFee = 9800; // 98% in basis points
        uint256 newFeePerCategory = excessiveFee / 4; // 2450 basis points (24.5%)

        // BEFORE: Query fee state variables
        console2.log("--- BEFORE-Trigger Fee Variables ---");
        uint256 liquidityFeeBefore = token.sLiquidityFee();
        uint256 marketingFeeBefore = token.sMarketingFee();
        uint256 devFeeBefore = token.sDevFee();
        uint256 jackpotFeeBefore = token.sJackpotFee();
        
        console2.log("BEFORE Liquidity Fee:", liquidityFeeBefore);
        console2.log("BEFORE Marketing Fee:", marketingFeeBefore);
        console2.log("BEFORE Dev Fee:", devFeeBefore);
        console2.log("BEFORE Jackpot Fee:", jackpotFeeBefore);

        console2.log("--- Trigger: setSellFees(2450,2450,2450,2450) ---");
        // Owner sets fees totaling 98% by splitting equally
        vm.prank(owner);
        token.setSellFees(
            newFeePerCategory,   // 24.5%
            newFeePerCategory,   // 24.5%
            newFeePerCategory,   // 24.5%
            newFeePerCategory    // 24.5%
        ); // Total = 98% 

        // AFTER: Query fee state variables
        console2.log("--- AFTER-Trigger Fee Variables ---");
        uint256 liquidityFeeAfter = token.sLiquidityFee();
        uint256 marketingFeeAfter = token.sMarketingFee();
        uint256 devFeeAfter = token.sDevFee();
        uint256 jackpotFeeAfter = token.sJackpotFee();
        
        console2.log("AFTER Liquidity Fee:", liquidityFeeAfter);
        console2.log("AFTER Marketing Fee:", marketingFeeAfter);
        console2.log("AFTER Dev Fee:", devFeeAfter);
        console2.log("AFTER Jackpot Fee:", jackpotFeeAfter);

        // Differential verification
        console2.log("--- Differential Verification ---");
        bool liquidityChanged = liquidityFeeAfter != liquidityFeeBefore;
        bool marketingChanged = marketingFeeAfter != marketingFeeBefore;
        bool devChanged = devFeeAfter != devFeeBefore;
        bool jackpotChanged = jackpotFeeAfter != jackpotFeeBefore;
        
        console2.log("Liquidity Fee Changed:", liquidityChanged ? "YES" : "NO");
        console2.log("Marketing Fee Changed:", marketingChanged ? "YES" : "NO");
        console2.log("Dev Fee Changed:", devChanged ? "YES" : "NO");
        console2.log("Jackpot Fee Changed:", jackpotChanged ? "YES" : "NO");

        // Final vulnerability check
        bool vulnerabilityExists = liquidityFeeAfter == newFeePerCategory &&
                                   marketingFeeAfter == newFeePerCategory &&
                                   devFeeAfter == newFeePerCategory &&
                                   jackpotFeeAfter == newFeePerCategory;

        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Fees successfully manipulated to 24.5%% each (98%% total)");
        } else {
            console2.log("Vulnerability not Exist: Fee manipulation failed");
        }
    }
}