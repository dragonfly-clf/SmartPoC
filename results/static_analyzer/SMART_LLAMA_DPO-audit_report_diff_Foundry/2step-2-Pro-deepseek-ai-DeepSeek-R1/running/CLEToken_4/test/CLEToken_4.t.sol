// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CLEToken.sol";

contract LockTest is Test {
    CLEToken token;
    address owner = address(1);
    uint256 initialTime;

    function setUp() public {
        initialTime = block.timestamp;
        vm.warp(initialTime);
        vm.deal(owner, 100 ether);

        // Mock Uniswap router calls
        address router = address(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
        address factory = address(0x123);
        address WETH = address(0x456);

        // Mock router functions
        vm.mockCall(
            router,
            abi.encodeWithSignature("factory()"),
            abi.encode(factory)
        );
        vm.mockCall(
            router,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        
        // Mock factory createPair
        vm.mockCall(
            factory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x789))
        );

        // Deploy token contract with owner address
        vm.prank(owner);
        token = new CLEToken();
    }

    function test_owner_can_repeatedly_lock_contract() public {
        // Phase 1: Initial lock - 7 days
        console.log("--- BEFORE-Trigger Lock (Phase 1: 7 days) ---");
        uint256 preLockTime1 = block.timestamp;
        uint256 unlockTimePre1 = token.geUnlockTime();
        console.log("Block time:", preLockTime1);
        console.log("Initial unlock time:", unlockTimePre1);

        console.log("--- Trigger Lock (Duration: 7 days) ---");
        vm.prank(owner);
        token.lock(7 days);

        console.log("--- AFTER-Trigger Lock (Phase 1) ---");
        uint256 unlockTimePost1 = token.geUnlockTime();
        uint256 expectedUnlock1 = preLockTime1 + 7 days;
        console.log("Expected unlock time:", expectedUnlock1);
        console.log("Actual unlock time:", unlockTimePost1);
        require(unlockTimePost1 == expectedUnlock1, "Phase1: unlock time mismatch");

        // Fast forward past initial lock period
        vm.warp(unlockTimePost1 + 1);
        console.log("Warped to:", block.timestamp);
        
        console.log("--- Trigger Unlock (Phase1) ---");
        vm.prank(owner);
        token.unlock();
        
        // Phase 2: Relock -14 days
        console.log("--- BEFORE-Trigger Lock (Phase 2: 14 days) ---");
        uint256 preLockTime2 = block.timestamp;
        uint256 unlockTimePre2 = token.geUnlockTime();
        console.log("Block time:", preLockTime2);
        console.log("Pre-lock unlock time:", unlockTimePre2);

        console.log("--- Trigger Lock (Duration: 14 days) ---");
        vm.prank(owner);
        token.lock(14 days);

        console.log("--- AFTER-Trigger Lock (Phase 2) ---");
        uint256 unlockTimePost2 = token.geUnlockTime();
        uint256 expectedUnlock2 = preLockTime2 + 14 days;
        console.log("Expected unlock time:", expectedUnlock2);
        console.log("Actual unlock time:", unlockTimePost2);
        require(unlockTimePost2 == expectedUnlock2, "Phase2: unlock time mismatch");

        // Fast forward to end of second period
        vm.warp(unlockTimePost2 + 1);
        console.log("Warped to:", block.timestamp);
        
        console.log("--- Trigger Unlock (Phase2) ---");
        vm.prank(owner);
        token.unlock();

        // Phase 3: Final lock - 30 days
        console.log("--- BEFORE-Trigger Lock (Phase 3: 30 days) ---");
        uint256 preLockTime3 = block.timestamp;
        uint256 unlockTimePre3 = token.geUnlockTime();
        console.log("Block time:", preLockTime3);
        console.log("Pre-lock unlock time:", unlockTimePre3);

        console.log("--- Trigger Lock (Duration: 30 days) ---");
        vm.prank(owner);
        token.lock(30 days);

        console.log("--- AFTER-Trigger Lock (Phase 3) ---");
        uint256 finalUnlockTime = token.geUnlockTime();
        uint256 expectedUnlock3 = preLockTime3 + 30 days;
        console.log("Expected unlock time:", expectedUnlock3);
        console.log("Actual unlock time:", finalUnlockTime);
        require(finalUnlockTime == expectedUnlock3, "Phase3: unlock time mismatch");

        // Vulnerability verdict
        console.log("--- Vulnerability Verification ---");
        bool sequentialLockApproval = unlockTimePost1 > unlockTimePre1 && 
                                    unlockTimePost2 > unlockTimePre2 && 
                                    finalUnlockTime > unlockTimePre3;
        bool increasingDuration = finalUnlockTime > unlockTimePost2 && unlockTimePost2 > unlockTimePost1;
        
        if (sequentialLockApproval && increasingDuration) {
            console.log("Vulnerability Exists: Owner can bypass lock restriction and repeatedly extend lock duration");
        } else {
            console.log("Vulnerability not Exist: Lock function has correct restrictions");
        }
    }
}