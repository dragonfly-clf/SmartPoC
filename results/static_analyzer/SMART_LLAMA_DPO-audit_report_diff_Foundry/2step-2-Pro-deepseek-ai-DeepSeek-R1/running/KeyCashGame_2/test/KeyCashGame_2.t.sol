// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract MockEarningPlatform {
    uint256 public received;
    
    function deposit() external payable {
        received += msg.value;
    }
}

contract KeyCashGameTest is Test {
    KeyCashGame game;
    MockEarningPlatform platform;
    address owner = address(0x1);
    address player1 = address(0x2);
    address player2 = address(0x3);

    function setUp() public {
        // Setup funding
        vm.deal(owner, 100 ether);
        vm.deal(player1, 100 ether);
        vm.deal(player2, 100 ether);
        
        // Deploy contracts
        vm.startPrank(owner);
        platform = new MockEarningPlatform();
        game = new KeyCashGame();
        
        // Configure game
        game.updateRoundPeiod(86400);
        game.setPrizePoolShare(50, 30, 10, 10);
        game.setTicketPriceShare(50, 30, 20);
        game.setStartPrice(0.001 ether);
        game.setIncreasePricePerTicket(0);
        game.setMaxKeysPerTx(10);
        game.updateEarningPlatform(address(platform));
        game.startGame();
        vm.stopPrank();
    }

    function test_IDUniquenessVulnerability() public {
        // Player1 buys tickets in round 1
        vm.prank(player1);
        game.buyTickets{value: 0.002 ether}(2);
        
        // End round 1
        vm.warp(block.timestamp + 86400 + 1);
        
        // Player2 starts round 2 by buying tickets
        vm.prank(player2);
        game.buyTickets{value: 0.001 ether}(1);
        
        // Player1 buys again in round 2
        vm.prank(player1);
        game.buyTickets{value: 0.002 ether}(2);
        
        console.log("--- BEFORE-Trigger (Claimable Amount) ---");
        uint256 preClaimAmount = game.getClaimable(player1);
        console.log("Claimable amount for player1:", preClaimAmount);
        assertGt(preClaimAmount, 0, "Claimable amount expected before claiming");
        
        console.log("--- Trigger Claim ---");
        // Player1 claims - should set claimed flags
        vm.prank(player1);
        game.claim();
        
        console.log("--- AFTER-Trigger (Claimable Amount) ---");
        uint256 postClaimAmount = game.getClaimable(player1);
        console.log("Claimable amount for player1:", postClaimAmount);
        
        // Vulnerability verification
        if (postClaimAmount > 0) {
            console.log("Vulnerability Exists: Claimable amount did not reset to zero after claiming");
        } else {
            console.log("Vulnerability not Exist: Claimable amount became zero");
        }
    }
}