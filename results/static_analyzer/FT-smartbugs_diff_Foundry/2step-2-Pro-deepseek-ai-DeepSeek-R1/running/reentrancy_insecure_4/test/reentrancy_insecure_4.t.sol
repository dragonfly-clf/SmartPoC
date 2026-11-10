// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_insecure.sol";

// Helper contract that always reverts when receiving Ether
contract ContractRevertingOnReceive {
    receive() external payable {
        revert("Intentionally reverting on receive");
    }

    function deposit(Reentrancy_insecure target) public payable {
        (bool success, ) = address(target).call{value: msg.value}(
            abi.encodeCall(target.deposit, ())
        );
        require(success, "Deposit failed");
    }
}

contract ReentrancyInsecure_DoS_Test is Test {
    Reentrancy_insecure public vulnerableContract;
    ContractRevertingOnReceive public failedReceiver;

    function setUp() public {
        vulnerableContract = new Reentrancy_insecure();
        failedReceiver = new ContractRevertingOnReceive();
        vm.deal(address(failedReceiver), 10 ether);
    }

    function test_WithdrawRevertsWhenReceiveFails() public {
        // Make deposit from helper contract
        vm.prank(address(failedReceiver));
        failedReceiver.deposit{value: 1 ether}(vulnerableContract);

        // Verify deposit was recorded
        assertEq(
            vulnerableContract.getBalance(address(failedReceiver)),
            1 ether,
            "Deposit not recorded"
        );

        // --- BEFORE STATE SNAPSHOT ---
        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore = vulnerableContract.getBalance(address(failedReceiver));
        uint256 contractBalanceBefore = address(vulnerableContract).balance;
        console.log("User (failedReceiver) balance before: ", userBalanceBefore);
        console.log("Contract (vulnerableContract) balance before: ", contractBalanceBefore);

        // --- TRIGGER WITHDRAWAL ---
        console.log("--- Trigger Withdrawal ---");
        vm.prank(address(failedReceiver));
        vm.expectRevert(); // Expect general revert from require(success)
        vulnerableContract.withdrawBalance();

        // --- AFTER STATE SNAPSHOT ---
        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter = vulnerableContract.getBalance(address(failedReceiver));
        uint256 contractBalanceAfter = address(vulnerableContract).balance;
        console.log("User (failedReceiver) balance after: ", userBalanceAfter);
        console.log("Contract (vulnerableContract) balance after: ", contractBalanceAfter);

        // Check if state has remained unchanged
        bool userBalanceEqual = (userBalanceBefore == userBalanceAfter);
        bool contractBalanceEqual = (contractBalanceBefore == contractBalanceAfter);
        bool stateUnchanged = userBalanceEqual && contractBalanceEqual;
        
        console.log("State comparison - User balance unchanged: ", userBalanceEqual ? "YES" : "NO");
        console.log("State comparison - Contract balance unchanged: ", contractBalanceEqual ? "YES" : "NO");
        console.log("Overall state unchanged: ", stateUnchanged ? "YES" : "NO");

        // Final vulnerability verdict
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Funds locked due to failed transfer and state remains unchanged");
        } else {
            console.log("Vulnerability not Exist: State changed during withdrawal processing");
        }

        // Verify funds remain locked (existing assertions)
        assertEq(
            vulnerableContract.getBalance(address(failedReceiver)),
            1 ether,
            "Balance should remain after failed withdrawal"
        );
        assertEq(
            address(vulnerableContract).balance,
            1 ether,
            "Contract balance should remain unchanged"
        );
    }
}