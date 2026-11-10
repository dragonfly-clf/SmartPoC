// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract PredictableRandomTest is Test {
    RandomNumberGenerator public game;
    address public player = makeAddr("player");

    function setUp() public {
        game = new RandomNumberGenerator();
    }

    function testRandomIsPredictable() public {
        // Fix the block number to remove environment randomness
        uint256 blockNumber = 10;
        vm.roll(blockNumber);

        console2.log("--- BEFORE-Trigger (Initial State) ---");
        uint256 initialWinningNumber = game.winningNumber();
        console2.log("Initial winningNumber:", initialWinningNumber);

        console2.log("--- Trigger: first playGame ---");
        vm.prank(player);
        game.playGame(1);

        uint256 firstResult = game.winningNumber();
        console2.log("After first play, winningNumber:", firstResult);

        console2.log("--- Trigger: second playGame ---");
        vm.prank(player);
        game.playGame(1);

        uint256 secondResult = game.winningNumber();
        console2.log("After second play, winningNumber:", secondResult);

        console2.log("--- Comparison ---");
        console2.log("First winningNumber:", firstResult);
        console2.log("Second winningNumber:", secondResult);
        console2.log("Are they the same? ", firstResult == secondResult ? "YES" : "NO");

        if (firstResult == secondResult) {
            console2.log("Vulnerability Exists: The winning number is the same in two consecutive plays in the same block");
        } else {
            console2.log("Vulnerability not Exist: The winning numbers are different, as expected");
        }
    }
}