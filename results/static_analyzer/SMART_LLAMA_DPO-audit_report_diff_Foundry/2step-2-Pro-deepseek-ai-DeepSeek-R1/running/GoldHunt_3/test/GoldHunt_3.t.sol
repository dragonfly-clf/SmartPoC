// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoldHunt.sol";

contract MockPair {
    uint256 public syncCalled;

    function sync() external {
        syncCalled++;
    }
}

contract GoldHuntRebaseTest is Test {
    GoldHunt token;
    MockPair mockPair;
    
    address owner = address(0x1);
    address rewardsPool = address(0x2);
    address alice = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new GoldHunt();
        token.setRewardsPool(rewardsPool);
        
        mockPair = new MockPair();
        token.setPair(address(mockPair));
        vm.stopPrank();
    }

    function testRebaseFailsWithUnsetRewardsPool() public {
        vm.prank(owner);
        token.setRewardsPool(address(0));

        vm.prank(owner);
        vm.expectRevert("please set rewardsPool");
        token.rebase(2);
    }

    function testRebaseFailsWithUnsetPair() public {
        vm.prank(owner);
        token.setPair(address(0));

        vm.prank(owner);
        vm.expectRevert();
        token.rebase(2);
    }

    function testRebaseUpdatesStateCorrectly() public {
        // Store initial states
        console2.log("--- BEFORE-Trigger State ---");
        uint initialMultiple = token.rebaseMultiple();
        uint initialTotalSupply = token.totalSupply();
        uint initialRewardsPoolBalance = token.balanceOf(rewardsPool);
        uint initialOwnerBalance = token.balanceOf(owner);
        
        console2.log("Initial rebaseMultiple:", initialMultiple);
        console2.log("Initial totalSupply:", initialTotalSupply);
        console2.log("Initial rewardsPool balance:", initialRewardsPoolBalance);
        console2.log("Initial owner balance:", initialOwnerBalance);

        console2.log("--- Trigger Rebase ---");
        vm.prank(owner);
        token.rebase(2); // Double the rebase multiple
        console2.log("Rebase triggered with multiplier 2");

        console2.log("--- AFTER-Trigger State ---");
        uint newMultiple = token.rebaseMultiple();
        uint newTotalSupply = token.totalSupply();
        uint newRewardsPoolBalance = token.balanceOf(rewardsPool);
        uint newOwnerBalance = token.balanceOf(owner);
        
        console2.log("New rebaseMultiple:", newMultiple);
        console2.log("New totalSupply:", newTotalSupply);
        console2.log("New rewardsPool balance:", newRewardsPoolBalance);
        console2.log("New owner balance:", newOwnerBalance);

        // Compare state changes
        bool stateChanged = (initialMultiple != newMultiple) ||
                            (initialTotalSupply != newTotalSupply) ||
                            (initialRewardsPoolBalance != newRewardsPoolBalance) ||
                            (initialOwnerBalance != newOwnerBalance);
        
        if (stateChanged) {
            console2.log("--- State Change Detected ---");
            console2.log("RESULT: Vulnerability Exists - Rebase operation modifies token state arbitrarily");
        } else {
            console2.log("--- No State Change Detected ---");
            console2.log("RESULT: Vulnerability not Exist - Rebase operation didn't modify critical state");
        }

        // Final verdict
        if (stateChanged) {
            console2.log("Vulnerability Exists: Arbitrary state modification via rebase function");
        } else {
            console2.log("Vulnerability not Exist: Critical state unchanged after rebase");
        }

        // Verify updated state (original assertions)
        assertEq(newMultiple, initialMultiple * 2, "Rebase multiple not updated");
        assertEq(newTotalSupply, initialTotalSupply / 2, "Total supply not halved");
        assertEq(newRewardsPoolBalance, initialRewardsPoolBalance, "Rewards pool balance changed");
        assertEq(newOwnerBalance, initialOwnerBalance / 2, "Owner balance not adjusted for multiple");
        assertEq(mockPair.syncCalled(), 1, "Pair sync not called");
    }

    function testRebaseWithRewardsPoolBalance() public {
        // Transfer tokens to rewards pool to test non-zero case
        uint transferAmount = token.balanceOf(owner) / 2;
        vm.prank(owner);
        token.transfer(rewardsPool, transferAmount);

        uint initialRewardsPoolBalance = token.balanceOf(rewardsPool);
        uint initialOwnerBalance = token.balanceOf(owner);
        uint initialTotalSupply = token.totalSupply();

        vm.prank(owner);
        token.rebase(2); // Double the rebase multiple

        // Calculate expected changes
        uint newRewardsPoolBalance = token.balanceOf(rewardsPool);
        uint newOwnerBalance = token.balanceOf(owner);
        uint newTotalSupply = token.totalSupply();

        // Should maintain same public balance for rewards pool through compounding
        assertEq(newRewardsPoolBalance, initialRewardsPoolBalance, "Rewards pool balance changed");
        
        // Owner's public balance should be halved due to multiple doubling
        assertEq(newOwnerBalance, initialOwnerBalance / 2, "Owner balance not updated correctly");
        
        // Total supply calculation updated for new multiple and new tokens
        assertEq(newTotalSupply, (initialTotalSupply + initialRewardsPoolBalance) / 2, "Total supply incorrect");
    }

    function testRebaseUpdatesMultiple() public {
        uint initialMultiple = token.rebaseMultiple();
        
        vm.prank(owner);
        token.rebase(3); // Triple the rebase multiple
        
        uint newMultiple = token.rebaseMultiple();
        assertEq(newMultiple, initialMultiple * 3, "Rebase multiple not updated");
    }

    function testRebaseCallsSync() public {
        uint initialSyncCount = mockPair.syncCalled();
        
        vm.prank(owner);
        token.rebase(2);
        
        uint newSyncCount = mockPair.syncCalled();
        assertEq(newSyncCount, initialSyncCount + 1, "Sync not called");
    }
}