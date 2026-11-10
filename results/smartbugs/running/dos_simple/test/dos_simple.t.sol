// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_simple.sol";

contract DosOneFuncTest is Test {
    DosOneFunc public dosContract;
    address attacker = address(0xBAD);

    function setUp() public {
        dosContract = new DosOneFunc();
    }

    function testArrayFillDoS() public {
        // Record state BEFORE attack
        uint resetCountBefore = dosContract.arrayResetCount();
        (uint attackerContributionsBefore, uint attackerArraySizeBefore) = dosContract.getParticipantStats(attacker);

        console.log("\n--- BEFORE-Trigger Attack ---");
        console.log("Reset count before attack:", resetCountBefore);
        console.log("Attacker contributions before:", attackerContributionsBefore);
        console.log("Attacker array size before:", attackerArraySizeBefore);

        console.log("\n--- Trigger Attack ---");
        // Attacker starts filling the array repeatedly
        vm.startPrank(attacker);

        // First fill should succeed
        bool success = dosContract.ifillArray();
        assertTrue(success);

        // Subsequent fills cause the array to grow large and reset
        for (uint i = 0; i < 5; i++) {
            dosContract.ifillArray();
        }

        vm.stopPrank();

        // Record state AFTER attack
        uint resetCountAfter = dosContract.arrayResetCount();
        (uint attackerContributionsAfter, uint attackerArraySizeAfter) = dosContract.getParticipantStats(attacker);

        console.log("\n--- AFTER-Trigger Attack ---");
        console.log("Reset count after attack:", resetCountAfter);
        console.log("Attacker contributions after:", attackerContributionsAfter);
        console.log("Attacker array size after:", attackerArraySizeAfter);

        // Vulnerability detection logic
        bool vulnerabilityExists = 
            resetCountAfter > resetCountBefore && 
            attackerArraySizeAfter == 0;
        
        // Vulnerability verdict
        if (vulnerabilityExists) {
            console.log("\nVulnerability Exists: Attack caused %d array resets and reset attacker's array size to 0", resetCountAfter - resetCountBefore);
        } else {
            console.log("\nVulnerability not Exist: No state changes indicative of DoS vulnerability");
        }

        // Existing test verifications
        assertGt(attackerContributionsAfter, 0);
        assertEq(attackerArraySizeAfter, 0);
    }

    function testGasConsumption() public {
        vm.startPrank(attacker);

        // Measure gas consumption of first fill
        uint gasBefore = gasleft();
        dosContract.ifillArray();
        uint gasUsedFirstFill = gasBefore - gasleft();

        // Measure gas consumption after several fills
        gasBefore = gasleft();
        for (uint i = 0; i < 4; i++) {
            dosContract.ifillArray();
        }
        uint gasUsedLaterFill = gasBefore - gasleft();

        vm.stopPrank();

        // Show that gas consumption increases significantly
        console.log("Gas used first fill:", gasUsedFirstFill);
        console.log("Gas used later fills:", gasUsedLaterFill);
        assertGt(gasUsedLaterFill, gasUsedFirstFill * 3);
    }
}