// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract KeyCashGameTest is Test {
    KeyCashGame game;
    address owner = address(0x1);
    address player1 = address(0x2);
    address earningPlatform = address(0x4);
    
    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(player1, 10 ether);
        
        vm.startPrank(owner);
        game = new KeyCashGame();
        game.setTicketPriceShare(40, 40, 20);        // Prize pool, player div, platform
        game.setPrizePoolShare(60, 20, 10, 10);      // Prize, next round, players, platform
        game.updateEarningPlatform(earningPlatform);
        game.setStartPrice(0.1 ether);
        game.setIncreaseTimePerTicket(1);
        game.setNumberTicketToDecreaseAdditonalTime(1000);
        game.updateRoundPeiod(1 hours);
        game.setMaxKeysPerTx(10);
        game.startGame();
        vm.stopPrank();
    }

    function testDivisionByZeroOnRoundCloseWithNoTickets() public {
        // Advance time beyond initial round period
        vm.warp(block.timestamp + 1 hours + 1);

        console.log("--- BEFORE-Trigger State ---");
        // State snapshot: Not applicable (no state changes from vulnerability)

        console.log("--- Trigger Attempted BuyTickets ---");
        bool vulnerabilityExists = false;
        vm.prank(player1);
        try game.buyTickets{value: 0.1 ether}(1) {
            // Transaction succeeded (no revert) → vulnerability not triggered 
        } catch (bytes memory reason) {
            // Check for Panic(uint256) with code=0x12 (division by zero)
            if (reason.length == 36) {
                bytes4 selector;
                uint256 panicCode;
                assembly {
                    selector := mload(add(reason, 0x20))
                    panicCode := mload(add(reason, 0x24))
                }
                if (selector == 0x4e487b71 && panicCode == 0x12) {
                    vulnerabilityExists = true;
                    console.log("Division by zero panic detected");
                }
            }
        }

        console.log("--- AFTER-Trigger State ---");
        // State snapshot: Not applicable (no state changes from vulnerability)

        // Final Verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Division by zero panic during round close");
        } else {
            console.log("Vulnerability not Exist: Transaction did not revert with division by zero");
        }
    }
}