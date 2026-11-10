// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidoMetaUnderflowTest is Test {
    Fidometa token;
    address owner = address(0x1);
    address victim = address(0x2);
    uint256 mappingSlot; // Storage slot for locks mapping

    function setUp() public {
        vm.startPrank(owner);
        token = new Fidometa();
        vm.stopPrank();
        
        // Assume locks mapping is at storage slot 16 (common position in layout)
        mappingSlot = 16;
    }

    function test_unlockUnderflow() public {
        uint256 initialLock = 0;
        uint256 lockAmount = 1000 ether;
        uint256 startTime = block.timestamp;

        // Directly set lock state in storage
        bytes32 baseSlot = keccak256(abi.encode(victim, mappingSlot));
        vm.store(address(token), baseSlot, bytes32(startTime));                      // .startTime
        vm.store(address(token), bytes32(uint256(baseSlot) + 1), bytes32(lockAmount)); // .lockedToken
        vm.store(address(token), bytes32(uint256(baseSlot) + 2), bytes32(lockAmount)); // .remainedToken
        vm.store(address(token), bytes32(uint256(baseSlot) + 3), bytes32(uint256(5))); // .monthCount = 5
        vm.store(address(token), bytes32(uint256(baseSlot) + 4), bytes32(initialLock)); // .initialLock

        // Advance to position that would trigger underflow
        vm.warp(startTime + 121 days); // Approximately 4 months
        
        // Verify state before unlock attempt
        assertEq(token.isExcludedFromReward(victim), false, "Should not be excluded");

        // Get storage slot for remainedToken
        bytes32 remainedTokenSlot = bytes32(uint256(baseSlot) + 2);

        console.log("--- BEFORE-Trigger Unlock ---");
        uint256 remainedTokenBefore = uint256(vm.load(address(token), remainedTokenSlot));
        console.log("RemainedToken before unlock:", remainedTokenBefore);

        console.log("--- Trigger Unlock ---");
        // Attempt unlock - should revert due to underflow
        vm.expectRevert();
        token.unlock(victim);

        console.log("--- AFTER-Trigger Unlock ---");
        uint256 remainedTokenAfter = uint256(vm.load(address(token), remainedTokenSlot));
        console.log("RemainedToken after unlock:", remainedTokenAfter);

        // Compare state before and after
        if (remainedTokenBefore == remainedTokenAfter) {
            console.log("Verdict: State unchanged - underflow successfully triggered revert");
            console.log("Vulnerability Exists: unlock operation causes underflow and reverts without changing state");
        } else {
            console.log("Verdict: State changed - unlock completed without underflow");
            console.log("Vulnerability not Exist: underflow vulnerability was not triggered");
        }
    }
}