// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGESQ.sol";

contract DOGESQFeeTest is Test {
    DOGESQ token;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        // Deploy token with the test contract as initial owner
        token = new DOGESQ();
        // Transfer ownership to our designated owner address
        token.transferOwnership(owner);
    }

    function testFeeManipulationAboveLimit() public {
        // Initial state query
        console.log("--- BEFORE-Trigger Fee Setting (Initial State) ---");
        uint256 initialTaxFee = token._taxFee();
        uint256 initialLiqFee = token._liquidityFee();
        uint256 initialMktFee = token._marketingFee();
        uint256 initialBurnFee = token._BurnFee();
        
        console.log("Initial _taxFee:", initialTaxFee);
        console.log("Initial _liquidityFee:", initialLiqFee);
        console.log("Initial _marketingFee:", initialMktFee);
        console.log("Initial _BurnFee:", initialBurnFee);

        // Impersonate contract owner and set all fees to 26%
        console.log("--- Trigger Setting Fees to 26% ---");
        vm.startPrank(owner);
        token.setReflectionFee(26);
        token.setLiquidityFee(26);
        token.setMarketingFee(26);
        token.setBurnPercent(26);
        vm.stopPrank();

        // Post-26% setting state query
        console.log("--- AFTER-Trigger Fees Set to 26% ---");
        uint256 post26TaxFee = token._taxFee();
        uint256 post26LiqFee = token._liquidityFee();
        uint256 post26MktFee = token._marketingFee();
        uint256 post26BurnFee = token._BurnFee();

        console.log("_taxFee after 26%:", post26TaxFee);
        console.log("_liquidityFee after 26%:", post26LiqFee);
        console.log("_marketingFee after 26%:", post26MktFee);
        console.log("_BurnFee after 26%:", post26BurnFee);

        // Set single fee to 100%
        console.log("--- BEFORE-Trigger Extreme Fee Setting ---");
        uint256 pre100TaxFee = token._taxFee();
        console.log("_taxFee before 100%:", pre100TaxFee);

        console.log("--- Trigger Set Reflection Fee to 100% ---");
        vm.prank(owner);
        token.setReflectionFee(100);

        // Post-100% setting state query
        console.log("--- AFTER-Trigger Reflection Fee 100% ---");
        uint256 post100TaxFee = token._taxFee();
        console.log("_taxFee after 100%:", post100TaxFee);

        // Non-owner attempt with pre/post state checks
        console.log("--- BEFORE-Trigger Non-Owner Attempt ---");
        uint256 preNonOwnerTaxFee = token._taxFee();
        console.log("_taxFee before non-owner attempt:", preNonOwnerTaxFee);

        console.log("--- Trigger Non-Owner Fee Set Attempt ---");
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setReflectionFee(10);

        console.log("--- AFTER-Trigger Non-Owner Attempt ---");
        uint256 postNonOwnerTaxFee = token._taxFee();
        console.log("_taxFee after non-owner attempt:", postNonOwnerTaxFee);

        // Vulnerability verification
        bool feesExceededLimits = (post26TaxFee == 26 && 
                                  post26LiqFee == 26 && 
                                  post26MktFee == 26 && 
                                  post26BurnFee == 26);
        
        bool extremeFeeSet = (pre100TaxFee == 26) && (post100TaxFee == 100);

        // Final vulnerability verdict
        if (feesExceededLimits && extremeFeeSet) {
            console.log("Vulnerability Exists: Owner can set fees beyond intended limits");
        } else {
            console.log("Vulnerability not Exist: Fee limits functioning as intended");
        }
    }
}