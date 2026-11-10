// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

contract PoCGameTest is Test {
    PoCGame game;
    address owner = address(0x10);
    address whale = address(0x15);
    address player = address(0x20);
    uint256 wagerLimit = 1 ether;
    uint256 difficulty = 100; // Non-zero value to prevent division by zero

    function setUp() public {
        vm.startPrank(owner, owner);
        game = new PoCGame(whale, wagerLimit);
        game.AdjustDifficulty(difficulty);
        game.OpenToThePublic();
        vm.stopPrank();

        vm.deal(player, 10 ether);
    }

    function testPlayerCanPlayRepeatedly() public {
        // Initial wager
        vm.prank(player, player);
        game.wager{value: wagerLimit}();
        assertTrue(game.hasPlayerWagered(player), "Should have initial wager");

        // Advance blocks for timestamp condition
        vm.roll(block.number + 1);
        
        // First play - clears player state
        vm.prank(player, player);
        game.play();
        assertFalse(game.hasPlayerWagered(player), "Wager should be cleared");

        // Immediately wager again
        vm.prank(player, player);
        game.wager{value: wagerLimit}();
        assertTrue(game.hasPlayerWagered(player), "Should have second wager");

        // Advance blocks again
        vm.roll(block.number + 1);
        
        // Second play - should succeed
        vm.prank(player, player);
        game.play();
        assertFalse(game.hasPlayerWagered(player), "Wager should be cleared again");
        
        // Final verdict - reached only if test passes
        console.log("Vulnerability Exists: Player successfully executed repeated wagers/plays with block advancement");
    }
}