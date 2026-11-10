// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name1.sol";

contract MissingEventsTest is Test {
    Missing missing;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");

    function setUp() public {
        // Deploy the contract
        missing = new Missing();
        
        // Set the owner
        vm.prank(owner);
        missing.IamMissing();
    }

    // Test event emission when setting the owner
    function test_OwnerSetEventNotEmitted() public {
        console.log("--- BEFORE-Trigger OwnerSet ---");
        console.log("BEFORE: Recording logs started.");

        console.log("--- Trigger OwnerSet function ---");
        // Prepare to record logs
        vm.recordLogs();
        
        // Attempt to set owner (should not emit event in vulnerable contract)
        vm.prank(owner);
        missing.IamMissing();
        
        // Get recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();
        
        // Verify no events were emitted
        console.log("--- AFTER-Trigger OwnerSet ---");
        console.log("AFTER: Number of events detected: %s", entries.length);
        if (entries.length == 0) {
            console.log("Vulnerability Exists: OwnerSet event not emitted");
        } else {
            console.log("Vulnerability not Exist: OwnerSet event emitted");
        }
        assertEq(entries.length, 0, "OwnerSet event should not be emitted");
    }

    // Test event emission on ETH deposit
    function test_DepositEventNotEmitted() public {
        console.log("--- BEFORE-Trigger Deposit ---");
        console.log("BEFORE: Recording logs started.");

        console.log("--- Trigger Deposit function ---");
        // Prepare to record logs
        vm.recordLogs();
        
        // Send ETH to the contract
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        (bool success,) = address(missing).call{value: 1 ether}("");
        require(success, "Deposit failed");
        
        // Get recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log("--- AFTER-Trigger Deposit ---");
        console.log("AFTER: Number of events detected: %s", entries.length);
        if (entries.length == 0) {
            console.log("Vulnerability Exists: Deposit event not emitted");
        } else {
            console.log("Vulnerability not Exist: Deposit event emitted");
        }
        assertEq(entries.length, 0, "Deposit event should not be emitted");
    }

    // Test event emission on ETH withdrawal
    function test_WithdrawalEventNotEmitted() public {
        // First deposit some ETH
        vm.deal(address(missing), 1 ether);
        
        console.log("--- BEFORE-Trigger Withdraw ---");
        console.log("BEFORE: Recording logs started.");

        console.log("--- Trigger Withdraw function ---");
        // Prepare to record logs
        vm.recordLogs();
        
        // Withdraw funds
        vm.prank(owner);
        missing.withdraw();
        
        // Get recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log("--- AFTER-Trigger Withdraw ---");
        console.log("AFTER: Number of events detected: %s", entries.length);
        if (entries.length == 0) {
            console.log("Vulnerability Exists: Withdrawal event not emitted");
        } else {
            console.log("Vulnerability not Exist: Withdrawal event emitted");
        }
        assertEq(entries.length, 0, "Withdrawal event should not be emitted");
    }
}