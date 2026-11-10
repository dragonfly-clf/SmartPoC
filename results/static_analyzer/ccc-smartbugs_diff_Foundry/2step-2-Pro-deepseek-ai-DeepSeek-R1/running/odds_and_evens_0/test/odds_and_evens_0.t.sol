// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

// Helper contract that reverts on ETH receive
contract MaliciousPlayer {
    bool public revertOnReceive;
    address public self = address(this);

    constructor(bool _revertOnReceive) {
        revertOnReceive = _revertOnReceive;
    }

    function play(address gameAddress, uint number) public payable {
        OddsAndEvens game = OddsAndEvens(gameAddress);
        game.play{value: msg.value}(number);
    }

    receive() external payable {
        if (revertOnReceive) revert("MaliciousPlayer: Revert on receive");
    }
}

// Helper contract that reverts on ETH receive for owner
contract MaliciousOwner {
    OddsAndEvens public game;

    constructor() payable {
        game = new OddsAndEvens();
    }

    function collect() public {
        game.getProfit();
    }
    
    receive() external payable {
        revert("MaliciousOwner: Revert on receive");
    }
}

contract OddsAndEvensTest is Test {
    OddsAndEvens game;
    address owner = makeAddr("owner");
    MaliciousPlayer maliciousPlayer;
    MaliciousOwner maliciousOwner;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        game = new OddsAndEvens();
        vm.stopPrank();
    }

    // Test state update when ETH transfer fails in andTheWinnerIs()
    function test_uncheckedWinnerPayout() public {
        // Create players
        address payable player1 = payable(makeAddr("player1"));
        maliciousPlayer = new MaliciousPlayer(true);
        
        // Fund players
        vm.deal(player1, 10 ether);
        vm.deal(address(maliciousPlayer), 10 ether);
        
        // Player 1 (normal player) joins with even number
        vm.startPrank(player1);
        game.play{value: 1 ether}(2); // Even number
        vm.stopPrank();
        
        console.log("--- BEFORE-Trigger WinnerPayout ---");
        // Capture state BEFORE malicious player plays
        (uint256 preWinsMalicious, ) = game.getPlayerStats(address(maliciousPlayer));
        uint256 preContractBalance = address(game).balance;
        uint256 preTotalGames = game.totalGames();
        uint256 preTotalWinners = game.totalWinners();
        
        console.log("Contract Balance (pre):", preContractBalance);
        console.log("Malicious Player Wins (pre):", preWinsMalicious);
        console.log("Total Games (pre):", preTotalGames);
        console.log("Total Winners (pre):", preTotalWinners);
        
        console.log("--- Trigger: Malicious player plays and wins (expect payout revert) ---");
        // Malicious player joins with odd number (will become winner)
        vm.startPrank(address(maliciousPlayer));
        maliciousPlayer.play{value: 1 ether}(address(game), 1); // Odd number → Sum=3 → Winner is malicious
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger WinnerPayout ---");
        // Capture state AFTER malicious player plays
        (uint256 postWinsMalicious, ) = game.getPlayerStats(address(maliciousPlayer));
        uint256 postContractBalance = address(game).balance;
        uint256 postTotalGames = game.totalGames();
        uint256 postTotalWinners = game.totalWinners();
        
        console.log("Contract Balance (post):", postContractBalance);
        console.log("Malicious Player Wins (post):", postWinsMalicious);
        console.log("Total Games (post):", postTotalGames);
        console.log("Total Winners (post):", postTotalWinners);
        
        // Compare state changes
        console.log("--- Comparison ---");
        bool winsUpdated = (postWinsMalicious > preWinsMalicious);
        bool contractBalanceIncreased = (postContractBalance > preContractBalance);
        bool totalGamesUpdated = (postTotalGames > preTotalGames);
        bool totalWinnersUpdated = (postTotalWinners > preTotalWinners);
        
        console.log("Malicious Wins Updated:", winsUpdated ? "YES" : "NO");
        console.log("Contract Balance Increased:", contractBalanceIncreased ? "YES" : "NO");
        console.log("Total Games Updated:", totalGamesUpdated ? "YES" : "NO");
        console.log("Total Winners Updated:", totalWinnersUpdated ? "YES" : "NO");
        
        // Final verdict based on state update vs transfer failure
        if (winsUpdated) {
            console.log("Vulnerability Exists: State updated (player wins incremented) even though ETH transfer failed");
        } else {
            console.log("Vulnerability not Exist: No state update after payout failure");
        }
        
        // Original assertions (preserved)
        assertEq(postWinsMalicious, 1, "Win count should update despite failed payout");
        assertEq(address(game).balance, 2 ether, "Contract retains ETH after failed payout");
    }
    
    // Test state behavior when owner transfer fails in getProfit()
    function test_uncheckedProfitWithdrawal() public {
        // Create malicious owner contract
        maliciousOwner = new MaliciousOwner{value: 1 ether}();
        OddsAndEvens maliciousGame = maliciousOwner.game();
        
        // Fund game contract
        vm.deal(address(maliciousGame), 1 ether);
        
        console.log("--- BEFORE-Trigger ProfitWithdrawal ---");
        uint256 preWithdrawBalance = address(maliciousGame).balance;
        console.log("Contract Balance (pre):", preWithdrawBalance);
        
        console.log("--- Trigger: Owner attempts to withdraw profit (expect revert) ---");
        // Attempt to collect profit
        vm.prank(address(maliciousOwner));
        maliciousOwner.collect();
        
        console.log("--- AFTER-Trigger ProfitWithdrawal ---");
        uint256 postWithdrawBalance = address(maliciousGame).balance;
        console.log("Contract Balance (post):", postWithdrawBalance);
        
        // Compare state changes
        console.log("--- Comparison ---");
        bool balanceUnchanged = (postWithdrawBalance == preWithdrawBalance);
        console.log("Contract Balance Unchanged:", balanceUnchanged ? "YES" : "NO");
        
        // Final verdict based on transfer failure
        if (balanceUnchanged) {
            console.log("Vulnerability Exists: ETH transfer to owner failed resulting in locked funds");
        } else {
            console.log("Vulnerability not Exist: Withdrawal completed successfully");
        }
        
        // Original assertion (preserved)
        assertEq(address(maliciousGame).balance, 1 ether, "Contract retains ETH after failed owner withdrawal");
    }
}