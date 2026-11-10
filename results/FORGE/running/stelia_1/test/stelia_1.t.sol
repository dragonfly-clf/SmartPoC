// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Stelia.sol";

contract SteliaTest is Test {
    Stelia public token;
    address owner = address(0x1);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Create a mock factory address
        address mockFactory = address(new MockFactory());
        address dummyPair = 0x1234567890123456789012345678901234567890;

        // Mock PancakeRouter factory() call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(mockFactory)
        );

        // Mock PancakeRouter WETH() call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(WETH_ADDRESS)
        );

        // Mock factory createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(dummyPair)
        );

        // Deploy token contract
        vm.prank(owner);
        token = new Stelia();
    }

    function test_FeeManipulation() public {
        uint256 highBuyFee = 30;
        uint256 highSellFee = 30;
        
        // Pre-trigger state capture
        uint256 beforeBuyFee = token._buyAdvestisementFee();
        uint256 beforeSellFee = token._sellAdvestisementFee();
        console.log("--- BEFORE-Trigger setAdvestisementFeePercent ---");
        console.log("Buy Fee Before:", beforeBuyFee);
        console.log("Sell Fee Before:", beforeSellFee);

        console.log("--- Trigger setAdvestisementFeePercent(30,30) ---");
        vm.startPrank(owner);
        token.setAdvestisementFeePercent(highBuyFee, highSellFee);
        vm.stopPrank();

        // Post-trigger state capture
        uint256 afterBuyFee = token._buyAdvestisementFee();
        uint256 afterSellFee = token._sellAdvestisementFee();
        console.log("--- AFTER-Trigger setAdvestisementFeePercent ---");
        console.log("Buy Fee After:", afterBuyFee);
        console.log("Sell Fee After:", afterSellFee);

        // Validation and verdict
        bool success = (afterBuyFee == highBuyFee) && (afterSellFee == highSellFee);
        if (success) {
            console.log("Vulnerability Exists: setAdvestisementFeePercent permitted fees above 25% threshold (set to 30%)");
        } else {
            console.log("Vulnerability not Exist: Fees not changed to 30% after manipulation attempt");
        }
    }
}

contract MockFactory {
    // Empty mock contract for factory operations
}