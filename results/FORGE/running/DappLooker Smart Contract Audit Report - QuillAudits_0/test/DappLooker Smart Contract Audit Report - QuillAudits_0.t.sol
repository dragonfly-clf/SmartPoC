// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SafeOwn.sol";

contract MockSafeOwn is SafeOwn {
    constructor(uint256 interval) SafeOwn(interval) {}
    
    function dummyFunction() public onlyOwner {} // To test permission retention
}

contract SafeOwnTest is Test {
    MockSafeOwn safeOwn;
    address constant OWNER = address(0xABCD);
    
    uint256 constant RENOUNCE_INTERVAL = 86400; // 1 day

    function setUp() public {
        vm.startPrank(OWNER);
        safeOwn = new MockSafeOwn(RENOUNCE_INTERVAL);
        vm.stopPrank();
    }

    function test_RenounceAbort() public {
        // Confirm initial owner state
        assertEq(safeOwn.Owner(), OWNER, "Incorrect initial owner");
        (bool initialIsRenounced,,) = safeOwn.renounceParams();
        assertFalse(initialIsRenounced, "Renounced state should be false initially");
        
        // Initiate renouncement
        vm.prank(OWNER);
        safeOwn.renounceOwnership();
        
        // Validate renouncement state
        (bool isRenouncedAfter, uint256 interval, uint256 renounceTime) = safeOwn.renounceParams();
        assertTrue(isRenouncedAfter, "Renounced state should be true");
        assertEq(interval, RENOUNCE_INTERVAL, "Incorrect interval stored");
        assertEq(renounceTime, block.timestamp + RENOUNCE_INTERVAL, "Invalid renunciation timestamp");
        
        // Differential verification: query isRenounced state before critical action
        console.log("--- BEFORE-Trigger retainOwnership ---");
        (bool isRenouncedBeforeState,,) = safeOwn.renounceParams();
        console.log("isRenounced state BEFORE retainOwnership:", isRenouncedBeforeState);
        
        console.log("--- Trigger retainOwnership ---");
        // Critical vulnerability operation: abort renouncement
        vm.prank(OWNER);
        safeOwn.retainOwnership();
        
        // Differential verification: query isRenounced state after critical action
        console.log("--- AFTER-Trigger retainOwnership ---");
        (bool isRenouncedAfterState,,) = safeOwn.renounceParams();
        console.log("isRenounced state AFTER retainOwnership:", isRenouncedAfterState);
        
        // Verify renouncement was reset
        (bool isRenouncedAfterAbort,,) = safeOwn.renounceParams();
        assertFalse(isRenouncedAfterAbort, "Renounced state not reset after abortion");
        
        // Confirm owner retains privileges
        vm.prank(OWNER);
        safeOwn.dummyFunction(); // Should succeed (test via gas usage)
        assertTrue(true, "Owner privileges retained after abortion");

        // Final vulnerability verdict
        if (isRenouncedBeforeState && !isRenouncedAfterState) {
            console.log("Vulnerability Exists: retainOwnership successfully changed renounce state from true to false");
        } else {
            console.log("Vulnerability not Exist: retainOwnership did not alter renounce state");
        }
    }
}