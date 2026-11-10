// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TeaToken.sol";

contract TeaTokenFeeTest is Test {
    TeaToken public token;
    address constant UNISWAP_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0xFaC700);
    address constant MOCK_WETH = address(0xEaEbc);
    address constant MOCK_PAIR = address(0x199191);

    function setUp() public {
        // Mock Uniswap router responses
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair function for any arguments
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(MOCK_PAIR)
        );

        token = new TeaToken();
    }

    function test_setTaxFeeAboveLimit() public {
        // Get initial fees
        console.log("--- BEFORE-Trigger TaxFee ---");
        uint256 preTaxFee = token._taxFee();
        uint256 preLiqFee = token._liquidityFee();
        console.log("Pre-tax fee:", preTaxFee);
        console.log("Pre-liquidity fee:", preLiqFee);

        // Trigger vulnerability
        console.log("--- Trigger setTaxFeePercent(26) ---");
        token.setTaxFeePercent(26);
        
        // Check state after
        console.log("--- AFTER-Trigger TaxFee ---");
        uint256 postTaxFee = token._taxFee();
        uint256 postLiqFee = token._liquidityFee();
        console.log("Post-tax fee:", postTaxFee);
        console.log("Post-liquidity fee:", postLiqFee);
        
        // Vulnerability verdict
        if(postTaxFee == 26) {
            console.log("Vulnerability Exists: tax fee set above 25%% limit");
        } else {
            console.log("Vulnerability not Exist: tax fee remains within limits");
        }
    }
    
    function test_setLiquidityFeeAboveLimit() public {
        // Get initial fees
        console.log("--- BEFORE-Trigger LiqFee ---");
        uint256 preTaxFee = token._taxFee();
        uint256 preLiqFee = token._liquidityFee();
        console.log("Pre-tax fee:", preTaxFee);
        console.log("Pre-liquidity fee:", preLiqFee);

        // Trigger vulnerability
        console.log("--- Trigger setLiquidityFeePercent(26) ---");
        token.setLiquidityFeePercent(26);
        
        // Check state after
        console.log("--- AFTER-Trigger LiqFee ---");
        uint256 postTaxFee = token._taxFee();
        uint256 postLiqFee = token._liquidityFee();
        console.log("Post-tax fee:", postTaxFee);
        console.log("Post-liquidity fee:", postLiqFee);
        
        // Vulnerability verdict
        if(postLiqFee == 26) {
            console.log("Vulnerability Exists: liquidity fee set above 25%% limit");
        } else {
            console.log("Vulnerability not Exist: liquidity fee remains within limits");
        }
    }
    
    function test_OwnerCanSetFeesAboveAllowedLimit() public {
        // Get initial fees
        console.log("--- BEFORE-Trigger AllFees ---");
        uint256 preTaxFee = token._taxFee();
        uint256 preLiqFee = token._liquidityFee();
        console.log("Pre-tax fee:", preTaxFee);
        console.log("Pre-liquidity fee:", preLiqFee);

        // Trigger vulnerability
        console.log("--- Trigger setTaxFeePercent(26) ---");
        token.setTaxFeePercent(26);
        console.log("--- Trigger setLiquidityFeePercent(26) ---");
        token.setLiquidityFeePercent(26);
        
        // Check state after
        console.log("--- AFTER-Trigger AllFees ---");
        uint256 postTaxFee = token._taxFee();
        uint256 postLiqFee = token._liquidityFee();
        console.log("Post-tax fee:", postTaxFee);
        console.log("Post-liquidity fee:", postLiqFee);
        
        // Vulnerability verdict
        if(postTaxFee == 26 && postLiqFee == 26) {
            console.log("Vulnerability Exists: both fees set above 25%% limit");
        } else {
            console.log("Vulnerability not Exist: fees were not both set above limit");
        }
    }
}