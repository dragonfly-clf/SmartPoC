// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract RandomNumberGeneratorTest is Test {
    RandomNumberGenerator rng;
    address player1 = makeAddr("player1");
    address player2 = makeAddr("player2");

    function setUp() public {
        rng = new RandomNumberGenerator();
        bytes32 saltSlot = bytes32(uint256(0)); // Assume salt is at slot 0
        vm.store(address(rng), saltSlot, bytes32(uint256(1))); // Set salt to 1
    }

    function test_RandomIsPredictableInSameBlock() public {
        uint256 bet = 1;
        vm.roll(1000); // Set fixed block number
        
        console.log("\n--- BEFORE-Trigger First PlayGame ---");
        console.log("WinningNumber state (before first play):", rng.winningNumber());

        console.log("\n--- Trigger First PlayGame ---");
        vm.prank(player1);
        rng.playGame(bet);
        uint256 winningNumber1 = rng.winningNumber();
        console.log("Winning Number after first play:", winningNumber1);

        console.log("\n--- BEFORE-Trigger Second PlayGame ---");
        console.log("WinningNumber state (before second play):", rng.winningNumber());
        
        console.log("\n--- Trigger Second PlayGame ---");
        vm.prank(player2);
        rng.playGame(bet);
        uint256 winningNumber2 = rng.winningNumber();
        console.log("Winning Number after second play:", winningNumber2);
        
        console.log("\n--- Differential Verification ---");
        console.log("Comparing winning numbers [Fist Play vs Second Play]: %s vs %s", 
                    winningNumber1, winningNumber2);
        
        bool sameResults = (winningNumber1 == winningNumber2);
        console.log("Numbers are identical in same block:", sameResults ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (sameResults) {
            console.log("Vulnerability Exists: Identical block produces identical random numbers");
        } else {
            console.log("Vulnerability not Exist: Consecutive plays in same block produce different results");
        }
    }
}