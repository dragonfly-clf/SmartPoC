// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract Reverter {
    fallback() external payable {
        revert("Reverter: payment rejected");
    }
}

contract LottoTest is Test {
    Lotto public lotto;
    Reverter public reverter;
    uint256 constant WIN_AMOUNT = 1 ether;

    function setUp() public {
        lotto = new Lotto();
        reverter = new Reverter();

        // Set winner to a contract that rejects payments
        lotto.setWinner(address(reverter), WIN_AMOUNT);
        
        // Fund the lotto contract
        deal(address(lotto), WIN_AMOUNT);
    }

    function test_sendToWinner_IgnoresTransferFailure() public {
        console.log("--- BEFORE-Trigger State ---");
        // Capture state before payment
        bool payedOutBefore = lotto.payedOut();
        uint256 lottoBalanceBefore = address(lotto).balance;
        uint256 winnerBalanceBefore = address(reverter).balance;
        
        console.log("payedOut state: %s", payedOutBefore ? "true" : "false");
        console.log("Lotto contract ETH balance: %d", lottoBalanceBefore);
        console.log("Winner contract ETH balance: %d", winnerBalanceBefore);

        console.log("--- Trigger Operation: sendToWinner() ---");
        // Attempt to pay winner (expected to fail)
        lotto.sendToWinner();
        
        console.log("--- AFTER-Trigger State ---");
        // Capture state after payment attempt
        bool payedOutAfter = lotto.payedOut();
        uint256 lottoBalanceAfter = address(lotto).balance;
        uint256 winnerBalanceAfter = address(reverter).balance;
        
        console.log("payedOut state: %s", payedOutAfter ? "true" : "false");
        console.log("Lotto contract ETH balance: %d", lottoBalanceAfter);
        console.log("Winner contract ETH balance: %d", winnerBalanceAfter);
        
        console.log("--- Verification ---");
        console.log("DIFF: payedOut changed: %s", payedOutAfter != payedOutBefore ? "YES" : "NO");
        console.log("RESULT: State update on failed transfer: %s", 
            payedOutBefore != payedOutAfter ? "SUCCESSFUL" : "FAILED");

        // Determine vulnerability existence
        if (payedOutAfter) {
            console.log("Vulnerability Exists: payedOut state was updated to true even though transfer reverted");
        } else {
            console.log("Vulnerability not Exist: payedOut state remains false after transfer revert");
        }
    }
}