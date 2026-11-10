// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/VegasCrypto.sol";

contract VegasCryptoTest is Test {
    VegasCrypto token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new VegasCrypto();
        token.afterPreSale(); // Set fees to 10% total (200+300+500 basis points)
        
        // Transfer initial tokens to Alice (owner excluded from fees)
        uint256 transferAmount = token.totalSupply() / 10;
        token.transfer(alice, transferAmount);
        vm.stopPrank();
    }

    function testFeeParametersUpdatedAfterPreSale() public {
        uint256 amount = 1000 * (10 ** token.decimals());
        uint256 expectedTaxFee = amount * 500 / 10000;      // 5%
        uint256 expectedBurnFee = amount * 200 / 10000;     // 2%
        uint256 expectedLiquidityFee = amount * 300 / 10000;// 3%

        console.log("--- BEFORE-Trigger Fees ---");
        uint256 taxBefore = token._taxFeeTotal();
        uint256 burnBefore = token._BurnFeeTotal();
        uint256 liquidityBefore = token._liquidityFeeTotal();
        console.log("Tax fee accumulation (before):", taxBefore);
        console.log("Burn fee accumulation (before):", burnBefore);
        console.log("Liquidity fee accumulation (before):", liquidityBefore);
        
        console.log("--- Trigger Transfer ---");
        vm.prank(alice);
        token.transfer(bob, amount);
        
        console.log("--- AFTER-Trigger Fees ---");
        uint256 taxAfter = token._taxFeeTotal();
        uint256 burnAfter = token._BurnFeeTotal();
        uint256 liquidityAfter = token._liquidityFeeTotal();
        console.log("Tax fee accumulation (after):", taxAfter);
        console.log("Burn fee accumulation (after):", burnAfter);
        console.log("Liquidity fee accumulation (after):", liquidityAfter);
        
        // Compute delta between before/after measurements
        uint256 taxDelta = taxAfter - taxBefore;
        uint256 burnDelta = burnAfter - burnBefore;
        uint256 liquidityDelta = liquidityAfter - liquidityBefore;
        console.log("Tax fee collected (diff):", taxDelta);
        console.log("Burn fee collected (diff):", burnDelta);
        console.log("Liquidity fee collected (diff):", liquidityDelta);
        
        // Compare collected fees with expected amounts
        bool isVulnerable = (taxDelta != expectedTaxFee) ||
                            (burnDelta != expectedBurnFee) ||
                            (liquidityDelta != expectedLiquidityFee);
                            
        if (isVulnerable) {
            console.log("Vulnerability Exists: Collected fees do not match expected values");
        } else {
            console.log("Vulnerability not Exist: Fee collection matches expected parameters");
        }
    }
}