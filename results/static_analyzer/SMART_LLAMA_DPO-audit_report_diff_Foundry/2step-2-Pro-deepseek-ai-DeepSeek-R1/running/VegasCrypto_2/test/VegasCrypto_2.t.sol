// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/VegasCrypto.sol";

contract VegasCryptoTest is Test {
    VegasCrypto public token;
    address owner = address(0x123);
    address liquidityAddress1 = address(0x456);
    address liquidityAddress2 = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        token = new VegasCrypto();
        vm.stopPrank();
    }

    // Test that liquidity address can be set to same value multiple times
    function test_DuplicateLiquidityAddress() public {
        console.log("--- BEFORE setting liquidity addresses ---");
        address initialAddress = token.liquidityAddress();
        console.log("Initial liquidity address: ", initialAddress);
        
        console.log("--- TRIGGER: Setting addresses (with duplicate) ---");
        vm.startPrank(owner);
        token.setLiquidityAddress(liquidityAddress1);
        token.setLiquidityAddress(liquidityAddress2);
        token.setLiquidityAddress(liquidityAddress1); // Should be allowed but problematic per audit
        vm.stopPrank();
        
        console.log("--- AFTER setting liquidity addresses ---");
        address finalAddress = token.liquidityAddress();
        console.log("Final liquidity address: ", finalAddress);
        
        bool vulnerabilityExists = (finalAddress == liquidityAddress1);
        if (vulnerabilityExists) {
            console.log("Vulnerability exists: Duplicate address settings allowed");
        } else {
            console.log("Vulnerability not exist: Liquidity address not set to expected");
        }
    }

    // Test that fees can be arbitrarily reset multiple times
    function test_ArbitraryFeeReset() public {
        console.log("--- BEFORE resetting fees ---");
        uint256 initialBurnFee = token._BurnFee();
        uint256 initialLiquidityFee = token._liquidityFee();
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial fees - Burn: %d, Liq: %d, Tax: %d", 
            initialBurnFee, initialLiquidityFee, initialTaxFee);
        
        console.log("--- TRIGGER: Resetting fees repeatedly ---");
        vm.startPrank(owner);
        token.afterPreSale();
        token.afterPreSale(); // Resetting fees multiple times
        vm.stopPrank();
        
        console.log("--- AFTER resetting fees ---");
        uint256 finalBurnFee = token._BurnFee();
        uint256 finalLiquidityFee = token._liquidityFee();
        uint256 finalTaxFee = token._taxFee();
        console.log("Final fees - Burn: %d, Liq: %d, Tax: %d", 
            finalBurnFee, finalLiquidityFee, finalTaxFee);
        
        bool isResetValid = (finalBurnFee == 0 && 
                             finalLiquidityFee == 3 && 
                             finalTaxFee == 0);
        
        if (isResetValid) {
            console.log("Vulnerability exists: Fees arbitrarily reset");
        } else {
            console.log("Vulnerability not exist: Fees not set to target values");
        }
    }
}