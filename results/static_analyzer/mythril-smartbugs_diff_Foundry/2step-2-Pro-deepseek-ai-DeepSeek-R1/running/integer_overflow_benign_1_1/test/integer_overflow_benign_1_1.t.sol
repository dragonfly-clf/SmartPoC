// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_benign_1.sol";

contract IntegerOverflowBenign1Test is Test {
    IntegerOverflowBenign1 public testedContract;
    address testUser = address(0xDEAD);

    function setUp() public {
        testedContract = new IntegerOverflowBenign1();
    }

    function test_RunWithUnderflow() public {
        console.log("--- BEFORE-Trigger Operation ---");
        uint256 initialUserCount = testedContract.getUserOperationCount(testUser);
        uint256 initialTotalCount = testedContract.totalOperations();
        console.log("Initial user operation count: %s", initialUserCount);
        console.log("Initial total operations count: %s", initialTotalCount);
        assertEq(initialUserCount, 0, "Initial user operation count should be zero");
        
        console.log("--- Trigger run(1) ---");
        vm.prank(testUser);
        testedContract.run(1);
        
        console.log("--- AFTER-Trigger Operation ---");
        uint256 updatedUserCount = testedContract.getUserOperationCount(testUser);
        uint256 updatedTotalCount = testedContract.totalOperations();
        console.log("Updated user operation count: %s", updatedUserCount);
        console.log("Updated total operations count: %s", updatedTotalCount);
        assertEq(updatedUserCount, 1, "User operation count should increment despite underflow");
        
        bool stateChanged = (updatedUserCount == initialUserCount + 1) && 
                            (updatedTotalCount == initialTotalCount + 1);
        
        if (stateChanged) {
            console.log("Vulnerability Exists: Integer underflow occurred without reverting and state was updated");
        } else {
            console.log("Vulnerability not Exist: Operation counts did not change as expected");
        }
    }
}