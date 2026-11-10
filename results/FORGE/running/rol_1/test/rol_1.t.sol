// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WrathofLegends.sol";

contract MockUniswapV2Factory {
    address public constant dummyPair = address(0x456);

    function createPair(address, address) external pure returns (address) {
        return dummyPair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(address _factory) {
        factory = _factory;
    }
}

contract FeeManipulationTest is Test {
    WrathofLegends token;
    address owner = 0xfae03Ca5CED4900BBD3Cf8BF2b7dE4fc42f1592b;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        bytes memory mockFactoryCode = type(MockUniswapV2Factory).creationCode;
        MockUniswapV2Factory factory = new MockUniswapV2Factory();

        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(factory));
        bytes memory mockRouterCode = address(mockRouter).code;

        // Overwrite hardcoded router address
        vm.etch(routerAddress, mockRouterCode);
        
        vm.prank(owner);
        token = new WrathofLegends();
    }

    function testOwnerCanExceedFeeLimit() public {
        // Log pre-state snapshot
        console.log("--- BEFORE-Trigger Tax Fee ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial tax fee percentage (before): %s%%", initialTaxFee);
        require(initialTaxFee <= 25, "Tax fee exceeds pre-expected limit initially");

        // Log trigger operation detail
        console.log("--- Trigger Owner Fee Changes ---");
        vm.startPrank(owner);
        token.setTaxFeePercent(26);
        token.setTaxFeePercent(100);
        vm.stopPrank();
        console.log("Owner executed setTaxFeePercent(26) -> setTaxFeePercent(100)");

        // Log post-state snapshot
        console.log("--- AFTER-Trigger Tax Fee ---");
        uint256 finalTaxFee = token._taxFee();
        console.log("Final tax fee percentage (after): %s%%", finalTaxFee);

        // Vulnerability verification and final verdict
        if (finalTaxFee > 25) {
            console.log("Verdict: Tax fee changed %s%% -> %s%% (violates 25%% limit)", initialTaxFee, finalTaxFee);
            console.log("Vulnerability Exists: Owner can set tax fee arbitrarily above the 25%% limit");
        } else {
            console.log("Verdict: Tax fee remains within safe limits: %s%%", finalTaxFee);
            console.log("Vulnerability not Exist: Tax fee control mechanisms are effective");
        }
    }
}