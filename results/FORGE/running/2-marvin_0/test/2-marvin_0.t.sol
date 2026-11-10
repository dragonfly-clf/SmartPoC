// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarvinInu.sol";

contract MarvinInuFeeTest is Test {
    MarvinInu token;
    address constant OWNER = address(0x1);
    address constant MOCK_ROUTER = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant MOCK_FACTORY = address(0x1234);
    address constant MOCK_WETH = address(0x5678);
    address constant MOCK_PAIR = address(0x9ABC);

    function setUp() public {
        // Mock Uniswap router's factory() function
        vm.mockCall(
            MOCK_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock Uniswap router's WETH() function
        vm.mockCall(
            MOCK_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory's createPair() function
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Deploy token contract as owner
        vm.startPrank(OWNER);
        token = new MarvinInu();
        vm.stopPrank();
    }

    function test_FeeVulnerability() public {
        vm.startPrank(OWNER);

        console.log("\n--- BEFORE-Trigger Fee State ---");
        console.log("Initial Buy Total Fees:", token.buyTotalFees());
        console.log("Initial Sell Total Fees:", token.sellTotalFees());

        console.log("\n--- Trigger: updateBuyFees(40,9,1) ---");
        token.updateBuyFees(40, 9, 1);
        
        console.log("\n--- AFTER-Trigger Fee State ---");
        console.log("Updated Buy Total Fees:", token.buyTotalFees());
        console.log("Sell Total Fees (unchanged):", token.sellTotalFees());
        assertEq(token.buyTotalFees(), 50, "Total buy fees should be 50%");

        console.log("\n--- Trigger: updateSellFees(48,1,1) ---");
        token.updateSellFees(48, 1, 1);
        
        console.log("\n--- AFTER-Trigger Fee State ---");
        console.log("Buy Total Fees (unchanged):", token.buyTotalFees());
        console.log("Updated Sell Total Fees:", token.sellTotalFees());
        assertEq(token.sellTotalFees(), 50, "Total sell fees should be 50%");

        console.log("\n--- Trigger: Attempt updateBuyFees(51,0,0) ---");
        vm.expectRevert("Must keep fees at 50% or less");
        token.updateBuyFees(51, 0, 0);
        
        console.log("\n--- Trigger: Attempt updateSellFees(51,0,0) ---");
        vm.expectRevert("Must keep fees at 50% or less");
        token.updateSellFees(51, 0, 0);

        vm.stopPrank();

        console.log("\nVulnerability Exists: Owner can set fees to maximum 50%");
    }
}