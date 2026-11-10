// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FootballAI.sol";

contract FootballAITest is Test {
    FootballAI token;
    address constant UNISWAP_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant UNISWAP_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant OWNER = 0x971C47aF6220478Acd788E289B6c71a801f70774;

    function setUp() public {
        // Mock Uniswap Router calls
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(UNISWAP_FACTORY)
        );
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        
        // Mock Uniswap Factory createPair call
        vm.mockCall(
            UNISWAP_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(1234)) // Mock pair address
        );
        
        token = new FootballAI();
    }

    function test_SetLiquidityFeeExceedsLimit() public {
        // Check state before action
        console.log("--- BEFORE-Trigger setLiquidityFeePercent ---");
        uint256 liquidityBefore = token._liquidityFee();
        console.log("Initial Liquidity Fee:", liquidityBefore);
        
        // Trigger vulnerability
        console.log("--- Trigger setLiquidityFeePercent(26) ---");
        vm.prank(OWNER);
        token.setLiquidityFeePercent(26);
        
        // Check state after action
        console.log("--- AFTER-Trigger setLiquidityFeePercent ---");
        uint256 liquidityAfter = token._liquidityFee();
        console.log("Updated Liquidity Fee:", liquidityAfter);
        
        // Verify vulnerability outcome
        if(liquidityAfter == 26) {
            console.log("Vulnerability Exists: Liquidity fee set beyond 25% limit");
        } else {
            console.log("Vulnerability not Exist: Liquidity fee not changed to 26");
        }
    }

    function test_SetTaxFeeExceedsLimit() public {
        // Check state before action
        console.log("--- BEFORE-Trigger setTaxFeePercent ---");
        uint256 taxBefore = token._taxFee();
        console.log("Initial Tax Fee:", taxBefore);
        
        // Trigger vulnerability
        console.log("--- Trigger setTaxFeePercent(26) ---");
        vm.prank(OWNER);
        token.setTaxFeePercent(26);
        
        // Check state after action
        console.log("--- AFTER-Trigger setTaxFeePercent ---");
        uint256 taxAfter = token._taxFee();
        console.log("Updated Tax Fee:", taxAfter);
        
        // Verify vulnerability outcome
        if(taxAfter == 26) {
            console.log("Vulnerability Exists: Tax fee set beyond 25% limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee not changed to 26");
        }
    }

    function test_SetDevelopmentFeeExceedsLimit() public {
        // Check state before action
        console.log("--- BEFORE-Trigger setDevelopmentFeePercent ---");
        uint256 developmentBefore = token._developmentFee();
        console.log("Initial Development Fee:", developmentBefore);
        
        // Trigger vulnerability
        console.log("--- Trigger setDevelopmentFeePercent(26) ---");
        vm.prank(OWNER);
        token.setDevelopmentFeePercent(26);
        
        // Check state after action
        console.log("--- AFTER-Trigger setDevelopmentFeePercent ---");
        uint256 developmentAfter = token._developmentFee();
        console.log("Updated Development Fee:", developmentAfter);
        
        // Verify vulnerability outcome
        if(developmentAfter == 26) {
            console.log("Vulnerability Exists: Development fee set beyond 25% limit");
        } else {
            console.log("Vulnerability not Exist: Development fee not changed to 26");
        }
    }
}