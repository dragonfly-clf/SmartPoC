// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockTest is Test {
    TimeLock public timelock;
    address nonOwner = address(0x123);

    function setUp() public {
        timelock = new TimeLock();
    }

    function testNonOwnerCanIncreaseLockTimeWithoutRestriction() public {
        console.log("--- BEFORE-Trigger LockTime ---");
        uint256 preLockTime = timelock.lockTime(nonOwner);
        console.log("preLockTime (s): %s", preLockTime);
        
        console.log("--- Trigger: nonOwner calls increaseLockTime ---");
        uint256 lockTimeIncrease = 365 days;
        vm.prank(nonOwner);
        timelock.increaseLockTime(lockTimeIncrease);
        
        console.log("--- AFTER-Trigger LockTime ---");
        uint256 postLockTime = timelock.lockTime(nonOwner);
        console.log("postLockTime (s): %s", postLockTime);
        
        console.log("--- VULNERABILITY VERIFICATION ---");
        if (postLockTime == preLockTime + lockTimeIncrease) {
            console.log("Vulnerability Exists: Non-Owner successfully modified lock time without authorization");
        } else {
            console.log("Vulnerability not Exist: Lock time change failed or unexpected result");
        }
    }
}