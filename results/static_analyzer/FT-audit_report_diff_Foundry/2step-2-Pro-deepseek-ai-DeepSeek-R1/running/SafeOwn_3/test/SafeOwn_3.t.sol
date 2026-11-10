// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/SafeOwn.sol";

contract MockSafeOwn is SafeOwn {
    constructor(uint256 renounceInterval) SafeOwn(renounceInterval) {}
}

contract SafeOwnTest is Test {
    MockSafeOwn safeOwn;
    uint256 constant RENOUNCE_INTERVAL = 100 days;

    function setUp() public {
        safeOwn = new MockSafeOwn(RENOUNCE_INTERVAL);
    }

    function test_proposeOwnershipDoesNotEmitEvent() public {
        address newOwner = address(0x123);
        
        console2.log("--- BEFORE-Trigger State ---");
        address initialPendingOwner = safeOwn.pendingOwner();
        address initialOwner = safeOwn.Owner();
        console2.log("Current pendingOwner:", initialPendingOwner);
        console2.log("Current Owner:", initialOwner);
        console2.log("Pending owner is expected to be address(0) and Owner to be deployer.");

        console2.log("--- Trigger proposeOwnership ---");
        vm.recordLogs();
        safeOwn.proposeOwnership(newOwner);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        console2.log("--- AFTER-Trigger State ---");
        address finalPendingOwner = safeOwn.pendingOwner();
        address finalOwner = safeOwn.Owner();
        console2.log("New pendingOwner:", finalPendingOwner);
        console2.log("Owner remains:", finalOwner);
        
        // Detect event emission
        bytes32 eventHash = keccak256("ownershipTransferred(address,address,uint256)");
        bool eventDetected = false;
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == eventHash) {
                eventDetected = true;
                break;
            }
        }
        console2.log("Event ownershipTransferred emitted:", eventDetected ? "YES" : "NO");

        // Final vulnerability determination
        if (eventDetected) {
            console2.log("Vulnerability not Exist: OwnershipTransferred event was properly emitted");
        } else {
            console2.log("Vulnerability Exists: OwnershipTransferred event missing while state changed correctly");
        }
        
        // Conditional final log
        if (!eventDetected) {
            console2.log("Vulnerability Exists: Missing critical ownership transfer event");
        } else {
            console2.log("Vulnerability not Exist: Event emission functions correctly");
        }
    }
}