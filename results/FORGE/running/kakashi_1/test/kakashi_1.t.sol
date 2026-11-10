// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Kakashi.sol";

contract KakashiFeeTest is Test {
    Kakashi token;
    address constant REAL_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant mockFactory = address(0x123);
    address constant mockWETH = address(0x456);
    address constant mockPair = address(0x789);
    bool vulnerabilityExists = false;

    function setUp() public {
        // Create minimal contract at router address
        vm.etch(REAL_ROUTER, hex"600080600080f3");
        
        // Mock factory call
        vm.mockCall(
            REAL_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock WETH call
        vm.mockCall(
            REAL_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token contract
        token = new Kakashi();
    }

    function test_FeeManipulation_ExceedsLimit() public {
        // First fee set: 30%
        console.log("--- BEFORE Setting to 30% ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 liqFeeBefore = token._liquidityFee();
        uint256 fundFeeBefore = token._fundFee();
        console.log("Tax Fee Before:", taxFeeBefore);
        console.log("Liquidity Fee Before:", liqFeeBefore);
        console.log("Fund Fee Before:", fundFeeBefore);

        console.log("--- Trigger: Setting fees to 30%");
        token.setTaxFeePercent(30);
        token.setLiquidityFeePercent(30);
        token.setFundFeePercent(30);

        console.log("--- AFTER Setting to 30% ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 liqFeeAfter = token._liquidityFee();
        uint256 fundFeeAfter = token._fundFee();
        console.log("Tax Fee After:", taxFeeAfter);
        console.log("Liquidity Fee After:", liqFeeAfter);
        console.log("Fund Fee After:", fundFeeAfter);

        // Verify state changes for 30% set
        bool set30Result = (
            taxFeeAfter > 25 || 
            liqFeeAfter > 25 || 
            fundFeeAfter > 25
        );
        vulnerabilityExists = vulnerabilityExists || set30Result;

        // Second fee set: 50%
        console.log("\n--- BEFORE Setting to 50% ---");
        uint256 taxFeeBefore50 = token._taxFee();
        uint256 liqFeeBefore50 = token._liquidityFee();
        uint256 fundFeeBefore50 = token._fundFee();
        console.log("Tax Fee Before:", taxFeeBefore50);
        console.log("Liquidity Fee Before:", liqFeeBefore50);
        console.log("Fund Fee Before:", fundFeeBefore50);

        console.log("--- Trigger: Setting fees to 50%");
        token.setTaxFeePercent(50);
        token.setLiquidityFeePercent(50);
        token.setFundFeePercent(50);

        console.log("--- AFTER Setting to 50% ---");
        uint256 taxFeeAfter50 = token._taxFee();
        uint256 liqFeeAfter50 = token._liquidityFee();
        uint256 fundFeeAfter50 = token._fundFee();
        console.log("Tax Fee After:", taxFeeAfter50);
        console.log("Liquidity Fee After:", liqFeeAfter50);
        console.log("Fund Fee After:", fundFeeAfter50);

        // Verify state changes for 50% set
        bool set50Result = (
            taxFeeAfter50 > 25 || 
            liqFeeAfter50 > 25 || 
            fundFeeAfter50 > 25
        );
        vulnerabilityExists = vulnerabilityExists || set50Result;

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("\nVulnerability Exists: Fees were successfully modified beyond 25%% limit");
        } else {
            console.log("\nVulnerability not Exist: Fees were not modified beyond 25%% limit");
        }
    }
}