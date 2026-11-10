// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb7c5c5aa4d42967efe906e1b66cb8df9cebf04f7.sol";

contract FailingReceiver {
    bool public failTransfer = true;

    function setFailTransfer(bool _fail) external {
        failTransfer = _fail;
    }

    receive() external payable {
        if (failTransfer) {
            revert("Transfer failed");
        }
    }
}

contract KeepMyEtherWithdrawTest is Test {
    keepMyEther public token;
    FailingReceiver public failingReceiver;
    address public normalUser;
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;

    event Withdrawal(address indexed user, uint256 amount);

    function setUp() public {
        token = new keepMyEther();
        failingReceiver = new FailingReceiver();
        normalUser = address(0x1);

        vm.deal(address(failingReceiver), DEPOSIT_AMOUNT);
        vm.deal(normalUser, DEPOSIT_AMOUNT);

        // Setup deposits - check return values to avoid warnings
        vm.prank(normalUser);
        (bool success1, ) = address(token).call{value: DEPOSIT_AMOUNT}("");
        require(success1, "Normal user deposit failed");

        vm.prank(address(failingReceiver));
        (bool success2, ) = address(token).call{value: DEPOSIT_AMOUNT}("");
        require(success2, "Failing receiver deposit failed");
    }

    function testWithdrawFailureLeavesBalanceUnchanged() public {
        // Pre-trigger state capture
        console.log("--- BEFORE-Trigger User Stats ---");
        (uint256 userBalanceBefore, ) = token.getUserStats(address(failingReceiver));
        uint256 tokenEthBalanceBefore = address(token).balance;
        uint256 totalWithdrawalsBefore = token.totalWithdrawals();
        console.log("User Balance Before:", userBalanceBefore);
        console.log("Contract ETH Balance Before:", tokenEthBalanceBefore);
        console.log("Total Withdrawals Before:", totalWithdrawalsBefore);

        console.log("--- Trigger Withdrawal (expect revert) ---");
        // Attempt withdrawal from failing receiver - expect revert without data
        vm.expectRevert();
        vm.prank(address(failingReceiver));
        token.withdraw();

        // Post-trigger state capture
        console.log("--- AFTER-Trigger User Stats ---");
        (uint256 userBalanceAfter, ) = token.getUserStats(address(failingReceiver));
        uint256 tokenEthBalanceAfter = address(token).balance;
        uint256 totalWithdrawalsAfter = token.totalWithdrawals();
        console.log("User Balance After:", userBalanceAfter);
        console.log("Contract ETH Balance After:", tokenEthBalanceAfter);
        console.log("Total Withdrawals After:", totalWithdrawalsAfter);

        // Differential validation
        bool noStateChange = 
            userBalanceBefore == userBalanceAfter &&
            tokenEthBalanceBefore == tokenEthBalanceAfter &&
            totalWithdrawalsBefore == totalWithdrawalsAfter;
        
        if (noStateChange) {
            console.log("Vulnerability not Exist: State remains consistent after failed withdrawal");
        } else {
            console.log("Vulnerability Exists: State changed unexpectedly during failed withdrawal");
        }

        // Assertions to verify vulnerability state
        assertEq(userBalanceAfter, DEPOSIT_AMOUNT, "Balance should remain after failed withdrawal");
        assertEq(totalWithdrawalsAfter, totalWithdrawalsBefore, "Total withdrawals should not change");
    }

    function testSuccessfulWithdrawClearsBalance() public {
        // [Original test remains unchanged]
        // Configure receiver to succeed
        failingReceiver.setFailTransfer(false);

        // Expect withdrawal event
        vm.expectEmit(true, true, false, true);
        emit Withdrawal(address(failingReceiver), DEPOSIT_AMOUNT);

        vm.prank(address(failingReceiver));
        token.withdraw();

        // Verify state changes
        (uint256 failReceiverBalance, ) = token.getUserStats(address(failingReceiver));
        assertEq(failReceiverBalance, 0, "Balance should be zero after withdrawal");
        assertEq(address(failingReceiver).balance, DEPOSIT_AMOUNT, "Receiver should have funds");
    }
}