// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_add.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd public integerOverflowAdd;
    address public trustedUser = address(0x01);
    address public untrustedUser = address(0x02);

    function setUp() public {
        integerOverflowAdd = new IntegerOverflowAdd();
    }

    function test_AnyoneCanInvokeRun() public {
        // Record initial states
        uint initialCount = integerOverflowAdd.count();
        uint initialTrustedUserOps = integerOverflowAdd.getUserOperationCount(trustedUser);
        uint initialUntrustedUserOps = integerOverflowAdd.getUserOperationCount(untrustedUser);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Global count:", initialCount);
        console.log("Trusted user operations:", initialTrustedUserOps);
        console.log("Untrusted user operations:", initialUntrustedUserOps);
        console.log("Current state is as expected");

        console.log("--- Trigger Operation ---");
        console.log("Untrusted user attempts to invoke run(100)");
        vm.prank(untrustedUser);
        integerOverflowAdd.run(100);
        console.log("Trigger action completed");

        uint updatedCount = integerOverflowAdd.count();
        uint updatedTrustedUserOps = integerOverflowAdd.getUserOperationCount(trustedUser);
        uint updatedUntrustedUserOps = integerOverflowAdd.getUserOperationCount(untrustedUser);
        
        console.log("--- AFTER-Trigger ---");
        console.log("Global count:", updatedCount);
        console.log("Trusted user operations:", updatedTrustedUserOps);
        console.log("Untrusted user operations:", updatedUntrustedUserOps);
        
        // Check state changes
        bool countChanged = (updatedCount - initialCount == 100);
        bool trustedOpsChanged = (updatedTrustedUserOps != initialTrustedUserOps);
        bool untrustedOpsChanged = (updatedUntrustedUserOps == initialUntrustedUserOps + 1);
        
        console.log("--- Differential Results ---");
        console.log("Count increased by 100:", countChanged ? "SUCCESS" : "FAILED");
        console.log("Trusted user ops unchanged:", !trustedOpsChanged ? "SUCCESS" : "FAILED");
        console.log("Untrusted user ops increased by 1:", untrustedOpsChanged ? "SUCCESS" : "FAILED");
        
        // Final vulnerability verification
        if (countChanged && !trustedOpsChanged && untrustedOpsChanged) {
            console.log("Vulnerability Exists: Untrusted user successfully modified critical state");
        } else {
            console.log("Vulnerability not Exist: State changes not as expected");
        }

        // Original assertions (keep for test framework)
        assertEq(integerOverflowAdd.count(), initialCount + 100, "Count not updated");
        assertEq(integerOverflowAdd.getUserOperationCount(untrustedUser), initialUntrustedUserOps + 1, "User ops not updated");
        assertEq(integerOverflowAdd.getUserOperationCount(trustedUser), initialTrustedUserOps, "Unaffected user altered");
    }
}