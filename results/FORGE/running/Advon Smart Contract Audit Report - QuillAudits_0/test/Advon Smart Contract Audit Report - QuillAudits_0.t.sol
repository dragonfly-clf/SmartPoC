// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SafeOwn.sol";

contract MockSafeOwn is SafeOwn {
    constructor(uint256 interval) SafeOwn(interval) {}
    
    function testOnlyOwnerFunc() public view onlyOwner {
        // Dummy function to test onlyOwner modifier
    }
}

contract SafeOwnTest is Test {
    MockSafeOwn safeOwn;
    address owner;
    uint256 constant RENOUNCE_INTERVAL = 1 days;

    function setUp() public {
        owner = address(this);
        safeOwn = new MockSafeOwn(RENOUNCE_INTERVAL);
    }

    function testRenounceOwnershipLoss() public {
        console.log("--- BEFORE-Trigger Owner ---");
        address ownerBefore = safeOwn.Owner();
        console.log("Owner Before:", ownerBefore);

        console.log("--- Trigger: renounceOwnership ---");
        safeOwn.renounceOwnership();

        console.log("--- AFTER-Trigger (without time warp) ---");
        address ownerAfter = safeOwn.Owner();
        console.log("Owner After (immediately):", ownerAfter);

        console.log("--- Fast forward by %d seconds ---", RENOUNCE_INTERVAL + 1);
        vm.warp(block.timestamp + RENOUNCE_INTERVAL + 1);
        
        console.log("--- AFTER-Trigger (with time warp) ---");
        address ownerFinal = safeOwn.Owner();
        console.log("Owner After (final):", ownerFinal);

        // Differential check
        if (ownerBefore == ownerFinal) {
            console.log("State Change: Ownership state did NOT change");
            console.log("Vulnerability not Exist: renounceOwnership failed to change ownership state");
        } else {
            console.log("State Change: Ownership state changed from %s to %s", ownerBefore, ownerFinal);
            
            // Additional proof of privilege loss
            vm.expectRevert("SafeOwn: Caller is the not the Owner");
            safeOwn.testOnlyOwnerFunc();
            console.log("Verification: Owner privileges successfully revoked");
            
            console.log("Vulnerability Exists: renounceOwnership permanently changed ownership state to zero address");
        }
    }
}