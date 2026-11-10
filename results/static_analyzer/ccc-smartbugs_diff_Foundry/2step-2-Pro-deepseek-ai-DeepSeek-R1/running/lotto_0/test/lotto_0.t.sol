// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract MaliciousReceiver {
    receive() external payable {
        revert();
    }
}

contract LottoTest is Test {
    Lotto public lotto;
    MaliciousReceiver public maliciousWinner;
    MaliciousReceiver public maliciousWithdrawer;

    function setUp() public {
        lotto = new Lotto();
        maliciousWinner = new MaliciousReceiver();
        maliciousWithdrawer = new MaliciousReceiver();
    }

    function testSendToWinnerFailsSilently() public {
        // Fund contract and set malicious winner
        vm.deal(address(lotto), 1 ether);
        lotto.setWinner(address(maliciousWinner), 1 ether);

        console.log("=== BEGIN SendToWinner Test ===");
        console.log("--- BEFORE sendToWinner ---");
        console.log("Contract Balance (Before):", address(lotto).balance);
        console.log("Winner Balance  (Before):", address(maliciousWinner).balance);
        console.log("payedOut (Before):", lotto.payedOut());
        uint initialContractBalance = address(lotto).balance;

        console.log("--- EXECUTING sendToWinner ---");
        // This call should fail internally but not revert
        lotto.sendToWinner();

        console.log("--- AFTER sendToWinner ---");
        console.log("Contract Balance (After):", address(lotto).balance);
        console.log("Winner Balance  (After):", address(maliciousWinner).balance);
        console.log("payedOut (After):", lotto.payedOut());
        uint finalContractBalance = address(lotto).balance;

        // State assertions
        assertEq(lotto.payedOut(), true, "payedOut should be true after failed transfer");
        assertEq(address(maliciousWinner).balance, 0, "Winner should not receive funds");
        assertEq(finalContractBalance, initialContractBalance, "Contract balance should remain unchanged");
        
        console.log("=== VERDICT ===");
        if (finalContractBalance == initialContractBalance && lotto.payedOut()) {
            console.log("Vulnerability Exists: Contract state updated to paid despite failed transfer");
        } else {
            console.log("Vulnerability not Exist: Contract state changed consistently with operation outcome");
        }
    }

    function testWithdrawLeftOverFailsSilently() public {
        // Setup complete paid state
        address winner = address(0x123);
        lotto.setWinner(winner, 0.5 ether);
        vm.deal(address(lotto), 1 ether);
        lotto.sendToWinner();
        
        console.log("\n=== BEGIN WithdrawLeftOver Test ===");
        console.log("--- BEFORE withdrawLeftOver ---");
        uint initialContractBalance = address(lotto).balance;
        uint initialMaliciousBalance = address(maliciousWithdrawer).balance;
        console.log("Contract Balance (Before):", initialContractBalance);
        console.log("Malicious Address Balance (Before):", initialMaliciousBalance);

        console.log("--- EXECUTING withdrawLeftOver ---");
        // Attempt withdrawal to malicious contract
        vm.prank(address(maliciousWithdrawer));
        lotto.withdrawLeftOver();

        console.log("--- AFTER withdrawLeftOver ---");
        uint finalContractBalance = address(lotto).balance;
        uint finalMaliciousBalance = address(maliciousWithdrawer).balance;
        console.log("Contract Balance (After):", finalContractBalance);
        console.log("Malicious Address Balance (After):", finalMaliciousBalance);
        
        // Withdrawal failed silently - balances unchanged
        assertEq(finalContractBalance, initialContractBalance, "Contract balance should remain");
        assertEq(finalMaliciousBalance, initialMaliciousBalance, "Malicious recipient shouldn't receive funds");
        
        console.log("=== VERDICT ===");
        if (finalContractBalance == initialContractBalance && finalMaliciousBalance == initialMaliciousBalance) {
            console.log("Vulnerability Exists: Withdrawal failed silently without updating state");
        } else {
            console.log("Vulnerability not Exist: State changed consistently with operation outcome");
        }
    }
}