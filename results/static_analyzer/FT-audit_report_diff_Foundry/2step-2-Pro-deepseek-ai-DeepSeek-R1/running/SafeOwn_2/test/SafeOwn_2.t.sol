// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SafeOwn.sol";

contract SafeOwnHarness is SafeOwn {
    constructor(uint256 renounceInterval) SafeOwn(renounceInterval) {}
}

contract SafeOwnTest is Test {
    SafeOwnHarness safeOwn;
    address owner = address(1);
    uint256 constant RENOUNCE_INTERVAL = 1 days;

    function setUp() public {
        vm.prank(owner);
        safeOwn = new SafeOwnHarness(RENOUNCE_INTERVAL);
    }

    function test_retainOwnershipRevertsWhenNotRenounced() public {
        vm.prank(owner);
        vm.expectRevert("SafeOwn: Already Retained");
        safeOwn.retainOwnership();
        
        (bool isRenounced,,) = safeOwn.renounceParams();
        assertTrue(!isRenounced, "Ownership should not be renounced initially");
    }

    function test_retainOwnershipSucceedsAfterRenounce() public {
        vm.prank(owner);
        safeOwn.renounceOwnership();
        
        // BEFORE: Check renounced state
        (bool isRenouncedBefore,,) = safeOwn.renounceParams();
        console.log("--- BEFORE-Trigger RetainOwnership ---");
        console.log("isRenounced state:", isRenouncedBefore);
        
        console.log("--- Trigger RetainOwnership ---");
        vm.prank(owner);
        safeOwn.retainOwnership();
        
        // AFTER: Check renounced state
        console.log("--- AFTER-Trigger RetainOwnership ---");
        (bool isRenouncedAfter,,) = safeOwn.renounceParams();
        console.log("isRenounced state:", isRenouncedAfter);
        
        // Compare states for vulnerability verification
        if (isRenouncedBefore && !isRenouncedAfter) {
            console.log("Vulnerability Exists: retainOwnership successfully changed isRenounced from true to false");
        } else {
            console.log("Vulnerability not Exist: State change did not occur as expected");
        }
    }
}