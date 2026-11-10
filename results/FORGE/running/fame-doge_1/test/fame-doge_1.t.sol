// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Fame.sol";

contract FameTest is Test {
    Fame token;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDR = 0x000000000000000000000000000000000000bEEF;
    address constant WETH_ADDR = 0x000000000000000000000000000000000000dEaD;
    
    address owner;

    function setUp() public {
        // Deploy and set up mocks
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter();
        
        // Apply mock contracts to fixed addresses
        vm.etch(FACTORY_ADDR, address(mockFactory).code);
        vm.etch(ROUTER, address(mockRouter).code);

        // Create token instance
        token = new Fame();
        owner = token.owner();
    }

    function testFeeManipulation() public {
        console.log("--- BEFORE-Trigger setSelTaxes ---");
        // Query current fees
        uint256 liquidityFeeBefore = token._sellLiquidityFee();
        uint256 marketingFeeBefore = token._sellMarketingFee();
        uint256 teamFeeBefore = token._sellTeamFee();
        uint256 totalTaxBefore = token._totalTaxIfSelling();

        console.log("Initial Liquidity Fee:", liquidityFeeBefore);
        console.log("Initial Marketing Fee:", marketingFeeBefore);
        console.log("Initial Team Fee:", teamFeeBefore);
        console.log("Initial Total Tax on Selling:", totalTaxBefore);

        console.log("--- Trigger setSelTaxes ---");
        // Switch to owner
        vm.prank(owner);
        token.setSelTaxes(10, 10, 10);

        console.log("--- AFTER-Trigger setSelTaxes ---");
        uint256 liquidityFeeAfter = token._sellLiquidityFee();
        uint256 marketingFeeAfter = token._sellMarketingFee();
        uint256 teamFeeAfter = token._sellTeamFee();
        uint256 totalTaxAfter = token._totalTaxIfSelling();

        console.log("Updated Liquidity Fee:", liquidityFeeAfter);
        console.log("Updated Marketing Fee:", marketingFeeAfter);
        console.log("Updated Team Fee:", teamFeeAfter);
        console.log("Updated Total Tax on Selling:", totalTaxAfter);

        // Check if fees were successfully manipulated
        bool vulnerabilityExists = liquidityFeeAfter == 10 &&
            marketingFeeAfter == 10 &&
            teamFeeAfter == 10 &&
            totalTaxAfter == 30;

        // Final verdict based on state changes
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees were successfully modified to 30% total tax");
        } else {
            console.log("Vulnerability not Exist: Fees were not modified as expected");
        }
    }
}

contract MockRouter {
    function factory() public pure returns (address) {
        return 0x000000000000000000000000000000000000bEEF;
    }

    function WETH() public pure returns (address) {
        return 0x000000000000000000000000000000000000dEaD;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xFeED);
    }
}