// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract VestingLockTest is Test {
    Fidometa token;
    address owner;
    address user = address(0x1);

    function setUp() public {
        token = new Fidometa();
        owner = token.owner();
    }

    function testLockPrevention() public {
        uint8 decimals = token.decimals();
        uint256 oneToken = 10 ** decimals;
        uint256 lockAmount = 4 * oneToken;
        uint256 newLockAmount = 1 * oneToken;
        uint256 lockDuration = 0;

        // 1. Admin sets vesting for user (4 tokens)
        vm.prank(owner);
        token.transferWithLock(user, lockAmount, lockDuration);
        
        // 2. Advance time 300 days (10 months)
        vm.warp(block.timestamp + 300 days);
        
        // Differential: Query lock state BEFORE unlock
        console2.log("--- BEFORE-Trigger State ---");
        (uint256 lockedBefore, uint256 remainedBefore, , , ) = token.locks(user);
        console2.log("Locked tokens before unlock:", lockedBefore);
        console2.log("Remained tokens before unlock:", remainedBefore);

        // 3. User unlocks all tokens
        console2.log("--- Trigger Unlock ---");
        vm.prank(user);
        token.unlock(user);
        
        // Differential: Query lock state AFTER unlock
        console2.log("--- AFTER-Trigger State ---");
        (uint256 lockedAfter, uint256 remainedAfter, , , ) = token.locks(user);
        console2.log("Locked tokens after unlock:", lockedAfter);
        console2.log("Remained tokens after unlock:", remainedAfter);
        
        // Validate vulnerability exists
        if (lockedAfter > 0 || remainedAfter > 0) {
            console2.log("Vulnerability Exists: Lock state not cleared after unlock");
        } else {
            console2.log("Vulnerability not Exist: Lock state cleared successfully");
        }

        // 4. Admin tries to create new vesting for same user
        console2.log("--- Final Verdict ---");
        if (lockedAfter > 0 || remainedAfter > 0) {
            console2.log("Vulnerability Exists: Persisting lock state prevents new vesting");
            vm.prank(owner);
            vm.expectRevert("This address is already in vesting period");
            token.transferWithLock(user, newLockAmount, lockDuration);
        } else {
            console2.log("Vulnerability not Exist: Lock state cleared, allows new vesting");
            vm.prank(owner);
            token.transferWithLock(user, newLockAmount, lockDuration);  // Should succeed
        }
    }
}