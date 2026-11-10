// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_onefunc_feasible.sol";

contract AccessControlTest is Test {
    IntegerOverflowMultiTxOneFuncFeasible public vulnerableContract;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    // Event definitions to match with contract
    event OperationPerformed(address indexed user, uint256 input);

    function setUp() public {
        vm.prank(owner);
        vulnerableContract = new IntegerOverflowMultiTxOneFuncFeasible();
    }

    function testRunFunctionAccessControl() public {
        // First call: initialization should not emit OperationPerformed event
        vm.prank(attacker);
        vulnerableContract.run(0);

        console.log("--- BEFORE-Trigger totalOperations ---");
        uint256 totalOperationsBefore = vulnerableContract.totalOperations();
        console.log("Total operations before second call:", totalOperationsBefore);

        console.log("--- Trigger run(1) ---");
        // Expect the event with correct parameters
        vm.expectEmit(true, true, true, true, address(vulnerableContract));
        emit OperationPerformed(attacker, 1);
        
        // Attacker calls run() with non-zero input
        vm.prank(attacker);
        vulnerableContract.run(1);

        console.log("--- AFTER-Trigger totalOperations ---");
        uint256 totalOperationsAfter = vulnerableContract.totalOperations();
        console.log("Total operations after second call:", totalOperationsAfter);

        // Check state change
        bool stateChanged = (totalOperationsAfter == totalOperationsBefore + 1);
        console.log("State increased by 1:", stateChanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: attacker successfully increased totalOperations by 1");
        } else {
            console.log("Vulnerability not Exist: unauthorized state modification was prevented");
        }
    }
}