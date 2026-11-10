// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/junkoInu.sol";

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract JunkoInuTest is Test {
    junkoInu token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0xF000);
    address mockWETH = address(0xF000);
    address mockPair = address(0xCAFE);

    function setUp() public {
        // Mock router and factory calls
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(IUniswapV2Router.factory.selector),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSelector(IUniswapV2Router.WETH.selector),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token contract
        vm.startPrank(owner);
        token = new junkoInu();
        vm.stopPrank();

        // Setup user1 with tokens
        uint256 amount = 1000 * 10 ** token.decimals();
        vm.prank(owner);
        token.transfer(user1, amount);
    }

    function test_SetMaxTxAmountToZeroBlocksTransfers() public {
        console.log("--- BEFORE-Trigger: Query _maxTxAmount ---");
        uint256 maxTxAmountBefore = token._maxTxAmount();
        console.log("_maxTxAmount before set:", maxTxAmountBefore);
        bool initialNonZero = maxTxAmountBefore > 0;
        console.log("Initial maxTxAmount nonzero?", initialNonZero ? "YES" : "NO");

        console.log("--- Trigger: setMaxTxPercent(0) ---");
        // Owner sets maxTxPercent to 0 (makes _maxTxAmount = 0)
        vm.prank(owner);
        token.setMaxTxPercent(0);
        
        console.log("--- AFTER-Trigger: Query _maxTxAmount ---");
        uint256 maxTxAmountAfter = token._maxTxAmount();
        console.log("_maxTxAmount after set:", maxTxAmountAfter);
        bool isZero = maxTxAmountAfter == 0;
        console.log("_maxTxAmount changed to zero:", isZero ? "YES" : "NO");

        // Perform the transfer test
        console.log("--- Trigger: Transfer Test ---");
        vm.startPrank(user1);
        uint256 transferAmount = 1 * 10 ** token.decimals();
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(user2, transferAmount);
        vm.stopPrank();

        // Final vulnerability verdict
        if (isZero) {
            console.log("Vulnerability Exists: Owner successfully set _maxTxAmount to zero blocking transfers");
        } else {
            console.log("Vulnerability not Exist: Setting maxTxPercent(0) did not set _maxTxAmount to zero");
        }
    }
}