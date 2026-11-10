// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_number.sol";

contract DosNumberTest is Test {
    DosNumber dosNumber;
    address attacker = address(0x1337);

    function setUp() public {
        dosNumber = new DosNumber();
        vm.deal(attacker, 1 ether);
    }

    function testDenialOfServicePotential() public {
        console2.log("\n----- Starting testDenialOfServicePotential -----");
        vm.startPrank(attacker);

        // Pre-state for initial insert
        uint initialLength = dosNumber.getRealLengthArray();
        (uint initialInserts, uint initialArrayLength) = dosNumber.getUserStats(attacker);
        uint initialTotalInserts = dosNumber.totalInserts();

        console2.log("--- BEFORE initial insert ---");
        console2.log("Real array length:", initialLength);
        console2.log("Attacker inserts:", initialInserts);
        console2.log("Total inserts:", initialTotalInserts);

        // Initial small insert
        console2.log("--- TRIGGER: Initial insertNnumbers(1, 10) ---");
        dosNumber.insertNnumbers(1, 10);
        
        // Pre-trigger state for large insert
        uint preRealLength = dosNumber.getRealLengthArray();
        (uint preUserInserts, uint preUserLength) = dosNumber.getUserStats(attacker);
        uint preTotalInserts = dosNumber.totalInserts();
        
        console2.log("--- BEFORE large insert ---");
        console2.log("Real array length:", preRealLength);
        console2.log("Attacker inserts:", preUserInserts);
        console2.log("Total inserts:", preTotalInserts);
        
        // Test large insert
        uint largeNumber = 10_000;
        console2.log("--- TRIGGER: Large insertNnumbers(2, %d) ---", largeNumber);
        uint gasBefore = gasleft();
        dosNumber.insertNnumbers(2, largeNumber);
        uint gasUsed = gasBefore - gasleft();
        
        // Post-trigger state
        uint postRealLength = dosNumber.getRealLengthArray();
        (uint postUserInserts, uint postUserLength) = dosNumber.getUserStats(attacker);
        uint postTotalInserts = dosNumber.totalInserts();
        
        console2.log("--- AFTER large insert ---");
        console2.log("Real array length:", postRealLength);
        console2.log("Attacker inserts:", postUserInserts);
        console2.log("Total inserts:", postTotalInserts);
        console2.log("Gas used:", gasUsed);
        
        // State change analysis
        console2.log("--- STATE CHANGES ---");
        console2.log("Real array growth:", postRealLength - preRealLength);
        console2.log("Attacker inserts growth:", postUserInserts - preUserInserts);
        console2.log("Total inserts growth:", postTotalInserts - preTotalInserts);
        
        // Vulnerability verdict
        if (gasUsed > 500_000) {
            console2.log("Vulnerability Exists: High gas consumption (%d > 500000) indicates DOS risk", gasUsed);
            console2.log("Vulnerability Exists: High gas consumption in large insertion");
        } else {
            console2.log("Vulnerability not Exist: Gas consumption (%d <= 500000) acceptable", gasUsed);
        }
        
        vm.stopPrank();
    }

    function testArrayGrowthMechanism() public {
        console2.log("\n----- Starting testArrayGrowthMechanism -----");
        vm.startPrank(attacker);
        
        // Pre-trigger state
        uint realLengthBefore = dosNumber.getRealLengthArray();
        (uint userInsertsBefore, ) = dosNumber.getUserStats(attacker);
        uint totalInsertsBefore = dosNumber.totalInserts();
        
        console2.log("--- BEFORE inserts ---");
        console2.log("Real array length:", realLengthBefore);
        console2.log("Attacker inserts:", userInsertsBefore);
        console2.log("Total inserts:", totalInsertsBefore);
        
        // Trigger growth mechanism
        console2.log("--- TRIGGER: 10x insertNnumbers(i, 100) ---");
        for (uint i = 0; i < 10; i++) {
            dosNumber.insertNnumbers(i, 100);
        }
        
        // Post-trigger state
        uint realLengthAfter = dosNumber.getRealLengthArray();
        (uint userInsertsAfter, ) = dosNumber.getUserStats(attacker);
        uint totalInsertsAfter = dosNumber.totalInserts();
        
        console2.log("--- AFTER inserts ---");
        console2.log("Real array length:", realLengthAfter);
        console2.log("Attacker inserts:", userInsertsAfter);
        console2.log("Total inserts:", totalInsertsAfter);
        
        // State change analysis
        console2.log("--- STATE CHANGES ---");
        console2.log("Real array growth:", realLengthAfter - realLengthBefore);
        console2.log("Attacker inserts growth:", userInsertsAfter - userInsertsBefore);
        console2.log("Total inserts growth:", totalInsertsAfter - totalInsertsBefore);
        
        // Verify array growth
        if (realLengthAfter > realLengthBefore) {
            console2.log("Vulnerability not Exist: Array growth mechanism functional (%d items added)", 
                        totalInsertsAfter - totalInsertsBefore);
        } else {
            console2.log("Vulnerability Exists: Array growth failed (%d total inserts with no length change)", 
                        totalInsertsAfter - totalInsertsBefore);
            console2.log("Vulnerability Exists: Array growth mechanism failure");
        }
    }
}