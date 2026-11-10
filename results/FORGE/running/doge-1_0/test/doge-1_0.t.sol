// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGE1.sol";

contract DOGE1ExceedFeeTest is Test {
    DOGE1 token;
    address owner = address(0x1);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new DOGE1();
        vm.stopPrank();
    }

    function testTaxFeeExceedsLimit() public {
        console.log("--- STATE: Initial tax fee value ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial tax fee:", initialTaxFee, "%");
        
        // Test setting taxFee to 26%
        console.log("--- BEFORE-Trigger: Setting taxFee to 26% ---");
        uint256 pre26 = token._taxFee();
        console.log("Pre-setTaxFee(26) tax fee:", pre26, "%");
        
        console.log("--- TRIGGER: Owner calls setTaxFeePercent(26) ---");
        vm.prank(owner);
        token.setTaxFeePercent(26);
        
        console.log("--- AFTER-Trigger: Setting taxFee to 26% ---");
        uint256 post26 = token._taxFee();
        console.log("Post-setTaxFee(26) tax fee:", post26, "%");
        
        // Test setting taxFee to 99%
        console.log("--- BEFORE-Trigger: Setting taxFee to 99% ---");
        uint256 pre99 = token._taxFee();
        console.log("Pre-setTaxFee(99) tax fee:", pre99, "%");
        
        console.log("--- TRIGGER: Owner calls setTaxFeePercent(99) ---");
        vm.prank(owner);
        token.setTaxFeePercent(99);
        
        console.log("--- AFTER-Trigger: Setting taxFee to 99% ---");
        uint256 post99 = token._taxFee();
        console.log("Post-setTaxFee(99) tax fee:", post99, "%");
        
        // Final vulnerability determination
        if (post99 > 25) {
            console.log("Vulnerability Exists: Tax fee set to", post99, "% which exceeds 25% limit");
        } else if (post26 > 25) {
            console.log("Vulnerability Exists: Tax fee set to", post26, "% which exceeds 25% limit");
        } else {
            console.log("Vulnerability not Exist: Maximum tax fee remains at", post99, "% (within limits)");
        }
    }
}