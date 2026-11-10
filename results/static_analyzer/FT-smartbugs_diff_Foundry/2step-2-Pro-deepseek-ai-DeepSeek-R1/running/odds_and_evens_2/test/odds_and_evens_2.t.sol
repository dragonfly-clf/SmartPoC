// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

contract EtherRejector {
    fallback() external payable {
        revert();
    }
}

contract OddsAndEvensTest is Test {
    OddsAndEvens game;
    OddsAndEvens maliciousGame;
    EtherRejector rejector;
    
    address player1 = address(0x1);
    address player2 = address(0x2);

    function setUp() public {
        // Create contracts used in tests
        rejector = new EtherRejector();
        game = new OddsAndEvens();
        
        // Deploy second game instance with malicious owner
        vm.prank(address(rejector));
        maliciousGame = new OddsAndEvens();
    }

    function test_PayoutRevertLeavesEtherStuck() public {
        // Fund players
        vm.deal(player1, 1 ether);
        vm.deal(address(rejector), 1 ether);

        // Record initial state
        console2.log("--- BEFORE-Trigger Plays ---");
        uint256 gameBalanceBefore = address(game).balance;
        (uint256 winsRejectorBefore,) = game.getPlayerStats(address(rejector));
        uint256 totalWinnersBefore = game.totalWinners();
        uint256 totalGamesBefore = game.totalGames();
        
        console2.log("Game contract balance:", gameBalanceBefore);
        console2.log("Rejector wins:", winsRejectorBefore);
        console2.log("Total winners:", totalWinnersBefore);
        console2.log("Total games:", totalGamesBefore);

        // Player1 makes a valid play
        console2.log("--- Trigger: player1 plays ---");
        vm.prank(player1);
        game.play{value: 1 ether}(1);

        // Rejector contract acts as malicious player
        console2.log("--- Trigger: rejector plays ---");
        vm.prank(address(rejector));
        game.play{value: 1 ether}(2);

        // Record after state
        console2.log("--- AFTER-Trigger Plays ---");
        uint256 gameBalanceAfter = address(game).balance;
        (uint256 winsRejectorAfter,) = game.getPlayerStats(address(rejector));
        uint256 totalWinnersAfter = game.totalWinners();
        uint256 totalGamesAfter = game.totalGames();
        
        console2.log("Game contract balance:", gameBalanceAfter);
        console2.log("Rejector wins:", winsRejectorAfter);
        console2.log("Total winners:", totalWinnersAfter);
        console2.log("Total games:", totalGamesAfter);
        
        // Log state changes
        console2.log("Balance change:", gameBalanceAfter - gameBalanceBefore);
        console2.log("Rejector wins change:", winsRejectorAfter - winsRejectorBefore);
        console2.log("Total winners change:", totalWinnersAfter - totalWinnersBefore);
        console2.log("Total games change:", totalGamesAfter - totalGamesBefore);

        // Existing assertions
        assertEq(address(game).balance, 2 ether, "Ether should remain stuck in contract");
        (uint256 wins,) = game.getPlayerStats(address(rejector));
        assertEq(wins, 1, "Win count should increment despite failed payout");

        // Final vulnerability verification
        bool etherStuck = gameBalanceAfter == gameBalanceBefore + 2 ether;
        bool statsUpdated = winsRejectorAfter == winsRejectorBefore + 1 &&
                           totalWinnersAfter == totalWinnersBefore + 1 &&
                           totalGamesAfter == totalGamesBefore + 2;
        
        if (etherStuck && statsUpdated) {
            console2.log("Vulnerability Exists: Failed payout didn't revert state changes and left ether stuck");
        } else {
            console2.log("Vulnerability not Exist: Ether not stuck or state not updated as expected");
        }
    }

    function test_OwnerWithdrawRevertLeavesEtherStuck() public {
        // Fund malicious contract
        vm.deal(address(maliciousGame), 2 ether);

        // Record initial state
        console2.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 maliciousBalanceBefore = address(maliciousGame).balance;
        console2.log("MaliciousGame balance:", maliciousBalanceBefore);

        // Attempt withdrawal
        console2.log("--- Trigger: owner withdrawal attempt ---");
        vm.prank(address(rejector));
        maliciousGame.getProfit();

        // Record after state
        console2.log("--- AFTER-Trigger Withdrawal ---");
        uint256 maliciousBalanceAfter = address(maliciousGame).balance;
        console2.log("MaliciousGame balance:", maliciousBalanceAfter);
        
        // Log balance change
        console2.log("Balance change:", maliciousBalanceAfter - maliciousBalanceBefore);

        // Existing assertion
        assertEq(address(maliciousGame).balance, 2 ether, "Ether should remain stuck after failed owner withdrawal");

        // Final vulnerability verification
        if (maliciousBalanceAfter == maliciousBalanceBefore) {
            console2.log("Vulnerability Exists: Failed owner withdrawal left ether stuck in contract");
        } else {
            console2.log("Vulnerability not Exist: Balance changed during failed withdrawal");
        }
    }
}