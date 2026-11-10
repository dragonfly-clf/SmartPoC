// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingEventTest is Test {
    Missing public missing;
    address owner = makeAddr("owner");

    function setUp() public {
        // Setup owner and deploy contract
        vm.startPrank(owner);
        missing = new Missing();
        missing.Constructor(); // Initialize ownership
        vm.stopPrank();

        // Fund the contract with 1 ether
        vm.deal(address(missing), 1 ether);
    }

    function test_withdraw_does_not_emit_custom_event() public {
        console.log("--- BEFORE-Trigger Withdraw ---");
        console.log("Contract balance: %s", address(missing).balance);

        // Trigger the withdrawal and record logs
        console.log("--- Trigger Withdraw ---");
        vm.recordLogs();
        vm.prank(owner);
        missing.withdraw();

        console.log("--- AFTER-Trigger Withdraw ---");
        console.log("Contract balance: %s", address(missing).balance);

        // Verify logs for FundsTransferred event
        bytes32 fundsSig = keccak256("FundsTransferred(address,uint256)");
        bool foundCustomEvent = false;
        Vm.Log[] memory logs = vm.getRecordedLogs();
        
        for (uint i; i < logs.length; i++) {
            if (logs[i].topics[0] == fundsSig) {
                foundCustomEvent = true;
                break;
            }
        }

        // Final vulnerability verdict
        if (foundCustomEvent) {
            console.log("Vulnerability not Exist: FundsTransferred event was emitted");
        } else {
            console.log("Vulnerability Exists: FundsTransferred event was not emitted");
        }
    }
}