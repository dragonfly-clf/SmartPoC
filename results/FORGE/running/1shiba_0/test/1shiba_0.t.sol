// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ONE1SHIBA.sol";

contract ONE1SHIBATest is Test {
    ONE1SHIBA token;
    address owner = address(0x1);
    address constant pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock router.factory() to return address(0xFa1)
        vm.mockCall(
            pancakeRouter,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(address(0xFa1))
        );
        
        // Mock router.WETH() to return address(0xDEAD)
        vm.mockCall(
            pancakeRouter,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(address(0xDEAD))
        );
        
        // Mock factory.createPair() to return address(0x777)
        vm.mockCall(
            address(0xFa1),
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(address(0x777))
        );
        
        // Deploy token as owner
        vm.prank(owner);
        token = new ONE1SHIBA();
    }

    function testTaxFeeManipulation() public {
        uint256 excessiveFee = 100; // 100% fee
        
        console.log("--- BEFORE-Trigger TaxFee ---");
        uint256 taxFeeBefore = token._taxFee();
        console.log("Tax Fee Before:", taxFeeBefore);
        
        console.log("--- Trigger setTaxFeePercent(100) ---");
        vm.prank(owner);
        token.setTaxFeePercent(excessiveFee);
        
        console.log("--- AFTER-Trigger TaxFee ---");
        uint256 taxFeeAfter = token._taxFee();
        console.log("Tax Fee After:", taxFeeAfter);
        
        if (taxFeeBefore != taxFeeAfter) {
            console.log("State changed: Tax Fee modified successfully");
            console.log("Vulnerability Exists: Owner can set tax fee to 100%");
        } else {
            console.log("State unchanged: Tax Fee not modified");
            console.log("Vulnerability not Exist: Failed to set tax fee to 100%");
        }
    }
    
    function testLiquidityFeeManipulation() public {
        uint256 excessiveFee = 100; // 100% fee
        
        console.log("--- BEFORE-Trigger LiquidityFee ---");
        uint256 liquidityFeeBefore = token._liquidityFee();
        console.log("Liquidity Fee Before:", liquidityFeeBefore);
        
        console.log("--- Trigger setLiquidityFeePercent(100) ---");
        vm.prank(owner);
        token.setLiquidityFeePercent(excessiveFee);
        
        console.log("--- AFTER-Trigger LiquidityFee ---");
        uint256 liquidityFeeAfter = token._liquidityFee();
        console.log("Liquidity Fee After:", liquidityFeeAfter);
        
        if (liquidityFeeBefore != liquidityFeeAfter) {
            console.log("State changed: Liquidity Fee modified successfully");
            console.log("Vulnerability Exists: Owner can set liquidity fee to 100%");
        } else {
            console.log("State unchanged: Liquidity Fee not modified");
            console.log("Vulnerability not Exist: Failed to set liquidity fee to 100%");
        }
    }
}