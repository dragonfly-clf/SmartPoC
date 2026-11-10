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
    address owner;
    address rewardsPool;
    address alice;

    function setUp() public {
        owner = address(0x1);
        rewardsPool = address(0x2);
        alice = address(0x3);
        
        mockPair = new MockPair();
        
        vm.startPrank(owner);
        token = new GoldHunt();
        token.setRewardsPool(rewardsPool);
        token.setPair(address(mockPair));
        
        uint256 decimals = token.decimals();
        uint256 unit = 10 ** decimals;
        uint256 initialAmount = 1000 * unit;
        
        token.transfer(rewardsPool, initialAmount);
        token.transfer(alice, initialAmount);
        vm.stopPrank();
    }

    function test_RebaseAccountingIssue() public {
        uint256 decimals = token.decimals();
        uint256 unit = 10 ** decimals;
        uint256 initialSupply = token.totalSupply();
        
        // Initial state checks
        console.log("--- BEFORE First Rebase Trigger ---");
        uint256 rewardsPoolBeforeFirst = token.balanceOf(rewardsPool);
        uint256 aliceBeforeFirst = token.balanceOf(alice);
        uint256 totalSupplyBeforeFirst = token.totalSupply();

        console.log("RewardsPool initial balance:", rewardsPoolBeforeFirst);
        console.log("Alice initial balance:", aliceBeforeFirst);
        console.log("Initial total supply:", totalSupplyBeforeFirst);

        // First rebase (2x)
        console.log("--- Trigger First Rebase ---");
        vm.prank(owner);
        token.rebase(2);
        
        console.log("--- AFTER First Rebase ---");
        uint256 rewardsPoolAfterFirst = token.balanceOf(rewardsPool);
        uint256 aliceAfterFirst = token.balanceOf(alice);
        uint256 totalSupplyAfterFirst = token.totalSupply();

        console.log("RewardsPool balance after 1st rebase:", rewardsPoolAfterFirst);
        console.log("Alice balance after 1st rebase:", aliceAfterFirst);
        console.log("Total supply after 1st rebase:", totalSupplyAfterFirst);

        // Prepare for second rebase
        console.log("--- BEFORE Second Rebase Trigger ---");
        console.log("RewardsPool pre-trigger:", rewardsPoolAfterFirst);
        console.log("Alice pre-trigger:", aliceAfterFirst);
        console.log("Total supply pre-trigger:", totalSupplyAfterFirst);

        // Second rebase (2x) - vulnerability manifests
        console.log("--- Trigger Second Rebase ---");
        vm.prank(owner);
        token.rebase(2);
        
        console.log("--- AFTER Second Rebase ---");
        uint256 rewardsPoolAfterSecond = token.balanceOf(rewardsPool);
        uint256 aliceAfterSecond = token.balanceOf(alice);
        uint256 totalSupplyAfterSecond = token.totalSupply();
        
        console.log("RewardsPool balance after 2nd rebase:", rewardsPoolAfterSecond);
        console.log("Alice balance after 2nd rebase:", aliceAfterSecond);
        console.log("Total supply after 2nd rebase:", totalSupplyAfterSecond);

        // Vulnerable state expectations
        uint256 expectedRewardsPool = 750 * unit;
        uint256 expectedAlice = 250 * unit;
        uint256 expectedTotalSupply = 25000500000000000000000000;
        
        // Validate against vulnerable state
        bool rewardsMatch = rewardsPoolAfterSecond == expectedRewardsPool;
        bool aliceMatch = aliceAfterSecond == expectedAlice;
        bool supplyMatch = totalSupplyAfterSecond == expectedTotalSupply;
        
        if (rewardsMatch && aliceMatch && supplyMatch) {
            console.log("Vulnerability Exists: Consecutive rebases caused incorrect dilution of rewardsPool and user balance, and total supply error.");
        } else {
            console.log("Vulnerability not Exist: Final state doesn't match vulnerable patterns (rewards: %s, alice: %s, supply: %s)",
                rewardsMatch, aliceMatch, supplyMatch
            );
        }
    }
}