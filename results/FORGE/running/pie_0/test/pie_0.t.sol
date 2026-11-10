// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PieShare.sol";

contract PieShareTest is Test {
    PieShare token;
    address owner = address(0x1);

    // Constants for mock addresses
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0x222);
    address constant MOCK_WETH = address(0x333);
    address constant MOCK_PAIR = address(0x444);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock PancakeRouter factory call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock PancakeRouter WETH call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Deploy token with mocked dependencies
        token = new PieShare();
        vm.stopPrank();
    }

    function test_unlimited_fee_increase() public {
        vm.startPrank(owner);

        // Set excessive fees (90% and 100%)
        uint256 excessiveFee1 = 90;
        uint256 excessiveFee2 = 100;
        
        // Record state before fee changes
        uint256 marketingFeeBefore = token.marketingFee();
        uint256 totalFeesBefore = token.totalFees();
        
        console.log("--- BEFORE-Trigger FeeSetting ---");
        console.log("Marketing fee before:", marketingFeeBefore);
        console.log("Total fees before:", totalFeesBefore);
        
        console.log("--- Trigger: setMarketingFee(90) and setMarketingFee(100) ---");
        
        // Should not revert (no upper limit checks)
        token.setMarketingFee(excessiveFee1);
        token.setMarketingFee(excessiveFee2);
        
        // Record state after fee changes
        uint256 marketingFeeAfter = token.marketingFee();
        uint256 totalFeesAfter = token.totalFees();
        
        console.log("--- AFTER-Trigger FeeSetting ---");
        console.log("Marketing fee after:", marketingFeeAfter);
        console.log("Total fees after:", totalFeesAfter);
        
        vm.stopPrank();
        
        // Vulnerability Verification
        if (marketingFeeAfter == excessiveFee2 && totalFeesAfter >= excessiveFee2) {
            console.log("Vulnerability Exists: Marketing fee set to 100% without upper limit");
        } else {
            console.log("Vulnerability not Exist: Marketing fee remains within safe bounds");
        }
    }
}