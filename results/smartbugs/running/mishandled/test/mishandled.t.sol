// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mishandled.sol";

contract SendBackTest is Test {
    SendBack public sendBack;
    address payable user = payable(address(0x123));
    address payable contractWithoutFallback = payable(address(0x456));

    function setUp() public {
        sendBack = new SendBack();
        
        // Fund the user and contract
        vm.deal(user, 1 ether);
        vm.deal(address(sendBack), 1 ether);
        vm.deal(contractWithoutFallback, 0 ether);
    }

    function testUncheckedSendVulnerability() public {
        // Step 1: Deposit from contractWithoutFallback
        vm.deal(contractWithoutFallback, 0.5 ether);
        vm.prank(contractWithoutFallback);
        sendBack.deposit{value: 0.5 ether}();

        // Make contractWithoutFallback unable to receive ETH
        vm.etch(contractWithoutFallback, hex"00");

        // === Before Action ===
        console.log("--- BEFORE-Trigger Withdraw Operation ---");
        uint256 beforeContractEthBalance = address(sendBack).balance;
        uint256 beforeTargetEthBalance = contractWithoutFallback.balance;
        uint256 beforeUserBalanceInContract = sendBack.userBalances(contractWithoutFallback);
        uint256 beforeTotalWithdrawals = sendBack.totalWithdrawals();

        console.log("Contract ETH balance: %d", beforeContractEthBalance);
        console.log("Target contract ETH balance: %d", beforeTargetEthBalance);
        console.log("Target user balance in contract: %d", beforeUserBalanceInContract);
        console.log("Total withdrawals: %d", beforeTotalWithdrawals);

        // === Trigger Action ===
        console.log("--- Trigger WithdrawBalance Operation ---");
        vm.prank(contractWithoutFallback);
        sendBack.withdrawBalance();

        // === After Action ===
        console.log("--- AFTER-Trigger Withdraw Operation ---");
        uint256 afterContractEthBalance = address(sendBack).balance;
        uint256 afterTargetEthBalance = contractWithoutFallback.balance;
        uint256 afterUserBalanceInContract = sendBack.userBalances(contractWithoutFallback);
        uint256 afterTotalWithdrawals = sendBack.totalWithdrawals();

        console.log("Contract ETH balance: %d", afterContractEthBalance);
        console.log("Target contract ETH balance: %d", afterTargetEthBalance);
        console.log("Target user balance in contract: %d", afterUserBalanceInContract);
        console.log("Total withdrawals: %d", afterTotalWithdrawals);

        // === Vulnerability Check ===
        bool stateUpdated = afterUserBalanceInContract == 0 && 
                            afterTotalWithdrawals == beforeTotalWithdrawals + beforeUserBalanceInContract;
        bool ethTransferFailed = afterTargetEthBalance == beforeTargetEthBalance;
        bool vulnerabilityExists = stateUpdated && ethTransferFailed;

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: ETH transfer failed but contract state was incorrectly updated");
        } else {
            console.log("Vulnerability not Exist: Contract either updated state correctly or failed to update state");
        }
    }

    function testProperSendHandling() public {
        // Simulate user depositing funds
        vm.prank(user);
        sendBack.deposit{value: 0.5 ether}();

        // Verify initial balance
        assertEq(address(sendBack).balance, 1.5 ether);

        // Withdraw to a regular address (should succeed)
        uint256 initialUserBalance = user.balance;
        vm.prank(user);
        sendBack.withdrawBalance();

        // Check that the state was updated correctly
        // Contract balance should be reduced by withdrawn amount (1.5 - 0.5 = 1 ether)
        assertEq(address(sendBack).balance, 1 ether);
        
        // User balance should be original 1 ether + withdrawn 0.5 ether = 1.5 ether
        assertEq(user.balance, initialUserBalance + 0.5 ether);
    }
}