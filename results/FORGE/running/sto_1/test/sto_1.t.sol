// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StepOut.sol";

contract StepOutTest is Test {
    StepOut token;
    address constant owner = address(0x1);
    address constant PCS_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Router function selectors
    bytes4 constant ROUTER_FACTORY_SELECTOR = 0xc45a0155;
    bytes4 constant ROUTER_WETH_SELECTOR = 0xad5c4648;
    
    // Factory function selector
    bytes4 constant FACTORY_CREATE_PAIR_SELECTOR = 0xc9c65396;

    function setUp() public {
        vm.startPrank(owner);
        
        // Precompute token address before deployment
        uint256 nonce = vm.getNonce(owner);
        address tokenAddress = computeCreateAddress(owner, nonce);
        
        // Predefine mock addresses
        address mockFactory = address(0xFaC7);
        address mockWETH = address(0xEe);
        address mockPair = address(0xAbC);
        
        // Mock router factory query
        vm.mockCall(
            PCS_ROUTER,
            abi.encodeWithSelector(ROUTER_FACTORY_SELECTOR),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH query
        vm.mockCall(
            PCS_ROUTER,
            abi.encodeWithSelector(ROUTER_WETH_SELECTOR),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(FACTORY_CREATE_PAIR_SELECTOR, tokenAddress, mockWETH),
            abi.encode(mockPair)
        );
        
        // Deploy token after mocks are set
        token = new StepOut();
        vm.stopPrank();
    }

    function test_TaxCanExceed25Percent() public {
        uint256 excessiveTax = 2600; // 26% (above 25% threshold)
        uint256 threshold = 2500;    // 25% threshold
        
        console2.log("--- BEFORE-Trigger Taxes ---");
        (uint256 marketingBuyBefore,,) = token.taxes();
        (, uint256 liquiditySellBefore,) = token.sellTaxes();
        console2.log("Initial Marketing Buy Tax:", marketingBuyBefore);
        console2.log("Initial Liquidity Sell Tax:", liquiditySellBefore);
        console2.log("Tax Verification Before: Fees are within limits");
        
        console2.log("--- Trigger setTaxes ---");
        // Set taxes above allowed limit
        vm.startPrank(owner);
        token.setTaxes(excessiveTax, 0, 0);       // 26% marketing tax
        token.setSellTaxes(0, excessiveTax, 0);   // 26% liquidity tax
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger Taxes ---");
        (uint256 marketingBuyAfter,,) = token.taxes();
        (, uint256 liquiditySellAfter,) = token.sellTaxes();
        console2.log("Final Marketing Buy Tax:", marketingBuyAfter);
        console2.log("Final Liquidity Sell Tax:", liquiditySellAfter);
        
        // Compare tax rates pre/post trigger
        bool buyTaxExceeded = marketingBuyAfter > threshold;
        bool sellTaxExceeded = liquiditySellAfter > threshold;
        bool vulnerabilityExists = buyTaxExceeded || sellTaxExceeded;
        
        // Print verification result
        console2.log("--- Verification ---");
        console2.log("Marketing tax exceeds 25%%:", buyTaxExceeded ? "YES" : "NO");
        console2.log("Liquidity tax exceeds 25%%:", sellTaxExceeded ? "YES" : "NO");
        console2.log("Total buy tax changed from:", marketingBuyBefore, "to", marketingBuyAfter);
        console2.log("Total sell tax changed from:", liquiditySellBefore, "to", liquiditySellAfter);
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Taxes exceeded 25% limit");
        } else {
            console2.log("Vulnerability not Exist: Taxes remain within 25% limit");
        }
    }
}