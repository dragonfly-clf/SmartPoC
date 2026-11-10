// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Milesinu.sol";

contract MilesinuFeeTest is Test {
    Milesinu token;
    address owner = address(0x1);

    function setUp() public {
        // Fork BSC mainnet to access PancakeSwap contract
        vm.createSelectFork("https://bsc-dataseed.binance.org/");
        
        // Deploy as privileged owner account
        vm.startPrank(owner);
        token = new Milesinu();
        vm.stopPrank();
    }

    function testFeeManipulationAboveLimit() public {
        // Reset fees to 0 for consistent baseline
        vm.startPrank(owner);
        token.setTaxFeePercent(0);
        token.setDevFeePercent(0);
        token.setLiquidityFeePercent(0);
        vm.stopPrank();

        // Verify initial state
        assertEq(token.owner(), owner, "Test setup error: Incorrect owner");

        // Log pre-manipulation states
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 preTaxFee = token._taxFee();
        uint256 preDevFee = token._DevFee();
        uint256 preLiquidityFee = token._liquidityFee();
        console.log("Initial _taxFee: %s", preTaxFee);
        console.log("Initial _DevFee: %s", preDevFee);
        console.log("Initial _liquidityFee: %s", preLiquidityFee);

        // Execute vulnerability trigger
        console.log("--- Trigger Set HIGH Fees ---");
        vm.startPrank(owner);
        token.setTaxFeePercent(2600);    // 26%
        token.setDevFeePercent(3000);    // 30%
        token.setLiquidityFeePercent(4000);  // 40%
        vm.stopPrank();

        // Log post-manipulation states
        console.log("--- AFTER-Trigger Fees ---");
        uint256 postTaxFee = token._taxFee();
        uint256 postDevFee = token._DevFee();
        uint256 postLiquidityFee = token._liquidityFee();
        console.log("Post _taxFee: %s", postTaxFee);
        console.log("Post _DevFee: %s", postDevFee);
        console.log("Post _liquidityFee: %s", postLiquidityFee);

        // Differential validation criteria
        bool taxChanged = (postTaxFee != preTaxFee) && (postTaxFee > 2500);
        bool devChanged = (postDevFee != preDevFee) && (postDevFee > 2500);
        bool liqChanged = (postLiquidityFee != preLiquidityFee) && (postLiquidityFee > 2500);
        
        // Final verdict with exactly one output line
        if (taxChanged && devChanged && liqChanged) {
            console.log("Vulnerability Exists: Fee parameters improperly exceeded 25% limit");
        } else {
            console.log("Vulnerability not Exist: Fee changes stayed within safety limits");
        }
    }
}