// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

contract MockPair {
    function sync() external {}
}

contract GoldHuntTest is Test {
    GoldHunt token;
    MockPair mockPair;
    address owner = address(0x1);
    address rewardsPool = address(0x2);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new GoldHunt();
        mockPair = new MockPair();
        
        token.setPair(address(mockPair));
        token.setRewardsPool(rewardsPool);
        
        // Transfer initial tokens to rewardsPool
        uint256 transferAmount = 100 ether;
        token.transfer(rewardsPool, transferAmount);
        vm.stopPrank();
    }
    
    function testMultipleRebasesCauseInconsistency() public {
        vm.startPrank(owner);
        uint256 initialBalance = token.balanceOf(rewardsPool);
        assertEq(initialBalance, 100 ether, "Initial rewards pool balance should be 100 ether");
        
        console.log("--- BEFORE-First-Rebase ---");
        uint256 supplyBefore1 = token.totalSupply();
        console.log("Initial Rewards Pool Balance:", initialBalance);
        console.log("Initial Total Supply:", supplyBefore1);
        
        console.log("--- Trigger First Rebase ---");
        // Execute first rebase
        token.rebase(2);
        
        console.log("--- AFTER-First-Rebase ---");
        uint256 balanceAfter1 = token.balanceOf(rewardsPool);
        uint256 supplyAfter1 = token.totalSupply();
        console.log("Rewards Pool Balance (After 1st):", balanceAfter1);
        console.log("Total Supply (After 1st):", supplyAfter1);
        assertEq(balanceAfter1, initialBalance, "Balance should remain same after first rebase");
        
        console.log("--- BEFORE-Second-Rebase ---");
        console.log("Rewards Pool Balance (Pre 2nd):", balanceAfter1);
        console.log("Total Supply (Pre 2nd):", supplyAfter1);
        
        console.log("--- Trigger Second Rebase ---");
        // Execute second rebase
        token.rebase(2);
        
        console.log("--- AFTER-Second-Rebase ---");
        uint256 balanceAfter2 = token.balanceOf(rewardsPool);
        uint256 supplyAfter2 = token.totalSupply();
        console.log("Rewards Pool Balance (After 2nd):", balanceAfter2);
        console.log("Total Supply (After 2nd):", supplyAfter2);
        // Should be reduced to 75% of original
        assertEq(balanceAfter2, 75 ether, "Balance after second rebase should be reduced");
        
        // Vulnerability verification logic
        bool poolBalanceChanged = balanceAfter1 != balanceAfter2;
        bool unexpectedReduction = balanceAfter2 < balanceAfter1;
        bool vulnerabilityExists = poolBalanceChanged && unexpectedReduction;
        
        console.log("State Changes:");
        console.log("- Rewards Pool: %s (before) -> %s (after) = %s%% of initial", 
            balanceAfter1/1e18, 
            balanceAfter2/1e18, 
            (balanceAfter2 * 100) / initialBalance);
        console.log("- Total Supply: %s (before) -> %s (after)", 
            supplyAfter1/1e18, 
            supplyAfter2/1e18);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Consecutive rebases caused 25%% rewards pool reduction");
        } else {
            console.log("Vulnerability not Exist: Rebases didn't reduce rewards pool unexpectedly");
        }
        vm.stopPrank();
    }
    
    function testRebaseWithoutRewardsPool() public {
        vm.startPrank(owner);
        token.setRewardsPool(address(0));
        
        vm.expectRevert("please set rewardsPool");
        token.rebase(2);
        vm.stopPrank();
    }
}