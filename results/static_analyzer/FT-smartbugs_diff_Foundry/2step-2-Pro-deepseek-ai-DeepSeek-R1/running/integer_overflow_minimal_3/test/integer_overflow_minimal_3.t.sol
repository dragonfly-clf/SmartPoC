// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_minimal.sol";

contract IntegerOverflowMinimalTest is Test {
    IntegerOverflowMinimal public targetContract;
    address owner = makeAddr("contractOwner");
    address attacker = makeAddr("unauthorizedUser");
    
    function setUp() public {
        vm.prank(owner);
        targetContract = new IntegerOverflowMinimal();
    }

    function test_UnauthorizedReset() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 countBefore = targetContract.count();
        uint256 totalOpsBefore = targetContract.totalOperations();
        console.log("count: ", countBefore);
        console.log("totalOperations: ", totalOpsBefore);

        console.log("--- Trigger ACTION: Attacker calls resetCount() ---");
        bool success;
        vm.prank(attacker);
        try targetContract.resetCount() {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger State ---");
        uint256 countAfter = targetContract.count();
        uint256 totalOpsAfter = targetContract.totalOperations();
        console.log("count: ", countAfter);
        console.log("totalOperations: ", totalOpsAfter);

        console.log("--- VERDICT ---");
        if (success) {
            console.log("Vulnerability Exists: Unauthorized user successfully called function");
        } else {
            console.log("Vulnerability not Exist: Function call reverted due to access control");
        }
    }
}