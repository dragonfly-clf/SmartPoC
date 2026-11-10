// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x93c32845fae42c83a70e5f06214c8433665c2ab5.sol";

contract TimestampVulnerabilityTest is Test {
    X_WALLET public wallet;
    Log public logInst;
    address user = makeAddr("user");
    
    function setUp() public {
        logInst = new Log();
        wallet = new X_WALLET(address(logInst));
        vm.deal(user, 10 ether);
    }

    // Test shows collection fails at exact unlock time
    function testCollectFailsAtExactUnlockTime() public {
        uint256 depositAmount = 1 ether;
        uint256 unlockTime = block.timestamp + 7 days;

        // Deposit funds
        vm.prank(user);
        wallet.Put{value: depositAmount}(unlockTime);

        // Advance to exact unlock time
        vm.warp(unlockTime);
        
        // Record states before Collect
        console.log("--- BEFORE-Trigger Collect ---");
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 userBalanceBefore = user.balance;
        (, uint256 internalDepositBefore) = wallet.Acc(user);
        console.log("Contract balance (before):", contractBalanceBefore);
        console.log("User balance (before):", userBalanceBefore);
        console.log("Internal deposited amount (before):", internalDepositBefore);

        // Attempt withdrawal
        console.log("--- Trigger Collect ---");
        vm.prank(user);
        wallet.Collect(depositAmount);

        // Record states after Collect
        console.log("--- AFTER-Trigger Collect ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 userBalanceAfter = user.balance;
        (, uint256 internalDepositAfter) = wallet.Acc(user);
        console.log("Contract balance (after):", contractBalanceAfter);
        console.log("User balance (after):", userBalanceAfter);
        console.log("Internal deposited amount (after):", internalDepositAfter);

        // Compare states - all balances should remain unchanged
        bool contractBalanceUnchanged = contractBalanceAfter == contractBalanceBefore;
        bool userBalanceUnchanged = userBalanceAfter == userBalanceBefore;
        bool internalDepositUnchanged = internalDepositAfter == internalDepositBefore;
        console.log("Contract balance unchanged:", contractBalanceUnchanged);
        console.log("User balance unchanged:", userBalanceUnchanged);
        console.log("Internal deposited amount unchanged:", internalDepositUnchanged);

        // Final verdict
        if (contractBalanceUnchanged && userBalanceUnchanged && internalDepositUnchanged) {
            console.log("Vulnerability Exists: Withdrawal blocked at exact unlock time despite accounting showing funds available");
        } else {
            console.log("Vulnerability not Exist: Funds moved unexpectedly at exact unlock time");
        }
    }

    // Test shows successful collection after unlock time
    function testCollectSucceedsAfterUnlockTime() public {
        uint256 depositAmount = 1 ether;
        uint256 unlockTime = block.timestamp + 7 days;

        // Deposit funds
        vm.prank(user);
        wallet.Put{value: depositAmount}(unlockTime);

        // Advance to after unlock time
        vm.warp(unlockTime + 1 seconds);

        // Record states before Collect
        console.log("--- BEFORE-Trigger Collect ---");
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 userBalanceBefore = user.balance;
        (, uint256 internalDepositBefore) = wallet.Acc(user);
        console.log("Contract balance (before):", contractBalanceBefore);
        console.log("User balance (before):", userBalanceBefore);
        console.log("Internal deposited amount (before):", internalDepositBefore);

        // Attempt withdrawal
        console.log("--- Trigger Collect ---");
        vm.prank(user);
        wallet.Collect(depositAmount);

        // Record states after Collect
        console.log("--- AFTER-Trigger Collect ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 userBalanceAfter = user.balance;
        (, uint256 internalDepositAfter) = wallet.Acc(user);
        console.log("Contract balance (after):", contractBalanceAfter);
        console.log("User balance (after):", userBalanceAfter);
        console.log("Internal deposited amount (after):", internalDepositAfter);

        // Compare states - funds should move correctly
        bool contractBalanceReduced = contractBalanceAfter == contractBalanceBefore - depositAmount;
        bool userBalanceIncreased = userBalanceAfter == userBalanceBefore + depositAmount;
        bool internalDepositReduced = internalDepositAfter == internalDepositBefore - depositAmount;
        console.log("Contract balance reduced correctly:", contractBalanceReduced);
        console.log("User balance increased correctly:", userBalanceIncreased);
        console.log("Internal deposited amount reduced correctly:", internalDepositReduced);

        // Final verdict
        if (contractBalanceReduced && userBalanceIncreased && internalDepositReduced) {
            console.log("Vulnerability not Triggered: Withdrawal succeeded after unlock time as expected");
        } else {
            console.log("Vulnerability Possible: Unexpected fund movement after unlock time");
        }
    }

    // Test shows immediate withdrawal failure after deposit
    function testImmediateWithdrawalFailure() public {
        uint256 depositAmount = 1 ether;

        // Deposit with immediate unlock time
        vm.prank(user);
        wallet.Put{value: depositAmount}(0);

        // Record states after deposit (before withdrawal attempt)
        console.log("--- BEFORE-Trigger Collect ---");
        uint256 contractBalanceBeforeWithdrawal = address(wallet).balance;
        uint256 userBalanceBeforeWithdrawal = user.balance;
        (, uint256 internalDepositBefore) = wallet.Acc(user);
        console.log("Contract balance (before withdrawal):", contractBalanceBeforeWithdrawal);
        console.log("User balance (before withdrawal):", userBalanceBeforeWithdrawal);
        console.log("Internal deposited amount (before):", internalDepositBefore);

        // Attempt immediate withdrawal
        console.log("--- Trigger Collect ---");
        vm.prank(user);
        wallet.Collect(depositAmount);

        // Record states after withdrawal attempt
        console.log("--- AFTER-Trigger Collect ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 userBalanceAfter = user.balance;
        (, uint256 internalDepositAfter) = wallet.Acc(user);
        console.log("Contract balance (after):", contractBalanceAfter);
        console.log("User balance (after):", userBalanceAfter);
        console.log("Internal deposited amount (after):", internalDepositAfter);

        // Compare states - all balances should remain unchanged
        bool contractBalanceUnchanged = contractBalanceAfter == contractBalanceBeforeWithdrawal;
        bool userBalanceUnchanged = userBalanceAfter == userBalanceBeforeWithdrawal;
        bool internalDepositUnchanged = internalDepositAfter == internalDepositBefore;
        console.log("Contract balance unchanged:", contractBalanceUnchanged);
        console.log("User balance unchanged:", userBalanceUnchanged);
        console.log("Internal deposited amount unchanged:", internalDepositUnchanged);

        // Final verdict
        if (contractBalanceUnchanged && userBalanceUnchanged && internalDepositUnchanged) {
            console.log("Vulnerability Exists: Immediate withdrawal blocked despite deposit");
        } else {
            console.log("Vulnerability not Exist: Funds moved unexpectedly during immediate withdrawal");
        }
    }
}