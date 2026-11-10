// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mishandled.sol";

contract RevertingReceiver {
    // Always reverts - requires more gas than send() provides
    receive() external payable {
        require(false, "Receive failed");
    }
}

contract SendBackTest is Test {
    SendBack public sendBack;
    RevertingReceiver public revertingReceiver;
    address user = address(0x69);

    function setUp() public {
        sendBack = new SendBack();
        revertingReceiver = new RevertingReceiver();
        
        // Fund testing addresses
        vm.deal(address(revertingReceiver), 1 ether);
        vm.deal(user, 1 ether);
    }

    function testUncheckedSendFailure() public {
        // Execute deposit through reverting receiver
        vm.prank(address(revertingReceiver));
        sendBack.deposit{value: 1 ether}();

        // Pre-withdrawal checks
        assertEq(address(sendBack).balance, 1 ether, "Initial deposit failed");

        console.log("--- BEFORE-Trigger State ---");
        uint256 userBalanceBefore = sendBack.userBalances(address(revertingReceiver));
        uint256 totalWithdrawalsBefore = sendBack.totalWithdrawals();
        uint256 contractBalanceBefore = address(sendBack).balance;
        uint256 receiverBalanceBefore = address(revertingReceiver).balance;
        
        console.log("    userBalances (revertingReceiver):", userBalanceBefore);
        console.log("    totalWithdrawals                 :", totalWithdrawalsBefore);
        console.log("    Contract ETH balance             :", contractBalanceBefore);
        console.log("    Receiver ETH balance             :", receiverBalanceBefore);

        console.log("--- Trigger: withdrawBalance ---");
        // Attempt withdrawal - should fail silently
        vm.prank(address(revertingReceiver));
        sendBack.withdrawBalance();

        console.log("--- AFTER-Trigger State ---");
        uint256 userBalanceAfter = sendBack.userBalances(address(revertingReceiver));
        uint256 totalWithdrawalsAfter = sendBack.totalWithdrawals();
        uint256 contractBalanceAfter = address(sendBack).balance;
        uint256 receiverBalanceAfter = address(revertingReceiver).balance;
        
        console.log("    userBalances (revertingReceiver):", userBalanceAfter);
        console.log("    totalWithdrawals                 :", totalWithdrawalsAfter);
        console.log("    Contract ETH balance             :", contractBalanceAfter);
        console.log("    Receiver ETH balance             :", receiverBalanceAfter);

        // Post-withdrawal assertions
        assertEq(
            address(revertingReceiver).balance, 
            0, 
            "Receiver should get no Ether"
        );
        assertEq(
            address(sendBack).balance, 
            1 ether, 
            "Contract must retain locked funds"
        );

        // Vulnerability exists if: 
        // 1. User's contract balance reset to 0 (state change)
        // 2. Total withdrawals increased by 1 ether (state change)
        // 3. ETH remained in contract (no actual transfer)
        // 4. Receiver balance unchanged (ETH not received)
        bool vulnerabilityExists = 
            (userBalanceAfter == 0) &&
            (totalWithdrawalsAfter == totalWithdrawalsBefore + 1 ether) &&
            (contractBalanceAfter == contractBalanceBefore) &&
            (receiverBalanceAfter == receiverBalanceBefore);

        // Conditional final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State changed despite failed ETH transfer");
        } else {
            console.log("Vulnerability not Exist: State changes inconsistent with vulnerability behavior");
        }
    }

    // Remain unchanged (comparison test)
    function testValidWithdrawalForComparison() public {
        vm.prank(user);
        sendBack.deposit{value: 1 ether}();

        vm.prank(user);
        sendBack.withdrawBalance();

        assertGt(
            user.balance, 
            0, 
            "Valid user didn't receive funds"
        );
    }
}