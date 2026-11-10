// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_address.sol";

contract DosGasTest is Test {
    DosGas dosGas;
    address[] creditors;
    uint256 constant CREDIT_THRESHOLD = 100; // Assuming threshold is 100 based on code

    function setUp() public {
        dosGas = new DosGas();
        
        // Initialize creditor addresses (without adding them to storage)
        creditors = new address[](CREDIT_THRESHOLD + 1);
        for (uint256 i = 0; i < CREDIT_THRESHOLD + 1; i++) {
            creditors[i] = address(uint160(i + 1)); // Generate unique addresses
        }
    }

    function testDenialOfService() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 creditorsBefore = dosGas.numberCreditors();
        bool winBefore = dosGas.iWin();
        uint256 totalCreditsBefore = dosGas.totalCredits();
        console.log("Creditors count (before):", creditorsBefore);
        console.log("Win status (before):", winBefore);
        console.log("Total credits (before):", totalCreditsBefore);
        
        console.log("--- Trigger emptyCreditors ---");
        // Execute the critical action
        vm.prank(address(this));
        dosGas.emptyCreditors();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 creditorsAfter = dosGas.numberCreditors();
        bool winAfter = dosGas.iWin();
        uint256 totalCreditsAfter = dosGas.totalCredits();
        console.log("Creditors count (after):", creditorsAfter);
        console.log("Win status (after):", winAfter);
        console.log("Total credits (after):", totalCreditsAfter);
        
        // State validation
        bool winStatusChanged = winAfter != winBefore;
        bool creditsChanged = totalCreditsAfter != totalCreditsBefore;
        
        // Vulnerability verdict
        if (winStatusChanged) {
            console.log("Vulnerability Exists: Win status changed unexpectedly");
        } else if (creditsChanged) {
            console.log("Vulnerability Exists: Credits changed unexpectedly");
        } else {
            console.log("Vulnerability not Exist: No unexpected state changes");
        }
    }

    function testGasConsumption() public {
        // Gas measurement (unchanged)
        uint256 gasBefore = gasleft();
        dosGas.emptyCreditors();
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used:", gasUsed);
    }
}