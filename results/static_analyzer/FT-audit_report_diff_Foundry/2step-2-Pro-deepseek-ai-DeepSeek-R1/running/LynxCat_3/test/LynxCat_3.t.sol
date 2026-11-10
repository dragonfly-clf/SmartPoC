// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol"; // Added for formatted logging
import "../src/LynxCat.sol";

contract LynxCatFeeManipulationTest is Test {
    LynxCat token;
    address owner = address(0x1);
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Using valid checksum addresses
    address constant mockFactory = 0x1234567890123456789012345678901234567890;
    address constant mockPair = 0x0987654321098765432109876543210987654321;
    address constant weth = 0x0000000000000000000000000000000000000001;
    uint256 constant MAX_FEE = 100; // 100% fee

    function setUp() public {
        // Start prank as owner
        vm.startPrank(owner);

        // Mock router factory function
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );

        // Mock router WETH function
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(weth)
        );

        // Mock factory createPair function
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token contract
        token = new LynxCat();

        vm.stopPrank();
    }

    function test_FeeManipulationVulnerability() public {
        console2.log("--- BEFORE-Trigger Query Fees ---");
        // Query initial buy fee components
        (uint256 bTaxOld, uint256 bLiqOld, uint256 bMarketOld, uint256 bDevOld, uint256 bBurnOld) = token.buyFee();
        console2.log("Initial buyFee: [Tax=%s, Liq=%s, Market=%s, Dev=%s, Burn=%s]",
            bTaxOld, bLiqOld, bMarketOld, bDevOld, bBurnOld);
        
        // Query initial sell fee components
        (uint256 sTaxOld, uint256 sLiqOld, uint256 sMarketOld, uint256 sDevOld, uint256 sBurnOld) = token.sellFee();
        console2.log("Initial sellFee: [Tax=%s, Liq=%s, Market=%s, Dev=%s, Burn=%s]",
            sTaxOld, sLiqOld, sMarketOld, sDevOld, sBurnOld);

        console2.log("--- Trigger: Fee Manipulation Actions ---");
        // Owner sets extremely high fees (100% for each component)
        vm.prank(owner);
        token.setBothFees(
            100, 100, 100, 100, 100,   // Buy fees each at 100%
            100, 100, 100, 100, 100    // Sell fees each at 100%
        );

        // Set high individual buy fees
        vm.prank(owner);
        token.setBuyFee(100, 100, 100, 100, 100);

        // Set high individual sell fees
        vm.prank(owner);
        token.setSellFee(100, 100, 100, 100, 100);

        console2.log("--- AFTER-Trigger Query Fees ---");
        // Query updated buy fee components
        (uint256 bTaxNew, uint256 bLiqNew, uint256 bMarketNew, uint256 bDevNew, uint256 bBurnNew) = token.buyFee();
        console2.log("Updated buyFee: [Tax=%s, Liq=%s, Market=%s, Dev=%s, Burn=%s]",
            bTaxNew, bLiqNew, bMarketNew, bDevNew, bBurnNew);
        
        // Query updated sell fee components
        (uint256 sTaxNew, uint256 sLiqNew, uint256 sMarketNew, uint256 sDevNew, uint256 sBurnNew) = token.sellFee();
        console2.log("Updated sellFee: [Tax=%s, Liq=%s, Market=%s, Dev=%s, Burn=%s]",
            sTaxNew, sLiqNew, sMarketNew, sDevNew, sBurnNew);

        // Vulnerability verification
        bool buyFeesMax = (bTaxNew == MAX_FEE && bLiqNew == MAX_FEE && 
                          bMarketNew == MAX_FEE && bDevNew == MAX_FEE && 
                          bBurnNew == MAX_FEE);
        
        bool sellFeesMax = (sTaxNew == MAX_FEE && sLiqNew == MAX_FEE &&
                           sMarketNew == MAX_FEE && sDevNew == MAX_FEE &&
                           sBurnNew == MAX_FEE);

        if (buyFeesMax && sellFeesMax) {
            console2.log("Vulnerability Exists: Owner can set fees to 100%");
        } else {
            console2.log("Vulnerability not Exist: Contract prevents excessive fees");
        }
    }
}