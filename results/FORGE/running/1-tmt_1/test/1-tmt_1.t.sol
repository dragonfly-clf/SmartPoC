// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MILLTICKET.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract FeeManipulationTest is Test {
    MILLTICKET token;
    address constant HARDCODED_OWNER = 0x3588C2d85B0fdFaDc8e24F4e31744aEa3066F277;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mocks
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(
            address(mockFactory), 
            address(1)  // Mock WETH address
        );
        
        // Replace router address code with our mock
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy token contract
        token = new MILLTICKET();
    }

    function test_setTaxFee_beyondLimit() public {
        console.log("--- BEFORE-Trigger Tax Fee ---");
        uint256 taxFeeBefore = token._taxFee();
        console.log("Tax Fee Before: ", taxFeeBefore);

        console.log("--- Trigger setTaxFeePercent(26) ---");
        vm.startPrank(HARDCODED_OWNER);
        uint256 unsafeFee = 26;
        token.setTaxFeePercent(unsafeFee);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Tax Fee ---");
        uint256 taxFeeAfter = token._taxFee();
        console.log("Tax Fee After: ", taxFeeAfter);

        if (taxFeeAfter == unsafeFee) {
            console.log("Vulnerability Exists: Tax fee successfully set beyond safe limit (25%) to 26%");
        } else {
            console.log("Vulnerability not Exist: Tax fee remains within safe limits");
        }
    }
}