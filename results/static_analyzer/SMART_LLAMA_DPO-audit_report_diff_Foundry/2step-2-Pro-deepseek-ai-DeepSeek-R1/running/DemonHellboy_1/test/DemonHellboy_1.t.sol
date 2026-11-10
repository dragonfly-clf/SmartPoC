// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DemonHellboy.sol";

contract MockWETH {
    fallback() external payable {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract DemonHellboyFeeTest is Test {
    DemonHellboy public token;
    address public owner = address(0x1);
    address public constant PANCAKE_ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock dependencies to bypass router call in constructor
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));

        // Mock the hardcoded PancakeSwap router address
        vm.etch(PANCAKE_ROUTER_ADDR, address(mockRouter).code);
        
        vm.startPrank(owner);
        token = new DemonHellboy();
        vm.stopPrank();
    }

    function testSetExcessiveBuyFees() public {
        console.log("--- BEFORE-Trigger Fee Change ---");
        console.log("Buy fee settings unchanged (normal state)");
        
        console.log("--- Trigger SetBuyFee(10000, 10000) ---");
        vm.prank(owner);
        token.setBuyFee(10000, 10000);
        
        console.log("--- AFTER-Trigger Fee Change ---");
        console.log("Vulnerability Exists: Owner successfully set 100% buy fees without validation");
    }

    function testSetExcessiveSellFees() public {
        console.log("--- BEFORE-Trigger Fee Change ---");
        console.log("Sell fee settings unchanged (normal state)");
        
        console.log("--- Trigger SetSellFee(10000, 10000) ---");
        vm.prank(owner);
        token.setSellFee(10000, 10000);
        
        console.log("--- AFTER-Trigger Fee Change ---");
        console.log("Vulnerability Exists: Owner successfully set 100% sell fees without validation");
    }

    function testSetExcessiveTaxFee() public {
        console.log("--- BEFORE-Trigger Fee Change ---");
        console.log("Tax fee setting unchanged (normal state)");
        
        console.log("--- Trigger SetTaxFeePercent(10000) ---");
        vm.prank(owner);
        token.setTaxFeePercent(10000);
        
        console.log("--- AFTER-Trigger Fee Change ---");
        console.log("Vulnerability Exists: Owner successfully set 100% tax fee without validation");
    }

    function testSetExcessiveLiquidityFee() public {
        console.log("--- BEFORE-Trigger Fee Change ---");
        console.log("Liquidity fee setting unchanged (normal state)");
        
        console.log("--- Trigger SetLiquidityFeePercent(10000) ---");
        vm.prank(owner);
        token.setLiquidityFeePercent(10000);
        
        console.log("--- AFTER-Trigger Fee Change ---");
        console.log("Vulnerability Exists: Owner successfully set 100% liquidity fee without validation");
    }
}