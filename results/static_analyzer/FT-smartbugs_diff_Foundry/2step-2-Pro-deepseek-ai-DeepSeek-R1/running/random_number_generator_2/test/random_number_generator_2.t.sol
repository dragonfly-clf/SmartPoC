// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract PredictableRandomnessTest is Test {
    RandomNumberGenerator game;
    address player1 = address(0x1);
    address player2 = address(0x2);

    function setUp() public {
        // Deploy the vulnerable contract
        game = new RandomNumberGenerator();
    }

    function test_RandomNumberIsPredictableInSameBlock() public {
        // Set fixed block number
        vm.roll(1000);
        
        // First game play by player1
        vm.prank(player1);
        game.playGame(10);
        uint256 result1 = game.winningNumber();

        // Differential verification
        console.log("--- BEFORE-Trigger: winningNumber (after first play) ---");
        uint256 stateBefore = game.winningNumber();
        console.log("State BEFORE second game play: %s", stateBefore);

        console.log("--- Trigger: player2 plays the game in same block ---");
        vm.prank(player2);
        game.playGame(10);

        console.log("--- AFTER-Trigger: winningNumber ---");
        uint256 stateAfter = game.winningNumber();
        console.log("State AFTER second game play: %s", stateAfter);

        // Vulnerability checking logic
        if (stateBefore == stateAfter) {
            console.log("Vulnerability Exists: Random number remains fixed in same block (stateBefore %s == stateAfter %s)", stateBefore, stateAfter);
        } else {
            console.log("Vulnerability not Exist: Random number changed in same block");
        }
    }
}