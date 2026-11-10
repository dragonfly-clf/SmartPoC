// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract VaultProxyTest is Test {
    VaultProxy vault;
    address owner = address(0xAAA);
    address nonOwner = address(0xBBB);
    address newOwner = address(0xCCC);

    function setUp() public {
        vm.prank(owner);
        vault = new VaultProxy();
        
        // Verify initial owner is set correctly
        bytes32 ownerSlot = vm.load(address(vault), bytes32(0));
        assertEq(address(uint160(uint256(ownerSlot))), owner, "Contract not deployed with correct owner");
    }

    function test_UnderflowVulnerability() public {
        // Record initial owner from storage
        bytes32 initialOwnerSlot = vm.load(address(vault), bytes32(0));
        address ownerBefore = address(uint160(uint256(initialOwnerSlot)));
        console.log("--- BEFORE-Trigger State ---");
        console.log("Owner (storage slot):", ownerBefore);

        // Trigger action 1: Non-owner attempts transfer
        console.log("--- Trigger: nonOwner calls transferOwner ---");
        vm.prank(nonOwner);
        (bool success,) = address(vault).call(
            abi.encodeWithSignature("transferOwner(address)", nonOwner)
        );
        assertTrue(success, "Call should succeed but not change state");

        // Check state after first trigger
        bytes32 tempOwnerSlot = vm.load(address(vault), bytes32(0));
        address ownerAfterFirst = address(uint160(uint256(tempOwnerSlot)));
        console.log("--- AFTER-Trigger State 1 ---");
        console.log("Owner (storage slot):", ownerAfterFirst);

        // Determine state change
        bool ownerChanged = (ownerAfterFirst != ownerBefore);
        console.log("Owner changed after nonOwner call?", ownerChanged ? "YES" : "NO");
        console.log("--- Secondary Action: Owner transfer ---");

        // Owner transfers ownership
        vm.prank(owner);
        vault.transferOwner(newOwner);

        // Final owner check
        bytes32 finalOwnerSlot = vm.load(address(vault), bytes32(0));
        address finalOwner = address(uint160(uint256(finalOwnerSlot)));
        console.log("Final owner:", finalOwner);

        // Vulnerability verdict
        if (ownerChanged) {
            console.log("Vulnerability Exists: non-owner successfully changed owner state");
        } else {
            console.log("Vulnerability not Exist: non-owner could not change owner state");
        }
    }
}