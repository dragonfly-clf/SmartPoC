// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mishandled.sol";

contract MaliciousReceiver {
    receive() external payable {
        revert("MaliciousReceiver rejects payments");
    }
}

contract SendBackTest is Test {
    SendBack public sendBack;
    MaliciousReceiver public maliciousReceiver;
    
    function setUp() public {
        sendBack = new SendBack();
        maliciousReceiver = new MaliciousReceiver();
    }

    function test_MissingReturnValueCheck() public {
        // Fund the malicious receiver contract with 1 ether
        vm.deal(address(maliciousReceiver), 1 ether);
        
        // MaliciousReceiver deposits 1 ether to create a balance
        vm.prank(address(maliciousReceiver));
        sendBack.deposit{value: 1 ether}();
        
        // Pre-withdrawal state checks
        uint256 preWithdrawUserBalance = sendBack.userBalances(address(maliciousReceiver));
        uint256 preWithdrawContractBalance = address(sendBack).balance;
        uint256 preWithdrawContractReportedBalance = sendBack.getContractBalance();
        uint256 preWithdrawReceiverBalance = address(maliciousReceiver).balance;
        uint256 preTotalWithdrawals = sendBack.totalWithdrawals();
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("User Balance (SendBack):", preWithdrawUserBalance);
        console2.log("Contract ETH Balance:", preWithdrawContractBalance);
        console2.log("getContractBalance():", preWithdrawContractReportedBalance);
        console2.log("MaliciousReceiver ETH Balance:", preWithdrawReceiverBalance);
        console2.log("Total Withdrawals:", preTotalWithdrawals);

        // Attempt withdrawal from malicious contract (will fail)
        console2.log("--- Trigger Withdrawal ---");
        vm.prank(address(maliciousReceiver));
        sendBack.withdrawBalance();  // Returns false, but doesn't revert!

        // Post-withdrawal state checks
        uint256 postWithdrawUserBalance = sendBack.userBalances(address(maliciousReceiver));
        uint256 postWithdrawContractBalance = address(sendBack).balance;
        uint256 postWithdrawContractReportedBalance = sendBack.getContractBalance();
        uint256 postWithdrawReceiverBalance = address(maliciousReceiver).balance;
        uint256 postTotalWithdrawals = sendBack.totalWithdrawals();
        
        console2.log("--- AFTER-Trigger State ---");
        console2.log("User Balance (SendBack):", postWithdrawUserBalance);
        console2.log("Contract ETH Balance:", postWithdrawContractBalance);
        console2.log("getContractBalance():", postWithdrawContractReportedBalance);
        console2.log("MaliciousReceiver ETH Balance:", postWithdrawReceiverBalance);
        console2.log("Total Withdrawals:", postTotalWithdrawals);
        
        // Vulnerability verification
        console2.log("--- Vulnerability Analysis ---");
        bool userBalanceReset = (postWithdrawUserBalance == 0);
        bool ethStillInContract = (postWithdrawContractBalance == 1 ether);
        bool incorrectAccounting = (postWithdrawContractReportedBalance == 1 ether);
        bool receiverFundsMissing = (postWithdrawReceiverBalance == 0);
        bool withdrawalsUnchanged = (postTotalWithdrawals == preTotalWithdrawals);
        
        console2.log("User balance reset to 0:", userBalanceReset);
        console2.log("ETH still in contract:", ethStillInContract);
        console2.log("Contract shows same balance:", incorrectAccounting);
        console2.log("Receiver got no funds:", receiverFundsMissing);
        console2.log("Total withdrawals unchanged:", withdrawalsUnchanged);

        bool vulnerabilityExists = userBalanceReset &&
                                   ethStillInContract &&
                                   incorrectAccounting &&
                                   receiverFundsMissing &&
                                   withdrawalsUnchanged;

        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Funds were trapped and state was incorrectly updated after failed transfer");
        } else {
            console2.log("Vulnerability not Exist: Withdrawal failed and state was preserved correctly");
        }
    }
}