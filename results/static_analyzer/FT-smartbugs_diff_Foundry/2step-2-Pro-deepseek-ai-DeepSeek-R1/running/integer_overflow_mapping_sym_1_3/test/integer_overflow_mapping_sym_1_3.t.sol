// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowMappingSym1Test is Test {
    IntegerOverflowMappingSym1 public target;
    address public owner = address(0xA);
    address public nonOwner = address(0xB);
    uint256 public testKey = 1;
    uint256 public testValue = 100;

    function setUp() public {
        vm.startPrank(owner);
        target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
    }

    function test_NonOwnerCanCallInit() public {
        // Use v = 0 to prevent underflow
        uint256 safeValue = 0;

        // Capture initial state
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialTotalOperations = target.totalOperations();
        uint256 initialNonOwnerOps = target.getUserOperationCount(nonOwner);
        uint256 initialLastOperationTime = target.lastOperationTime();
        
        console.log("Initial totalOperations:     ", initialTotalOperations);
        console.log("Initial userOpCount(nonOwner):", initialNonOwnerOps);
        console.log("Initial lastOperationTime:   ", initialLastOperationTime);

        console.log("--- Trigger: nonOwner calls init ---");
        bytes memory payload = abi.encodeWithSelector(target.init.selector, testKey, safeValue);
        vm.startPrank(nonOwner);
        (bool success, ) = address(target).call(payload);
        vm.stopPrank();

        // Capture post-call state
        console.log("--- AFTER-Trigger State ---");
        uint256 newTotalOperations = target.totalOperations();
        uint256 newNonOwnerOps = target.getUserOperationCount(nonOwner);
        uint256 newLastOperationTime = target.lastOperationTime();
        
        console.log("New totalOperations:      ", newTotalOperations);
        console.log("New userOpCount(nonOwner): ", newNonOwnerOps);
        console.log("New lastOperationTime:    ", newLastOperationTime);

        // Check state changes
        bool totalOperationsChanged = (newTotalOperations == initialTotalOperations + 1);
        bool userOpsChanged = (newNonOwnerOps == initialNonOwnerOps + 1);
        bool operationTimeChanged = (newLastOperationTime > initialLastOperationTime);

        // Print change verification
        console.log("----------------------------------------");
        console.log("State change verification:");
        console.log("totalOperations incremented:     %s", totalOperationsChanged ? "YES" : "NO");
        console.log("userOpCount(nonOwner) incremented: %s", userOpsChanged ? "YES" : "NO");
        console.log("lastOperationTime updated:        %s", operationTimeChanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (totalOperationsChanged && userOpsChanged && operationTimeChanged) {
            console.log("Vulnerability Exists: non-owner call successfully changed state");
        } else {
            console.log("Vulnerability not Exist: state change not completed as expected");
        }
    }

    function test_OwnerCanAlsoCallInit() public {
        // Use safe value to prevent underflow
        uint256 safeValue = 0;

        vm.startPrank(owner);
        target.init(testKey, safeValue);
        vm.stopPrank();
        
        assertEq(
            target.getUserOperationCount(owner),
            1,
            "Owner operation count should increase"
        );
    }
}