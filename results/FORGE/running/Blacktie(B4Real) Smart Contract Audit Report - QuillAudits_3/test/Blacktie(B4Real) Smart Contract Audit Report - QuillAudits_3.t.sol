// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/B4REAL.sol";

contract B4REALTest is Test {
    B4REAL public token;
    address owner = address(0x1);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new B4REAL();
        vm.stopPrank();
    }

    function test_TaxFeeCanBeSetTo100Percent() public {
        // BEFORE STATE
        uint256 preTaxFee = token.taxFee();
        uint256 preTaxFeeDecimals = token.taxFeeDecimals();
        console.log("--- BEFORE-Trigger TaxFee ---");
        console.log("Pre taxFee:", preTaxFee);
        console.log("Pre taxFeeDecimals:", preTaxFeeDecimals);

        // TRIGGER ACTION
        console.log("--- Trigger: setTaxFee(100, 0) ---");
        vm.startPrank(owner);
        token.setTaxFee(100, 0);
        vm.stopPrank();

        // AFTER STATE
        uint256 postTaxFee = token.taxFee();
        uint256 postTaxFeeDecimals = token.taxFeeDecimals();
        console.log("--- AFTER-Trigger TaxFee ---");
        console.log("Post taxFee:", postTaxFee);
        console.log("Post taxFeeDecimals:", postTaxFeeDecimals);

        // VERDICT
        bool taxFeeChanged = (postTaxFee == 100);
        bool decimalsChanged = (postTaxFeeDecimals == 0);
        bool vulnerabilityExists = taxFeeChanged && decimalsChanged;

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Tax fee successfully set to 100%");
        } else {
            console.log("Vulnerability not Exist: Failed to manipulate tax fee");
        }
    }
}