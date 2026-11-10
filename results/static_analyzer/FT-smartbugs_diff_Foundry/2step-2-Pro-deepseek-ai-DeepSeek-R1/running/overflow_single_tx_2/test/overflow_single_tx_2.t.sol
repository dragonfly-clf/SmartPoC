// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowSingleTransaction target;

    function setUp() public {
        target = new IntegerOverflowSingleTransaction();
    }

    // Test overflow in add operation that updates state
    function test_add_overflow() public {
        // Set initial state to max uint256 value for count (slot0)
        vm.store(address(target), bytes32(uint256(0)), bytes32(type(uint256).max));
        address caller = address(this);
        
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger ---");
        uint256 countBefore = target.count();
        uint256 totalOpsBefore = target.totalOperations();
        uint256 userOpsBefore = target.userOperations(caller);
        console.log("count:", countBefore);
        console.log("totalOperations:", totalOpsBefore);
        console.log("userOperations:", userOpsBefore);

        console.log("--- Trigger overflowaddtostate ---");
        // Call the function to trigger overflow
        target.overflowaddtostate(1);
        
        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger ---");
        uint256 countAfter = target.count();
        uint256 totalOpsAfter = target.totalOperations();
        uint256 userOpsAfter = target.userOperations(caller);
        console.log("count:", countAfter);
        console.log("totalOperations:", totalOpsAfter);
        console.log("userOperations:", userOpsAfter);

        // Verification and verdict
        console.log("--- VERDICT ---");
        bool countChanged = countAfter != countBefore;
        bool opsIncreased = (totalOpsAfter == totalOpsBefore + 1) && 
                            (userOpsAfter == userOpsBefore + 1);
        bool overflowVerified = (countChanged && opsIncreased && countAfter == 0);
        
        console.log("count overflow  :", countChanged ? "WRAPPED" : "NO CHANGE");
        console.log("ops increment    :", opsIncreased ? "SUCCESS" : "FAILED");
        
        if (overflowVerified) {
            console.log("Vulnerability Exists: Integer overflow caused count reset (wrapped to 0)");
        } else {
            console.log("Vulnerability not Exist: Overflow conditions not met");
        }
    }

    // Test underflow in subtraction operation that updates state
    function test_sub_underflow() public {
        // Set initial state to minimum value (0) for count (slot0)
        vm.store(address(target), bytes32(uint256(0)), bytes32(0));
        address caller = address(this);
        
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger ---");
        uint256 countBefore = target.count();
        uint256 totalOpsBefore = target.totalOperations();
        uint256 userOpsBefore = target.userOperations(caller);
        console.log("count:", countBefore);
        console.log("totalOperations:", totalOpsBefore);
        console.log("userOperations:", userOpsBefore);

        console.log("--- Trigger underflowtostate ---");
        // Call the function to trigger underflow
        target.underflowtostate(1);
        
        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger ---");
        uint256 countAfter = target.count();
        uint256 totalOpsAfter = target.totalOperations();
        uint256 userOpsAfter = target.userOperations(caller);
        console.log("count:", countAfter);
        console.log("totalOperations:", totalOpsAfter);
        console.log("userOperations:", userOpsAfter);

        // Verification and verdict
        console.log("--- VERDICT ---");
        bool countChanged = countAfter != countBefore;
        bool opsIncreased = (totalOpsAfter == totalOpsBefore + 1) && 
                            (userOpsAfter == userOpsBefore + 1);
        bool underflowVerified = (countChanged && opsIncreased && countAfter == type(uint256).max);
        
        console.log("count underflow :", countChanged ? "WRAPPED" : "NO CHANGE");
        console.log("ops increment    :", opsIncreased ? "SUCCESS" : "FAILED");
        
        if (underflowVerified) {
            console.log("Vulnerability Exists: Integer underflow caused count wrap (to max)");
        } else {
            console.log("Vulnerability not Exist: Underflow conditions not met");
        }
    }

    // Test overflow in multiplication operation that updates state
    function test_mul_overflow() public {
        // Set initial state to max uint256 value for count (slot0)
        vm.store(address(target), bytes32(uint256(0)), bytes32(type(uint256).max));
        address caller = address(this);
        
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger ---");
        uint256 countBefore = target.count();
        uint256 totalOpsBefore = target.totalOperations();
        uint256 userOpsBefore = target.userOperations(caller);
        console.log("count:", countBefore);
        console.log("totalOperations:", totalOpsBefore);
        console.log("userOperations:", userOpsBefore);

        console.log("--- Trigger overflowmultostate ---");
        // Should cause overflow when multiplied by 2
        target.overflowmultostate(2);
        
        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger ---");
        uint256 countAfter = target.count();
        uint256 totalOpsAfter = target.totalOperations();
        uint256 userOpsAfter = target.userOperations(caller);
        console.log("count:", countAfter);
        console.log("totalOperations:", totalOpsAfter);
        console.log("userOperations:", userOpsAfter);

        // Verification and verdict
        console.log("--- VERDICT ---");
        bool countChanged = countAfter != countBefore;
        bool opsIncreased = (totalOpsAfter == totalOpsBefore + 1) && 
                            (userOpsAfter == userOpsBefore + 1);
        bool overflowVerified = (countChanged && opsIncreased && countAfter == type(uint256).max - 1);
        
        console.log("count overflow  :", countChanged ? "VERIFIED" : "NO CHANGE");
        console.log("ops increment    :", opsIncreased ? "SUCCESS" : "FAILED");
        
        if (overflowVerified) {
            console.log("Vulnerability Exists: Multiplication overflow caused count rollback");
        } else {
            console.log("Vulnerability not Exist: Overflow conditions not met");
        }
    }
}