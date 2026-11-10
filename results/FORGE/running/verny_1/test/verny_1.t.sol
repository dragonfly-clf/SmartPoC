// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/VernyDoge.sol";

contract VernyDogeFeeTest is Test {
    VernyDoge token;
    address owner = address(0x1);
    address constant MOCK_FACTORY = address(0xFaC7);
    address constant MOCK_WETH = address(0xEeEE);
    address constant MOCK_PAIR = address(0x1234);
    IUniswapV2Router02 public uniswapV2Router;

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock factory call
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock WETH call
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Flexible mock for createPair (accepts any arguments)
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );
        
        token = new VernyDoge();
        uniswapV2Router = token.uniswapV2Router();
        vm.stopPrank();
    }

    function testFeeLimitViolation() public {
        uint256 excessLiquidityFee = 10;
        uint256 excessMarketingFee = 10;
        uint256 excessTeamFee = 10; // Total = 30% (>25% limit)
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 sellTaxBefore = token._totalTaxIfSelling();
        console.log("Total Sell Tax Before Set: ", sellTaxBefore, "%");

        console.log("--- Trigger SetSelTaxes ---");
        // Owner sets fees beyond intended limit
        vm.prank(owner);
        token.setSelTaxes(
            excessLiquidityFee,
            excessMarketingFee,
            excessTeamFee
        );
        
        console.log("--- AFTER-Trigger State ---");
        uint256 sellTaxAfter = token._totalTaxIfSelling();
        console.log("Total Sell Tax After Set: ", sellTaxAfter, "%");
        
        // Compare before/after states and validate vulnerability
        bool violated = (sellTaxAfter > 25);
        console.log("Fee limit exceeded (25% max):", violated ? "YES" : "NO");

        // Final vulnerability verdict
        if (violated) {
            console.log("Vulnerability Exists: Total sell tax exceeds allowed limit (25%) after manipulation");
        } else {
            console.log("Vulnerability not Exist: Total sell tax within allowed limit (25%) after manipulation");
        }
    }
}