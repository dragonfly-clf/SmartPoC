// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SafeWolf.sol";

contract SafeWolfTest is Test {
    SafeWolf token;
    address owner = address(0x1234);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new SafeWolf();
        vm.stopPrank();
    }

    function testTaxFeeExceedsLimit() public {
        // Set tax fee to 30% which exceeds allowed 25% limit
        uint256 excessiveFee = 30;
        
        console.log("--- BEFORE-Trigger TaxFee ---");
        uint256 initialTaxFee = token._getTaxFee();
        console.log("Initial Tax Fee:", initialTaxFee);
        
        console.log("--- Trigger SetTaxFee (excessive fee to 30%) ---");
        // Verify owner can set excess fee
        vm.prank(owner);
        token._setTaxFee(excessiveFee);
        
        console.log("--- AFTER-Trigger TaxFee ---");
        uint256 currentTaxFee = token._getTaxFee();
        console.log("Current Tax Fee:", currentTaxFee);
        
        // Differential check: compare before/after tax fee values
        bool feeChanged = currentTaxFee != initialTaxFee;
        bool feeExceedsLimit = currentTaxFee > 25;
        bool vulnerabilityExists = feeChanged && feeExceedsLimit && currentTaxFee == excessiveFee;
        
        console.log("Differential Check Results:");
        console.log("Tax fee changed (pre vs post):", feeChanged);
        console.log("Tax fee exceeds 25%% limit:", feeExceedsLimit);
        console.log("Tax fee equals attack value (30%):", currentTaxFee == excessiveFee);
        
        // Print final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can set tax fee beyond the allowed limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee not modified beyond limit or update failed");
        }
        
        // Assertion to trigger test success/failure
        assertTrue(vulnerabilityExists, "Tax fee not set beyond limit");
    }
}