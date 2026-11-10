// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

// Mock Uniswap sync interface
contract MockSync {
    function sync() external {
        // No-op implementation
    }
}

contract GoldHuntRebaseTest is Test {
    GoldHunt public token;
    MockSync public mockPair;
    
    address public owner = address(0xA);
    address public rewardsPool = address(0xB);
    
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 1e18;
    uint256 public constant TRANSFER_AMOUNT = 1_000 * 1e18;
    uint256 public constant REBASE_MULTIPLE = 2;

    function setUp() public {
        // Deploy contracts
        vm.startPrank(owner);
        token = new GoldHunt();
        mockPair = new MockSync();
        
        // Configure token
        token.setPair(address(mockPair));
        token.setRewardsPool(rewardsPool);
        
        // Prepare rewards pool
        token.transfer(rewardsPool, TRANSFER_AMOUNT);
        vm.stopPrank();
    }

    function test_rebaseOnlyByOwner() public {
        // Non-owner should not be able to rebase
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0xC));
        token.rebase(REBASE_MULTIPLE);
    }

    function test_rebaseInflation() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Capture initial state
        uint256 preTotalSupply = token.totalSupply();
        uint256 preRewardsBalance = token.balanceOf(rewardsPool);
        uint256 preOwnerBalance = token.balanceOf(owner);
        
        console2.log("Total Supply:        ", preTotalSupply);
        console2.log("Rewards Pool:        ", preRewardsBalance);
        console2.log("Owner Balance:       ", preOwnerBalance);
        
        console2.log("--- Trigger Rebase ---");
        // Perform rebase
        vm.prank(owner);
        token.rebase(REBASE_MULTIPLE);
        console2.log("Rebase triggered with multiplier:", REBASE_MULTIPLE);
        
        console2.log("--- AFTER-Trigger State ---");
        // Capture state after rebase
        uint256 postTotalSupply = token.totalSupply();
        uint256 postRewardsBalance = token.balanceOf(rewardsPool);
        uint256 postOwnerBalance = token.balanceOf(owner);
        
        console2.log("Total Supply:        ", postTotalSupply);
        console2.log("Rewards Pool:        ", postRewardsBalance);
        console2.log("Owner Balance:       ", postOwnerBalance);
        
        console2.log("--- State Comparison ---");
        // Calculate expected results based on PoC logic
        uint256 expectedTotalSupply = (INITIAL_SUPPLY + TRANSFER_AMOUNT) / REBASE_MULTIPLE;
        uint256 expectedOwnerBalance = (INITIAL_SUPPLY - TRANSFER_AMOUNT) / REBASE_MULTIPLE;
        
        // Compare pre and post states
        bool totalSupplyChanged = postTotalSupply != preTotalSupply;
        bool rewardsPoolChanged = postRewardsBalance != preRewardsBalance;
        bool ownerBalanceChanged = postOwnerBalance != preOwnerBalance;
        bool supplyMatchesExpectation = postTotalSupply == expectedTotalSupply;
        bool ownerBalanceMatchesExpectation = postOwnerBalance == expectedOwnerBalance;
        bool rewardsBalanceMaintained = postRewardsBalance == preRewardsBalance;
        bool ownerDiluted = postOwnerBalance < preOwnerBalance;
        
        console2.log("Total Supply Change:         ", totalSupplyChanged ? "YES" : "NO");
        console2.log("Rewards Pool Change:         ", rewardsPoolChanged ? "YES" : "NO");
        console2.log("Owner Balance Change:        ", ownerBalanceChanged ? "YES" : "NO");
        console2.log("Supply Matches Expectation:  ", supplyMatchesExpectation ? "YES" : "NO");
        console2.log("Owner Balance Matches:       ", ownerBalanceMatchesExpectation ? "YES" : "NO");
        console2.log("Rewards Balance Maintained:  ", rewardsBalanceMaintained ? "YES" : "NO");
        console2.log("Owner Diluted:               ", ownerDiluted ? "YES" : "NO");
        
        // Vulnerability verdict decision
        bool vulnerabilityExists = totalSupplyChanged && 
                                  ownerBalanceChanged && 
                                  rewardsBalanceMaintained && 
                                  ownerDiluted;
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: rebase operation changed total supply and diluted owner balance while maintaining rewards pool balance");
        } else {
            console2.log("Vulnerability not Exist: rebase operation did not produce expected state changes (totalSupply:%s rewardsPoolUnchanged:%s ownerDiluted:%s)", 
                         totalSupplyChanged, rewardsBalanceMaintained, ownerDiluted);
        }
    }
}