// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a4349a749e59a5736efb7826ee3496a2dfd5489.sol";

contract WhaleGiveawayTest is Test {
    WhaleGiveaway1 public whaleGiveaway;
    address payable owner = payable(address(0x100));
    address payable user = payable(address(0x200));

    function setUp() public {
        // Use non-precompile addresses that can receive Ether
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);
        
        // Deploy from owner
        vm.startPrank(owner);
        whaleGiveaway = new WhaleGiveaway1();
        vm.stopPrank();
    }

    function testContractDrainedAfterGetFreebie() public {
        // Snapshot state before attack
        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(whaleGiveaway).balance;
        uint256 ownerBalanceBefore = owner.balance;
        uint256 totalParticipantsBefore = whaleGiveaway.totalParticipants();
        uint256 totalGiveawaysBefore = whaleGiveaway.totalGiveaways();
        uint256 userContributionBefore = whaleGiveaway.participantContributions(user);
        
        console2.log("Contract balance:", contractBalanceBefore);
        console2.log("Owner balance:", ownerBalanceBefore);
        console2.log("Total participants:", totalParticipantsBefore);
        console2.log("Total giveaways:", totalGiveawaysBefore);
        console2.log("User contribution:", userContributionBefore);

        console2.log("--- Trigger GetFreebie ---");
        // Record initial balance for later assert (preserve original)
        uint256 initialOwnerBalance = owner.balance;
        // Call GetFreebie with 2 Ether from user
        vm.prank(user);
        whaleGiveaway.GetFreebie{value: 2 ether}();

        // Snapshot state after attack
        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(whaleGiveaway).balance;
        uint256 ownerBalanceAfter = owner.balance;
        uint256 totalParticipantsAfter = whaleGiveaway.totalParticipants();
        uint256 totalGiveawaysAfter = whaleGiveaway.totalGiveaways();
        uint256 userContributionAfter = whaleGiveaway.participantContributions(user);
        
        console2.log("Contract balance:", contractBalanceAfter);
        console2.log("Owner balance:", ownerBalanceAfter);
        console2.log("Total participants:", totalParticipantsAfter);
        console2.log("Total giveaways:", totalGiveawaysAfter);
        console2.log("User contribution:", userContributionAfter);

        // Calculate state changes with proper types
        int256 contractChange = int256(contractBalanceAfter) - int256(contractBalanceBefore);
        int256 ownerChange = int256(ownerBalanceAfter) - int256(ownerBalanceBefore);
        int256 participantsChange = int256(totalParticipantsAfter) - int256(totalParticipantsBefore);
        int256 giveawaysChange = int256(totalGiveawaysAfter) - int256(totalGiveawaysBefore);
        int256 userContributionChange = int256(userContributionAfter) - int256(userContributionBefore);

        console2.log("Contract balance change:", contractChange);
        console2.log("Owner balance change:", ownerChange);
        console2.log("Participants count change:", participantsChange);
        console2.log("Giveaways count change:", giveawaysChange);
        console2.log("User contribution change:", userContributionChange);

        // Final vulnerability verification
        bool fundsDrained = (contractBalanceAfter == 0) && (ownerChange == int256(2 ether));
        bool stateUpdated = (participantsChange == 1) && 
                            (giveawaysChange == 1) && 
                            (userContributionChange == int256(2 ether));

        console2.log("Funds fully drained:", fundsDrained ? "YES" : "NO");
        console2.log("State updated:", stateUpdated ? "YES" : "NO");
        
        // Maintain original assertions
        assertEq(address(whaleGiveaway).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + 2 ether);
        uint256 beforeWithdrawBalance = owner.balance;
        vm.prank(owner);
        whaleGiveaway.withdraw();
        assertEq(owner.balance, beforeWithdrawBalance);

        // Final verdict
        if (fundsDrained && stateUpdated) {
            console2.log("Vulnerability Exists: Contract funds drained and state updated unexpectedly");
        } else {
            console2.log("Vulnerability not Exist: Contract maintains proper invariant after attack");
        }
    }
}