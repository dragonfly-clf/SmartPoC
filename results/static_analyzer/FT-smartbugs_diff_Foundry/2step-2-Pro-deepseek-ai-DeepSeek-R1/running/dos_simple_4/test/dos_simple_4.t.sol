// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_simple.sol";

contract DosOneFuncTest is Test {
    DosOneFunc public dosContract;
    address testUser = address(0xABCD);
    
    function setUp() public {
        dosContract = new DosOneFunc();
    }

    function test_gasInefficiencyInFillArray() public {
        vm.startPrank(testUser);
        
        // Get initial state
        (uint initialContribution, uint initialSize) = dosContract.getParticipantStats(testUser);
        emit log("--- BEFORE-Trigger ---");
        emit log_named_uint("Initial Contribution", initialContribution);
        emit log_named_uint("Initial Size", initialSize);
        assertEq(initialContribution, 0);
        assertEq(initialSize, 0);

        emit log("--- Trigger Operation ---");
        emit log("Calling ifillArray()");
        
        // Measure gas usage
        uint gasStart = gasleft();
        bool result = dosContract.ifillArray();
        uint gasUsed = gasStart - gasleft();

        // Get state after operation
        (uint finalContribution, uint finalSize) = dosContract.getParticipantStats(testUser);
        emit log("--- AFTER-Trigger ---");
        emit log_named_uint("Final Contribution", finalContribution);
        emit log_named_uint("Final Size", finalSize);
        emit log_named_uint("Gas used for ifillArray", gasUsed);

        // Validate state updates
        assertTrue(result, "Function should return true when array < 1500");
        assertEq(finalContribution, 350, "Contributions not recorded");
        assertEq(finalSize, 350, "Array size not increased");

        // Final vulnerability verdict based on gas consumption
        if (gasUsed > 1_000_000) {
            emit log("Vulnerability Exists: Gas consumption exceeds acceptable limit (1,000,000 gas)");
        } else {
            emit log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
        
        vm.stopPrank();
    }
}