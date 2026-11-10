// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_simple.sol";

contract DosOneFuncTest is Test {
    DosOneFunc public dosContract;
    address public alice = makeAddr("alice");

    event ArrayFilled(address indexed participant, uint newLength);

    function setUp() public {
        dosContract = new DosOneFunc();
    }

    function test_arrayFilledEvent() public {
        // --- BEFORE-Trigger getParticipantStats ---
        (uint beforeContribAlice, uint beforeGlobalArraySize) = dosContract.getParticipantStats(alice);
        console.log("--- BEFORE-Trigger getParticipantStats ---");
        console.log("Alice's contributions (before):", beforeContribAlice);
        console.log("Global array size (before):", beforeGlobalArraySize);
        
        // --- Trigger ifillArray ---
        console.log("--- Trigger ifillArray ---");
        // Define expected values
        uint expectedLength = 350;

        // Expect proper event emission
        vm.expectEmit(true, true, false, false);
        emit ArrayFilled(alice, expectedLength);

        // Call function under test
        vm.prank(alice);
        bool success = dosContract.ifillArray();

        // Verify event and function outcome
        assertTrue(success, "Function should return true for first call");

        // --- AFTER-Trigger getParticipantStats ---
        (uint afterContribAlice, uint afterGlobalArraySize) = dosContract.getParticipantStats(alice);
        console.log("--- AFTER-Trigger getParticipantStats ---");
        console.log("Alice's contributions (after):", afterContribAlice);
        console.log("Global array size (after):", afterGlobalArraySize);
        
        // Calculate differences
        uint diffContributions = afterContribAlice - beforeContribAlice;
        uint diffArraySize = afterGlobalArraySize - beforeGlobalArraySize;
        console.log("Contributions difference:", diffContributions);
        console.log("Array size difference:", diffArraySize);
        
        // Determine if vulnerability exists
        bool stateNotUpdated = (diffContributions != 350) || (diffArraySize != 350);
        if (stateNotUpdated) {
            console.log("Vulnerability Exists: State variables were not updated by 350 as expected");
        } else {
            console.log("Vulnerability not Exist: State updated correctly by 350");
        }
    }
}