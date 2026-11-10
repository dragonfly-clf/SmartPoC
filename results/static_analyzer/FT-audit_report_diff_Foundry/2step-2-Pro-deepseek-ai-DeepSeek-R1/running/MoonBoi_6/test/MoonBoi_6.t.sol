// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoonBoi.sol";

contract MoonBoiTest is Test {
    MoonBoi token;
    address owner = address(0xA11CE);
    address constant pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant weth = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock PancakeSwap dependencies
        address mockFactory = address(0xFaC7);
        vm.mockCall(
            pancakeRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            pancakeRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(weth)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0xDeaD))
        );

        // Deploy token
        token = new MoonBoi();
        vm.stopPrank();
    }

    function test_OwnerCanSetExorbitantTax() public {
        // Pre-state: record initial tax values
        console.log("--- BEFORE-Trigger Taxes ---");
        (
            , 
            , 
            , 
            uint256 initialBuyTax, 
            uint256 initialSellTax, 
            uint256 initialTransferTax
        ) = token.getTaxes();
        console.log("Initial Buy Tax:     %s", initialBuyTax);
        console.log("Initial Sell Tax:    %s", initialSellTax);
        console.log("Initial Transfer Tax: %s", initialTransferTax);

        console.log("--- Trigger TeamSetTaxes ---");
        // Execute vulnerability trigger - set taxes to 100%
        vm.startPrank(owner);
        token.TeamSetTaxes(
            33,   // burnTaxes (33%)
            33,   // liquidityTaxes (33%)
            34,   // stakingTaxes (34%) - totals 100%
            100,  // buyTax (100%)
            100,  // sellTax (100%)
            100   // transferTax (100%)
        );
        vm.stopPrank();

        // Post-state: record updated tax values
        console.log("--- AFTER-Trigger Taxes ---");
        (
            , 
            , 
            , 
            uint256 afterBuyTax, 
            uint256 afterSellTax, 
            uint256 afterTransferTax
        ) = token.getTaxes();
        console.log("Updated Buy Tax:     %s", afterBuyTax);
        console.log("Updated Sell Tax:    %s", afterSellTax);
        console.log("Updated Transfer Tax: %s", afterTransferTax);

        // Vulnerability determination
        bool isVulnerable = (
            afterBuyTax == 100 && 
            afterSellTax == 100 && 
            afterTransferTax == 100
        );
        
        if (isVulnerable) {
            console.log("Vulnerability Exists: Owner successfully set all taxes to 100%");
        } else {
            console.log("Vulnerability not Exist: Owner failed to set all taxes to 100%");
        }
    }
}