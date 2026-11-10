// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a4349a749e59a5736efb7826ee3496a2dfd5489.sol";

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 public giveaway;
    address attacker = address(0x1337);

    // Allow test contract to receive ether
    receive() external payable {}

    function setUp() public {
        vm.deal(attacker, 20 ether);
        giveaway = new WhaleGiveaway1();
    }

    function testGetFreebieOverflow() public {
        // Set attacker's contribution to max value in storage
        bytes32 contributionsSlot = keccak256(abi.encode(attacker, uint256(3)));
        uint256 maxValue = type(uint256).max;
        vm.store(address(giveaway), contributionsSlot, bytes32(maxValue));
        
        // Record pre-attack state
        console2.log("--- BEFORE-Trigger GetFreebie ---");
        uint256 beforeContribution = giveaway.participantContributions(attacker);
        uint256 beforeParticipants = giveaway.totalParticipants();
        console2.log("Attacker Contribution Before:", beforeContribution);
        console2.log("Total Participants Before:", beforeParticipants);
        
        // Vulnerable function call
        console2.log("--- Trigger GetFreebie ---");
        vm.prank(attacker);
        vm.expectRevert();
        giveaway.GetFreebie{value: 1.5 ether}();
        
        // Record post-attack state
        console2.log("--- AFTER-Trigger GetFreebie ---");
        uint256 afterContribution = giveaway.participantContributions(attacker);
        uint256 afterParticipants = giveaway.totalParticipants();
        console2.log("Attacker Contribution After:", afterContribution);
        console2.log("Total Participants After:", afterParticipants);
        
        // Vulnerability exists if state remains unchanged (overflow caused revert)
        bool stateUnchanged = (beforeContribution == afterContribution) && 
                             (beforeParticipants == afterParticipants);
        
        if (stateUnchanged) {
            console2.log("Vulnerability Exists: Overflow caused revert with unchanged state");
        } else {
            console2.log("Vulnerability not Exist: State changed unexpectedly");
        }
    }
}