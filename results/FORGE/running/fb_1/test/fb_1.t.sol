// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FutuballToken.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xF111111111111111111111111111111111111111);
    }

    function WETH() external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x3333333333333333333333333333333333333333);
    }
}

contract FutuballTokenTest is Test {
    FutuballToken token;
    address owner = address(0x1);
    
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDR = 0xF111111111111111111111111111111111111111;

    function setUp() public {
        // Deploy mock implementations
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Set mock contracts at hardcoded addresses
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        vm.etch(FACTORY_ADDR, address(mockFactory).code);
        
        // Deploy token - will use mocked router/factory
        vm.startPrank(owner);
        token = new FutuballToken();
        vm.stopPrank();
    }

    function test_taxfee_exceeds_limit() public {
        console.log("--- BEFORE-Trigger Tax Fees ---");
        uint256 initialBuyTax = token.buyTaxFee();
        uint256 initialSellTax = token.sellTaxFee();
        console.log("Initial Buy Tax Fee:", initialBuyTax, "%");
        console.log("Initial Sell Tax Fee:", initialSellTax, "%");

        console.log("--- Trigger ChangeTaxFee ---");
        // Owner calls functions to change tax fees
        vm.startPrank(owner);
        token.setTax(26, 26);   // Set beyond 25% limit
        token.setTax(100, 100); // Set to maximum value
        vm.stopPrank();

        console.log("--- AFTER-Trigger Tax Fees ---");
        uint256 newBuyTax = token.buyTaxFee();
        uint256 newSellTax = token.sellTaxFee();
        console.log("New Buy Tax Fee:", newBuyTax, "%");
        console.log("New Sell Tax Fee:", newSellTax, "%");

        // Compare against allowed limit (25%)
        if (newBuyTax > 25 || newSellTax > 25) {
            console.log("Vulnerability Exists: Tax fees exceed allowed limit (25%)");
        } else {
            console.log("Vulnerability not Exist: Tax fees remain within allowed limit");
        }
    }
}