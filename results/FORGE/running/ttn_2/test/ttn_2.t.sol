// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TRITON.sol";

contract TotalSupplyDiscrepancyTest is Test {
    TRITON public token;
    address constant OWNER = address(1000);
    address constant USER = address(2000);
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        // Must run on BSC fork due to hardcoded router address
        if (block.chainid != 56) {
            console.log("Skipping test on non-BSC chain");
            return;
        }
        
        vm.startPrank(OWNER);
        token = new TRITON();
        
        // Configure trading and fees
        token.enableTrading();
        token.updateFees(
            0,   // buyDeadFees
            10,  // sellDeadFees
            0,   // buyMarketingFees
            0,   // sellMarketingFees
            0,   // buyLiquidityFee
            0,   // sellLiquidityFee
            0,   // buyRewardsFee
            0,   // sellRewardsFee
            0,   // buyDevFee
            0    // sellDevFee
        );
        token.setcooldowntimer(0);
        token.setGasPriceLimit(5); // Min value allowed: 5 GWEI
        vm.stopPrank();
        
        // Transfer tokens to test user
        uint256 transferAmount = 500 * 10**token.decimals();
        vm.prank(OWNER);
        token.transfer(USER, transferAmount);
        
        // Skip initial blocks
        vm.roll(block.number + 7);
    }

    function testTotalSupplyDiscrepancyAfterBurn() public {
        if (block.chainid != 56) return;

        address pair = token.uniswapV2Pair();
        address dividendTracker = address(token.dividendTracker());
        uint256 initialSupply = token.totalSupply();
        uint256 userBalance = token.balanceOf(USER);
        
        // Pre-transfer state
        console.log("--- BEFORE-Trigger ---");
        console.log("Total Supply:            ", initialSupply);
        uint256 balanceSumPre = 
            token.balanceOf(OWNER) +
            token.balanceOf(USER) +
            token.balanceOf(DEAD) +
            token.balanceOf(address(token)) +
            token.balanceOf(pair) +
            token.balanceOf(dividendTracker);
        console.log("Sum of Balances:         ", balanceSumPre);
        
        uint256 expectedBurn = userBalance * 10 / 100;
        console.log("Expected Burn:           ", expectedBurn);

        // Trigger: Execute user transfer
        console.log("--- Trigger Transfer ---");
        vm.prank(USER);
        token.transfer(pair, userBalance); // Triggers deadFees during sell

        // Post-transfer state
        console.log("--- AFTER-Trigger ---");
        uint256 postSupply = token.totalSupply();
        console.log("Total Supply:            ", postSupply);
        uint256 balanceSumPost = 
            token.balanceOf(OWNER) +
            token.balanceOf(USER) +
            token.balanceOf(DEAD) +
            token.balanceOf(address(token)) +
            token.balanceOf(pair) +
            token.balanceOf(dividendTracker);
        console.log("Sum of Balances:         ", balanceSumPost);

        // Vulnerability detection logic
        bool invariantHoldsPre = (initialSupply == balanceSumPre);
        bool invariantHoldsPost = (postSupply == balanceSumPost);
        bool vulnerabilityExists = invariantHoldsPre && !invariantHoldsPost;

        console.log("Pre-Invariant Holds:     ", invariantHoldsPre ? "Yes" : "No");
        console.log("Post-Invariant Holds:    ", invariantHoldsPost ? "Yes" : "No");
        
        // Final verdict based on state comparison
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Transfer operation destroyed invariant (total supply != sum of balances)");
        } else {
            console.log("Vulnerability not Exist: Invariant remains intact");
        }
    }
}