// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract WizardPayFeeManipulationTest is Test {
    WizardPay token;
    address owner;
    uint256 constant EXCESSIVE_FEE = 11; // >10% limit
    
    function setUp() public {
        owner = address(this);
        token = new WizardPay();
        token.transferOwnership(owner); // Ensure test contract is owner
    }

    function test_setFeesAboveLimit() public {
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 liquidityFeeBefore = token._LiquidityFee();
        uint256 marketingFeeBefore = token._smarketingFee();
        uint256 burningFeeBefore = token._burningFee();
        uint256 buybackFeeBefore = token._buybackv1Fee();
        
        console.log("Tax Fee Before:", taxFeeBefore);
        console.log("Liquidity Fee Before:", liquidityFeeBefore);
        console.log("Marketing Fee Before:", marketingFeeBefore);
        console.log("Burning Fee Before:", burningFeeBefore);
        console.log("BuyBack Fee Before:", buybackFeeBefore);

        console.log("--- Trigger SetFeesAboveLimit ---");
        vm.startPrank(owner);
        token.setTaxFee(EXCESSIVE_FEE);
        token.setLiquidityFee(EXCESSIVE_FEE);
        token.setSMarketingFee(EXCESSIVE_FEE);
        token.setBurningFee(EXCESSIVE_FEE);
        token.setBuyBackv1Fee(EXCESSIVE_FEE);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fees ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 liquidityFeeAfter = token._LiquidityFee();
        uint256 marketingFeeAfter = token._smarketingFee();
        uint256 burningFeeAfter = token._burningFee();
        uint256 buybackFeeAfter = token._buybackv1Fee();
        
        console.log("Tax Fee After:", taxFeeAfter);
        console.log("Liquidity Fee After:", liquidityFeeAfter);
        console.log("Marketing Fee After:", marketingFeeAfter);
        console.log("Burning Fee After:", burningFeeAfter);
        console.log("BuyBack Fee After:", buybackFeeAfter);

        // Vulnerability verification: Detect if ANY fee exceeded 10% limit
        bool vulnerabilityExists = (taxFeeAfter == EXCESSIVE_FEE) ||
                                   (liquidityFeeAfter == EXCESSIVE_FEE) ||
                                   (marketingFeeAfter == EXCESSIVE_FEE) ||
                                   (burningFeeAfter == EXCESSIVE_FEE) ||
                                   (buybackFeeAfter == EXCESSIVE_FEE);
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: At least one fee exceeded 10% limit");
        } else {
            console.log("Vulnerability not Exist: All fees remain below 11% threshold");
        }
    }
}