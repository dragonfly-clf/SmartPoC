// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract TimestampDependenceTest is Test {
    PENNY_BY_PENNY penny;
    LogFile logFile;
    address user = makeAddr("user");
    uint256 public deposit = 1 ether;
    uint256 public lockTime = 1 days;

    function setUp() public {
        // Deploy contracts
        penny = new PENNY_BY_PENNY();
        logFile = new LogFile();
        
        // Initialize logging system
        penny.SetLogFile(address(logFile));
        
        // Ensure minimum deposit condition is met
        penny.SetMinSum(0);
        
        // Setup user funds
        vm.deal(user, deposit);
        
        // Deposit funds with lock period
        vm.prank(user);
        penny.Put{value: deposit}(lockTime);
    }

    function testTimestampManipulationAllowsEarlyWithdrawal() public {
        // Get user deposit details
        (uint256 userDepositBalanceBefore, uint256 userUnlockTimeBefore) = penny.Acc(user);
        
        // Log and record pre-trigger state
        console.log("--- BEFORE-Trigger (User with early unlock) ---");
        uint256 contractBalanceBefore = address(penny).balance;
        uint256 userBalanceBefore = user.balance;
        console.log("Contract ETH balance: %s", contractBalanceBefore);
        console.log("User ETH balance: %s", userBalanceBefore);
        console.log("User deposit balance: %s", userDepositBalanceBefore);
        console.log("User unlock time: %s", userUnlockTimeBefore);

        // Manipulate timestamp to surpass unlock time
        uint256 unlockTime = block.timestamp + lockTime;
        vm.warp(unlockTime + 1);
        
        console.log("--- Trigger Collect (User with early unlock) ---");
        vm.prank(user);
        penny.Collect(deposit);
        console.log("Early withdrawal executed");

        // Log and record post-trigger state
        console.log("--- AFTER-Trigger (User with early unlock) ---");
        uint256 contractBalanceAfter = address(penny).balance;
        uint256 userBalanceAfter = user.balance;
        (uint256 userDepositBalanceAfter, uint256 userUnlockTimeAfter) = penny.Acc(user);
        console.log("Contract ETH balance: %s", contractBalanceAfter);
        console.log("User ETH balance: %s", userBalanceAfter);
        console.log("User deposit balance: %s", userDepositBalanceAfter);

        // Vulnerability detection logic
        bool vulnerabilityExists = 
            contractBalanceAfter == contractBalanceBefore - deposit &&
            userBalanceAfter == userBalanceBefore + deposit &&
            userDepositBalanceAfter == 0;
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Timestamp manipulation allowed early withdrawal");
        } else {
            console.log("Vulnerability not Exist: Withdrawal constraints are enforced");
        }
    }

    function testWithdrawalFailsWhenUnlockConditionNotMet() public {
        // Get user deposit details
        (uint256 userDepositBalanceBefore, uint256 userUnlockTimeBefore) = penny.Acc(user);
        
        // Log and record pre-trigger state
        console.log("--- BEFORE-Trigger (Unlock condition not met) ---");
        uint256 contractBalanceBefore = address(penny).balance;
        uint256 userBalanceBefore = user.balance;
        console.log("Contract ETH balance: %s", contractBalanceBefore);
        console.log("User ETH balance: %s", userBalanceBefore);
        console.log("User deposit balance: %s", userDepositBalanceBefore);
        console.log("User unlock time: %s", userUnlockTimeBefore);

        // Advance time to just before unlock
        vm.warp(block.timestamp + lockTime - 1);
        
        console.log("--- Trigger Collect (Unlock condition not met) ---");
        vm.prank(user);
        penny.Collect(deposit);
        console.log("Early withdrawal attempt made");

        // Log and record post-trigger state
        console.log("--- AFTER-Trigger (Unlock condition not met) ---");
        uint256 contractBalanceAfter = address(penny).balance;
        uint256 userBalanceAfter = user.balance;
        (uint256 userDepositBalanceAfter, uint256 userUnlockTimeAfter) = penny.Acc(user);
        console.log("Contract ETH balance: %s", contractBalanceAfter);
        console.log("User ETH balance: %s", userBalanceAfter);
        console.log("User deposit balance: %s", userDepositBalanceAfter);

        // Validation logic for failed withdrawal
        bool stateUnchanged = 
            contractBalanceAfter == contractBalanceBefore &&
            userBalanceAfter == userBalanceBefore &&
            userDepositBalanceAfter == userDepositBalanceBefore;
        
        // Final verdict
        if (stateUnchanged) {
            console.log("Vulnerability not Exist: Early withdrawal was prevented as expected");
        } else {
            console.log("Vulnerability Exists: Funds moved without meeting unlock conditions");
        }
    }
}