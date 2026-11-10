// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FGIKING.sol";

// Mock contracts to simulate PancakeSwap environment
contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
    function transfer(address, uint256) external pure returns (bool) {}
}

contract MockPair {}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _weth) {
        factory = address(new MockFactory());
        WETH = _weth;
    }
}

contract FGIKINGTest is Test {
    FGIKING token;
    address owner = address(0x1);

    function setUp() public {
        // Deploy mock WETH
        MockWETH weth = new MockWETH();
        
        // Define the hardcoded PancakeSwap router address
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
        // Deploy mock router and get its bytecode
        MockRouter router = new MockRouter(address(weth));
        bytes memory routerCode = address(router).code;
        
        // Deploy the mock router at the hardcoded address
        vm.etch(routerAddress, routerCode);
        
        // Deploy the token contract
        vm.startPrank(owner);
        token = new FGIKING();
        vm.stopPrank();
    }

    function test_FeeManipulationOver25Percent() public {
        console.log("--- BEFORE-Trigger Tax Rates ---");
        // Query initial tax rates
        uint256 buyTaxBefore = token._totalTaxIfBuying();
        uint256 sellTaxBefore = token._totalTaxIfSelling();
        console.log("Initial Buy Tax Rate: %", buyTaxBefore);
        console.log("Initial Sell Tax Rate: %", sellTaxBefore);

        console.log("--- Trigger ChangeFee ---");
        // Owner sets fees above allowed limit (30% total)
        vm.prank(owner);
        token.setBuyTaxes(10, 10, 10);  // Total 30%
        
        vm.prank(owner);
        token.setSellTaxes(10, 10, 10);  // Total 30%
        
        console.log("--- AFTER-Trigger Tax Rates ---");
        // Query new tax rates
        uint256 buyTaxAfter = token._totalTaxIfBuying();
        uint256 sellTaxAfter = token._totalTaxIfSelling();
        console.log("New Buy Tax Rate: %", buyTaxAfter);
        console.log("New Sell Tax Rate: %", sellTaxAfter);

        // Check if tax rates exceed 25%
        bool buyTaxExceedsLimit = buyTaxAfter > 25;
        bool sellTaxExceedsLimit = sellTaxAfter > 25;
        bool isVulnerable = buyTaxExceedsLimit || sellTaxExceedsLimit;
        
        // Final verdict based on state changes
        if (isVulnerable) {
            console.log("Vulnerability Exists: Taxes can be set above 25 percent limit");
        } else {
            console.log("Vulnerability not Exist: Taxes are capped at 25 percent");
        }
    }
}