// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DiamondDexToken.sol";

contract DiamondDexTokenOwnershipTest is Test {
    DiamondDexToken token;
    
    address owner = makeAddr("owner");
    address newOwner = makeAddr("newOwner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Fork BSC mainnet to handle router dependencies
        uint256 forkId = vm.createFork("https://bsc-dataseed.binance.org/");
        vm.selectFork(forkId);
        
        // Deploy token as owner
        vm.prank(owner);
        token = new DiamondDexToken();
    }

    // Test 1: Owner can arbitrarily extend lock period
    function test_lockExtensionVulnerability() public {
        uint256 initialLockPeriod = 1 days;
        
        console.log("--- BEFORE-Trigger (Initial Lock) ---");
        address preOwner = token.owner();
        uint256 preUnlockTime = token.geUnlockTime();
        uint256 preTime = block.timestamp;
        console.log("Pre-Trigger Owner:", preOwner);
        console.log("Pre-Trigger UnlockTime:", preUnlockTime);
        console.log("Pre-Trigger Timestamp:", preTime);

        console.log("--- Trigger Initial Lock ---");
        vm.prank(owner);
        token.lock(initialLockPeriod);

        console.log("--- AFTER-Trigger (Initial Lock) ---");
        address postOwner = token.owner();
        uint256 postUnlockTime = token.geUnlockTime();
        console.log("Post-Trigger Owner:", postOwner);
        console.log("Post-Trigger UnlockTime:", postUnlockTime);
        console.log("State changed:", (preOwner != postOwner) || (preUnlockTime != postUnlockTime));
        assertEq(postOwner, address(0), "Contract not locked after initial lock");
        assertEq(postUnlockTime, preTime + initialLockPeriod, "Unlock time not properly set");

        // Fast forward past unlock time
        skip(initialLockPeriod + 1);
        
        // Unlock and immediately relock with longer duration
        vm.prank(owner);
        token.unlock();
        
        console.log("--- BEFORE-Trigger (Extended Lock) ---");
        preOwner = token.owner();
        preUnlockTime = token.geUnlockTime();
        preTime = block.timestamp;
        console.log("Pre-Trigger Owner:", preOwner);
        console.log("Pre-Trigger UnlockTime:", preUnlockTime);
        console.log("Pre-Trigger Timestamp:", preTime);

        console.log("--- Trigger Extended Lock ---");
        vm.prank(owner);
        token.lock(initialLockPeriod * 2);

        console.log("--- AFTER-Trigger (Extended Lock) ---");
        postOwner = token.owner();
        postUnlockTime = token.geUnlockTime();
        console.log("Post-Trigger Owner:", postOwner);
        console.log("Post-Trigger UnlockTime:", postUnlockTime);
        console.log("State changed:", (preOwner != postOwner) || (preUnlockTime != postUnlockTime));
        assertEq(postOwner, address(0), "Contract not locked after extension");
        assertEq(postUnlockTime, preTime + initialLockPeriod * 2, "Extended unlock time not set");

        // Attempt admin function revert verification
        skip(initialLockPeriod + 1); 
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingWallet(address(0x123));
        
        console.log("Vulnerability Exists: Owner arbitrarily extended lock period beyond initial unlock time");
    }

    // Test 2: New owner can lock immediately after transfer
    function test_newOwnerImmediateLock() public {
        // Transfer ownership to new address
        vm.prank(owner);
        token.transferOwnership(newOwner);
        assertEq(token.owner(), newOwner, "Ownership not transferred");
        
        console.log("--- BEFORE-Trigger (New Owner Lock) ---");
        address preOwner = token.owner();
        uint256 preUnlockTime = token.geUnlockTime();
        uint256 preTime = block.timestamp;
        console.log("Pre-Trigger Owner:", preOwner);
        console.log("Pre-Trigger UnlockTime:", preUnlockTime);
        console.log("Pre-Trigger Timestamp:", preTime);

        console.log("--- Trigger New Owner Lock ---");
        uint256 lockDuration = 365 days;
        vm.prank(newOwner);
        token.lock(lockDuration);

        console.log("--- AFTER-Trigger (New Owner Lock) ---");
        address postOwner = token.owner();
        uint256 postUnlockTime = token.geUnlockTime();
        console.log("Post-Trigger Owner:", postOwner);
        console.log("Post-Trigger UnlockTime:", postUnlockTime);
        console.log("State changed:", (preOwner != postOwner) || (preUnlockTime != postUnlockTime));
        assertEq(postOwner, address(0), "Contract not locked by new owner");
        assertEq(postUnlockTime, preTime + lockDuration, "Unlock time not properly set");

        // Verify lock persists
        vm.prank(newOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setLiquidityFeePercent(10);
        
        console.log("Vulnerability Exists: New owner locked contract immediately after ownership transfer");
    }

    // Test 3: Attacker can lock contract permanently
    function test_attackerPermanentLock() public {
        // Transfer ownership to attacker
        vm.prank(owner);
        token.transferOwnership(attacker);
        assertEq(token.owner(), attacker, "Attack failed: not owner");
        
        console.log("--- BEFORE-Trigger (Permanent Lock) ---");
        address preOwner = token.owner();
        uint256 preUnlockTime = token.geUnlockTime();
        uint256 preTime = block.timestamp;
        console.log("Pre-Trigger Owner:", preOwner);
        console.log("Pre-Trigger UnlockTime:", preUnlockTime);
        console.log("Pre-Trigger Timestamp:", preTime);

        console.log("--- Trigger Permanent Lock ---");
        uint256 lockDuration = 365 days * 100;
        vm.prank(attacker);
        token.lock(lockDuration);

        console.log("--- AFTER-Trigger (Permanent Lock) ---");
        address postOwner = token.owner();
        uint256 postUnlockTime = token.geUnlockTime();
        console.log("Post-Trigger Owner:", postOwner);
        console.log("Post-Trigger UnlockTime:", postUnlockTime);
        console.log("State changed:", (preOwner != postOwner) || (preUnlockTime != postUnlockTime));
        assertEq(postOwner, address(0), "Contract not permanently locked");
        assertEq(postUnlockTime, preTime + lockDuration, "Lock duration not set correctly");

        // Verify lock persists even after long period
        skip(lockDuration / 2); 
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.includeInFee(address(0x456));
        
        console.log("Vulnerability Exists: Attacker permanently locked contract for 100 years");
    }
}