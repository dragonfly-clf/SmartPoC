// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BNRG.sol";

contract OwnershipEventTest is Test {
    BNRG token;
    address initialOwner = address(0x100);
    address newOwner = address(0x200);
    
    function setUp() public {
        vm.startPrank(initialOwner);
        token = new BNRG();
        vm.stopPrank();
    }
    
    function test_NoEventOnOwnershipTransfer() public {
        // Log initial state
        console.log("--- BEFORE-Trigger ---");
        address preOwner = token.owner();
        console.log("Pre-trigger owner:", preOwner);
        assertEq(preOwner, initialOwner, "Initial owner mismatch");

        // Start recording logs for event verification
        vm.recordLogs();

        console.log("--- Trigger: transferOwnership ---");
        vm.prank(preOwner);
        token.transferOwnership(newOwner);

        // Log post-trigger state
        console.log("--- AFTER-Trigger ---");
        address postOwner = token.owner();
        console.log("Post-trigger owner:", postOwner);
        assertEq(postOwner, newOwner, "Ownership transfer failed");

        // Validate event emissions
        Vm.Log[] memory logs = vm.getRecordedLogs();
        console.log("Number of events emitted:", logs.length);

        // Vulnerability verdict based on event presence
        if (logs.length == 0) {
            console.log("Vulnerability Exists: Ownership transfer should emit event but no event was triggered");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer emitted events as expected");
        }
    }
}