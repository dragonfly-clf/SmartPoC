// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3f2ef511aa6e75231e4deafc7a3d2ecab3741de2.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public giveaway;
    address owner = makeAddr("owner");
    address participant = makeAddr("participant");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        giveaway = new WhaleGiveaway2();
    }

    function testRedeemTransfersAllFundsToOwner() public {
        // Fund contract with 9 ether
        vm.deal(address(giveaway), 9 ether);
        // Fund participant with 1 ether for redemption
        vm.deal(participant, 1 ether);

        uint256 initialContractBalance = address(giveaway).balance;
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialParticipantBalance = participant.balance;

        console2.log("--- BEFORE-Trigger ---");
        console2.log("Initial Contract balance: %s wei", initialContractBalance);
        console2.log("Initial Owner balance: %s wei", initialOwnerBalance);
        console2.log("Initial Participant balance: %s wei", initialParticipantBalance);
        console2.log("");

        console2.log("--- Trigger: Participant redeems with 1 ether ---");
        // Participant redeems with 1 ether
        vm.prank(participant);
        giveaway.redeem{value: 1 ether}();
        console2.log("");

        uint256 finalContractBalance = address(giveaway).balance;
        uint256 finalOwnerBalance = owner.balance;
        uint256 finalParticipantBalance = participant.balance;

        console2.log("--- AFTER-Trigger ---");
        console2.log("Final Contract balance: %s wei", finalContractBalance);
        console2.log("Final Owner balance: %s wei", finalOwnerBalance);
        console2.log("Final Participant balance: %s wei", finalParticipantBalance);
        console2.log("");

        // Calculate expected balances changes
        uint256 expectedOwnerBalance = initialOwnerBalance + 10 ether;
        uint256 expectedParticipantBalance = initialParticipantBalance - 1 ether;

        // Verify if state changed as expected
        bool success = (finalContractBalance == 0 && 
                       finalOwnerBalance == expectedOwnerBalance && 
                       finalParticipantBalance == expectedParticipantBalance);

        // Final verdict
        if (success) {
            console2.log("Vulnerability Exists: Exploit success, funds transferred to owner");
        } else {
            console2.log("Vulnerability not Exist: Balances did not change as expected");
        }

        // Confirm assertions (matches the condition above)
        assertEq(finalContractBalance, 0, "Contract balance should be drained");
        assertEq(finalOwnerBalance, expectedOwnerBalance, "Owner should receive all funds");
        assertEq(finalParticipantBalance, expectedParticipantBalance, "Participant should lose their contribution");
    }
}