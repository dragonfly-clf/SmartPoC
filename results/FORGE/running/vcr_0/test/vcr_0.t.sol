// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/VegasCrypto.sol";

contract VegasCryptoFeeTest is Test {
    VegasCrypto token;
    address owner = address(0x1);
    uint256 public constant MAX_FEE = 10_000; // 100%

    function setUp() public {
        vm.prank(owner);
        token = new VegasCrypto();
    }

    function testReflectionFeeManipulation() public {
        console.log("--- BEFORE-Trigger ReflectionFee ---");
        uint256 preReflectionFee = token._taxFee();
        console.log("Pre-trigger Reflection Fee: %s", preReflectionFee);

        console.log("--- Trigger setReflectionFee ---");
        bool success;
        vm.startPrank(owner);
        try token.setReflectionFee(MAX_FEE) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger ReflectionFee ---");
        uint256 postReflectionFee = token._taxFee();
        console.log("Post-trigger Reflection Fee: %s", postReflectionFee);
        
        if (success && postReflectionFee == MAX_FEE) {
            console.log("Vulnerability Exists: Reflection fee set to 100%%");
        } else if (success) {
            console.log("Vulnerability not Exist: Reflection fee set to %s (not 100%%)", postReflectionFee);
        } else {
            console.log("Vulnerability not Exist: setReflectionFee reverted");
        }
    }

    function testLiquidityFeeManipulation() public {
        console.log("--- BEFORE-Trigger LiquidityFee ---");
        uint256 preLiquidityFee = token._liquidityFee();
        console.log("Pre-trigger Liquidity Fee: %s", preLiquidityFee);

        console.log("--- Trigger setLiquidityFee ---");
        bool success;
        vm.startPrank(owner);
        try token.setLiquidityFee(MAX_FEE) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger LiquidityFee ---");
        uint256 postLiquidityFee = token._liquidityFee();
        console.log("Post-trigger Liquidity Fee: %s", postLiquidityFee);
        
        if (success && postLiquidityFee == MAX_FEE) {
            console.log("Vulnerability Exists: Liquidity fee set to 100%%");
        } else if (success) {
            console.log("Vulnerability not Exist: Liquidity fee set to %s (not 100%%)", postLiquidityFee);
        } else {
            console.log("Vulnerability not Exist: setLiquidityFee reverted");
        }
    }

    function testBurnFeeManipulation() public {
        console.log("--- BEFORE-Trigger BurnFee ---");
        uint256 preBurnFee = token._BurnFee();
        console.log("Pre-trigger Burn Fee: %s", preBurnFee);

        console.log("--- Trigger setBurnPercent ---");
        bool success;
        vm.startPrank(owner);
        try token.setBurnPercent(MAX_FEE) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger BurnFee ---");
        uint256 postBurnFee = token._BurnFee();
        console.log("Post-trigger Burn Fee: %s", postBurnFee);
        
        if (success && postBurnFee == MAX_FEE) {
            console.log("Vulnerability Exists: Burn fee set to 100%%");
        } else if (success) {
            console.log("Vulnerability not Exist: Burn fee set to %s (not 100%%)", postBurnFee);
        } else {
            console.log("Vulnerability not Exist: setBurnPercent reverted");
        }
    }
}