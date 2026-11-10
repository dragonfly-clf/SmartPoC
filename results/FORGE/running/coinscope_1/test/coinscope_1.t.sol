// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Coinscope.sol";

contract MockWETH {
    receive() external payable {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(uint160(uint256(keccak256("test pair"))));
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

contract CoinscopeFeeManipulationTest is Test {
    Coinscope public token;
    address public owner = address(0x1);

    function setUp() public {
        // Deploy mock Uniswap dependencies
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(factory), address(weth));

        // Simulate PancakeSwap router at its mainnet address
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);

        // Deploy and initialize contract as owner
        vm.startPrank(owner);
        token = new Coinscope();
        token.afterPresale(); // Configure post-presale settings
        vm.stopPrank();
    }

    function testOwnerCanSetExcessiveTaxFee() public {
        console.log("--- BEFORE State ---");
        uint256 totalFeesBefore = token.totalFees();
        console.log("Total Fees Before: %s", totalFeesBefore);

        console.log("--- TRIGGER: setTaxFeePercent(100) ---");
        vm.prank(owner);
        token.setTaxFeePercent(100); // Critical vulnerability trigger

        console.log("--- AFTER State ---");
        uint256 totalFeesAfter = token.totalFees();
        console.log("Total Fees After: %s", totalFeesAfter);

        console.log("--- COMPARISON VERDICT ---");
        // Verify tax fee was increased to 100%
        if (totalFeesAfter >= 100) {
            console.log("Vulnerability Exists: Tax fee can be set to 100%% or higher");
        } else {
            console.log("Vulnerability not Exist: Tax fee not changed to excessive value");
        }
    }
}