// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_multifunc_feasible.sol";

contract IntegerOverflowGasLimitTest is Test {
    IntegerOverflowMultiTxMultiFuncFeasible public vulnerableContract;
    address user1 = makeAddr("user1");
    uint256 constant LIMIT = 100;

    function setUp() public {
        vulnerableContract = new IntegerOverflowMultiTxMultiFuncFeasible();
        vulnerableContract.init();
    }

    function test_OperationLimitExceeded() public {
        uint256 operationCount = LIMIT + 1; // 101 operations
        
        console.log("--- BEFORE-Trigger Operations ---");
        uint256 initialOperations = vulnerableContract.userOperations(user1);
        console.log("Initial operations for user1:", initialOperations);

        console.log("--- Trigger Operation Loop ---");
        vm.startPrank(user1);
        for(uint256 i = 0; i < operationCount; i++) {
            // Perform operation with minimal input to avoid underflow
            vulnerableContract.run(0);
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger Operations ---");
        uint256 finalOperations = vulnerableContract.userOperations(user1);
        console.log("Final operations for user1:", finalOperations);

        uint256 delta = finalOperations - initialOperations;
        console.log("Expected operation delta:", operationCount);
        console.log("Actual operation delta:", delta);

        // Vulnerability verdict
        if (delta == operationCount) {
            console.log("Vulnerability Exists: The contract allowed 101 operations which exceeds the limit of 100");
        } else {
            console.log("Vulnerability not Exist: The contract did not allow exceeding the operation limit as evidenced by the operation delta");
        }

        assertEq(finalOperations, operationCount, "User should be able to exceed operation limit");
    }
}