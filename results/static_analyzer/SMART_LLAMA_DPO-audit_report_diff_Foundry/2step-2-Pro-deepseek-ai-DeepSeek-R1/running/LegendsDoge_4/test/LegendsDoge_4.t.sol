// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LegendsDoge.sol";

contract LegendsDogePrivilegeTest is Test {
    LegendsDoge token;
    address owner = address(0x1);
    address charityAccount = address(0x2);
    
    function setUp() public {
        vm.prank(owner);
        token = new LegendsDoge(
            "LegendsDoge",   // _name
            "LEGENDS",       // _symbol
            9,               // _decimals
            100_000_000_000, // _supply 
            1,               // _txFee (1%)
            1,               // _burnFee (1%)
            1,               // _charityFee (1%)
            address(0x0),    // _FeeAddress
            owner            // tokenOwner
        );
    }

    // Test 1: Owner can set any address as charity without restrictions
    function testSetArbitraryCharityAccount() public {
        console.log("--- BEFORE-Trigger Charity ---");
        bool isCharityBefore = token.isCharity(charityAccount);
        console.log("Is charity (before):", isCharityBefore ? "true" : "false");

        console.log("--- Trigger SetAsCharityAccount ---");
        vm.prank(owner);
        token.setAsCharityAccount(charityAccount);

        console.log("--- AFTER-Trigger Charity ---");
        bool isCharityAfter = token.isCharity(charityAccount);
        console.log("Is charity (after):", isCharityAfter ? "true" : "false");

        assertTrue(isCharityAfter, "Arbitrary account became charity");
        console.log("Vulnerability Exists: Charity account updated to arbitrary address");
    }

    // Test 2: Owner can set fees to arbitrarily high values (100% each)
    function testSetArbitraryHighFees() public {
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 taxBefore = token._TAX_FEE();
        uint256 burnBefore = token._BURN_FEE();
        uint256 charityBefore = token._CHARITY_FEE();
        console.log("Fees (before) - Tax:", taxBefore, "Burn:", burnBefore, "Charity:", charityBefore);

        console.log("--- Trigger UpdateFee ---");
        vm.prank(owner);
        token.updateFee(100, 100, 100);

        console.log("--- AFTER-Trigger Fees ---");
        uint256 taxAfter = token._TAX_FEE();
        uint256 burnAfter = token._BURN_FEE();
        uint256 charityAfter = token._CHARITY_FEE();
        console.log("Fees (after) - Tax:", taxAfter, "Burn:", burnAfter, "Charity:", charityAfter);

        if (taxAfter == 100 && burnAfter == 100 && charityAfter == 100) {
            console.log("Vulnerability Exists: Fees updated to 100% without constraints");
        } else {
            console.log("Vulnerability not Exist: Fees not updated to extreme values");
        }
    }
}