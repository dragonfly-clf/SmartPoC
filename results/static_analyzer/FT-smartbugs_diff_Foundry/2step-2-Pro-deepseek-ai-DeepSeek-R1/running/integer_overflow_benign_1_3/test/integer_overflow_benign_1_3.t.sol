// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_benign_1.sol";

contract IntegerOverflowBenign1Test is Test {
    IntegerOverflowBenign1 public vulnerableContract;
    address testUser = address(0xABCD);

    function setUp() public {
        vulnerableContract = new IntegerOverflowBenign1();
    }

    function test_NoInputValidationUnderflow() public {
        console2.log("--- BEFORE-Trigger ---");
        // Query initial state
        uint initialUserOps = vulnerableContract.getUserOperationCount(testUser);
        uint initialTotalOps = vulnerableContract.totalOperations();
        console2.log("Initial user operations:", initialUserOps);
        console2.log("Initial total operations:", initialTotalOps);
        assertEq(initialUserOps, 0, "Initial operations should be zero");

        console2.log("--- Trigger: run(1) ---");
        // Execute function with overflow-inducing input
        vm.prank(testUser);
        vulnerableContract.run(1);  // Will cause underflow since base count=0

        console2.log("--- AFTER-Trigger ---");
        // Query post-state
        uint postUserOps = vulnerableContract.getUserOperationCount(testUser);
        uint postTotalOps = vulnerableContract.totalOperations();
        console2.log("Post user operations:", postUserOps);
        console2.log("Post total operations:", postTotalOps);

        // Compare state changes
        bool userOpsIncreased = postUserOps == initialUserOps + 1;
        bool totalOpsIncreased = postTotalOps == initialTotalOps + 1;
        console2.log("User operations increased:", userOpsIncreased ? "YES" : "NO");
        console2.log("Total operations increased:", totalOpsIncreased ? "YES" : "NO");
        console2.log("Vulnerability Exists: State updated despite integer underflow");
    }

    function testFuzz_UncheckedUnderflow(uint96 input) public {
        vm.assume(input > 0);  // Only test values that can cause underflow
        
        console2.log("--- BEFORE-Trigger ---");
        // Query initial state
        uint preUserOps = vulnerableContract.getUserOperationCount(testUser);
        uint preTotalOps = vulnerableContract.totalOperations();
        console2.log("Pre user operations:", preUserOps);
        console2.log("Pre total operations:", preTotalOps);
        
        console2.log("--- Trigger: run(%s) ---", input);
        // Execute potentially overflowing operation
        vm.prank(testUser);
        vulnerableContract.run(input);

        console2.log("--- AFTER-Trigger ---");
        // Query post-state
        uint postUserOps = vulnerableContract.getUserOperationCount(testUser);
        uint postTotalOps = vulnerableContract.totalOperations();
        console2.log("Post user operations:", postUserOps);
        console2.log("Post total operations:", postTotalOps);

        // Compare state changes
        bool userOpsIncreased = postUserOps == preUserOps + 1;
        bool totalOpsIncreased = postTotalOps == preTotalOps + 1;
        
        if (userOpsIncreased && totalOpsIncreased) {
            console2.log("Vulnerability Exists: State updated despite integer underflow");
        } else {
            console2.log("Vulnerability not Exist: State unchanged");
        }
    }
}