// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowSingleTransaction overflowContract;
    address owner = address(0x1);
    address testUser = address(0x123);

    function setUp() public {
        vm.prank(owner);
        overflowContract = new IntegerOverflowSingleTransaction();
    }

    function testOverflowAddToState() public {
        // Set count to max uint256 value - 1
        vm.prank(testUser);
        overflowContract.overflowaddtostate(type(uint256).max - 1);
        
        // Adding 1 should make it max value
        vm.prank(testUser);
        overflowContract.overflowaddtostate(1);
        
        console.log("--- BEFORE-Trigger Overflow ---");
        uint256 beforeOverflow = overflowContract.count();
        console.log("Current count:", beforeOverflow);
        
        console.log("--- Trigger Operation ---");
        // Adding 1 more should overflow to 0
        vm.prank(testUser);
        overflowContract.overflowaddtostate(1);
        
        console.log("--- AFTER-Trigger Overflow ---");
        uint256 afterOverflow = overflowContract.count();
        console.log("New count:", afterOverflow);
        
        // Verdict
        if (afterOverflow == 0) {
            console.log("Vulnerability Exists: Addition overflow resulted in 0");
        } else {
            console.log("Vulnerability not Exist: Count not overflowed to 0");
        }
    }

    function testUnderflowToState() public {
        // Set count to 1
        vm.prank(testUser);
        overflowContract.overflowaddtostate(1);
        
        // Subtracting 1 should make it 0
        vm.prank(testUser);
        overflowContract.underflowtostate(1);
        
        console.log("--- BEFORE-Trigger Underflow ---");
        uint256 beforeUnderflow = overflowContract.count();
        console.log("Current count:", beforeUnderflow);
        
        console.log("--- Trigger Operation ---");
        // Subtracting 1 more should underflow to max uint256
        vm.prank(testUser);
        overflowContract.underflowtostate(1);
        
        console.log("--- AFTER-Trigger Underflow ---");
        uint256 afterUnderflow = overflowContract.count();
        console.log("New count:", afterUnderflow);
        
        // Verdict
        if (afterUnderflow == type(uint256).max) {
            console.log("Vulnerability Exists: Underflow resulted in max value");
        } else {
            console.log("Vulnerability not Exist: Count not underflowed to max");
        }
    }

    function testOverflowMulToState() public {
        // Set count to max uint256 value / 2 + 1
        vm.prank(testUser);
        overflowContract.overflowaddtostate(type(uint256).max / 2 + 1);
        
        console.log("--- BEFORE-Trigger Overflow ---");
        uint256 beforeOverflow = overflowContract.count();
        console.log("Current count:", beforeOverflow);
        
        console.log("--- Trigger Operation ---");
        // Multiplying by 2 should overflow
        vm.prank(testUser);
        overflowContract.overflowmultostate(2);
        
        console.log("--- AFTER-Trigger Overflow ---");
        uint256 afterOverflow = overflowContract.count();
        console.log("New count:", afterOverflow);
        
        // Verdict
        if (afterOverflow == 0) {
            console.log("Vulnerability Exists: Multiplication overflow resulted in 0");
        } else {
            console.log("Vulnerability not Exist: Multiplication did not overflow");
        }
    }

    function testLocalOverflowDoesNotAffectState() public {
        console.log("--- BEFORE all local operations ---");
        uint256 initialCount = overflowContract.count();
        console.log("Initial count:", initialCount);
        
        // These operations perform overflow locally but don't modify state
        vm.prank(testUser);
        overflowContract.overflowlocalonly(type(uint256).max);
        
        vm.prank(testUser);
        overflowContract.underflowlocalonly(type(uint256).max);
        
        vm.prank(testUser);
        overflowContract.overflowmulocalonly(type(uint256).max);
        
        console.log("--- AFTER all local operations ---");
        uint256 finalCount = overflowContract.count();
        console.log("Final count:", finalCount);
        
        // Verdict
        if (finalCount == initialCount) {
            console.log("Vulnerability not Exist: Local operations correctly left count unchanged");
        } else {
            console.log("Vulnerability Exists: Local operations modified count state");
        }
        
        // Verify count remains unchanged
        assertEq(finalCount, initialCount);
    }

    function testResetCounter() public {
        // Perform some operations first
        vm.prank(testUser);
        overflowContract.overflowaddtostate(100);
        
        console.log("--- BEFORE-Trigger Reset ---");
        uint256 beforeReset = overflowContract.count();
        console.log("Count before reset:", beforeReset);
        
        console.log("--- Trigger Operation ---");
        // Reset should work when called by owner
        vm.prank(owner);
        overflowContract.resetCounter();
        
        console.log("--- AFTER-Trigger Reset ---");
        uint256 afterReset = overflowContract.count();
        console.log("Count after reset:", afterReset);
        
        // Verdict
        if (afterReset == 1) {
            console.log("Vulnerability not Exist: Reset function operated correctly");
        } else {
            console.log("Vulnerability Exists: Reset function failed");
        }
        
        // Verify count is reset to 1
        assertEq(afterReset, 1);
    }
}