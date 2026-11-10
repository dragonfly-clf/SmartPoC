// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public giveaway;
    address public deployer;
    address public participant1;
    address public participant2;
    
    function setUp() public {
        deployer = makeAddr("deployer");
        participant1 = makeAddr("participant1");
        participant2 = makeAddr("participant2");
        
        // Deploy contract by deployer account
        vm.prank(deployer);
        giveaway = new WhaleGiveaway2();

        // Fund participants
        vm.deal(participant1, 5 ether);
        vm.deal(participant2, 5 ether);
        
        // Fund contract with initial capital
        vm.deal(address(giveaway), 1 ether);
        
        // Deployer starts with 0 ETH
        vm.deal(deployer, 0);
    }

    function test_ContractDrainPreventsService() public {
        // State snapshot initial state
        console2.log("--- BEFORE-Trigger (Initial State) ---");
        uint256 contractBalanceInitial = giveaway.getContractBalance();
        console2.log("Initial contract balance:", contractBalanceInitial);
        console2.log("Total participants (initial):", giveaway.totalParticipants());
        console2.log("Total giveaways (initial):", giveaway.totalGiveaways());
        console2.log("Participant1 contribution (initial):", giveaway.participantContributions(participant1));
        console2.log("Participant2 contribution (initial):", giveaway.participantContributions(participant2));

        // First participant call - should drain contract
        console2.log("--- Trigger (First Participant) ---");
        vm.prank(participant1);
        giveaway.GetFreebie{value: 1.1 ether}();
        
        // State after first participant call
        console2.log("--- AFTER-Trigger (First Participant) ---");
        uint256 contractBalanceAfter1st = giveaway.getContractBalance();
        uint256 totalParticipantsAfter1st = giveaway.totalParticipants();
        uint256 totalGiveawaysAfter1st = giveaway.totalGiveaways();
        console2.log("Contract balance (after first):", contractBalanceAfter1st);
        console2.log("Total participants (after first):", totalParticipantsAfter1st);
        console2.log("Total giveaways (after first):", totalGiveawaysAfter1st);
        console2.log("Participant1 contribution (after first):", giveaway.participantContributions(participant1));
        console2.log("Participant2 contribution (after first):", giveaway.participantContributions(participant2));

        // Verify state changed unexpectedly
        bool hasAnomaly = giveaway.totalParticipants() == 0 ||
                          giveaway.totalGiveaways() != 0 ||
                          giveaway.participantContributions(participant1) != 0;
        console2.log("Anomalous state changes after first call:", hasAnomaly ? "YES" : "NO");

        // Second participant call - should also fail
        console2.log("--- Trigger (Second Participant) ---");
        vm.prank(participant2);
        giveaway.GetFreebie{value: 1.1 ether}();
        
        // State after second participant call
        console2.log("--- AFTER-Trigger (Second Participant) ---");
        console2.log("Contract balance (after second):", giveaway.getContractBalance());
        console2.log("Total participants (after second):", giveaway.totalParticipants());
        console2.log("Total giveaways (after second):", giveaway.totalGiveaways());
        console2.log("Participant1 contribution (after second):", giveaway.participantContributions(participant1));
        console2.log("Participant2 contribution (after second):", giveaway.participantContributions(participant2));

        // Final vulnerability verification
        bool vulnerable = (giveaway.getContractBalance() == 0) &&
                          (deployer.balance == 3.2 ether) &&
                          hasAnomaly;
        
        if(vulnerable) {
            console2.log("Vulnerability Exists: Contract drained, state unchanged, and users lost funds");
        } else {
            console2.log("Vulnerability not Exist: Contract state and balances match expected behavior");
        }
    }
}