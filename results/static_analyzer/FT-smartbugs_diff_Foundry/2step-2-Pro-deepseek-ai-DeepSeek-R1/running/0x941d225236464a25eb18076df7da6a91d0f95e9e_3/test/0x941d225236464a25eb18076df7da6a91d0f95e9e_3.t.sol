// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/0x941d225236464a25eb18076df7da6a91d0f95e9e.sol";

contract AddMessageGasTest is Test {
    Log public logContract;
    address user = address(0x123);
    uint value = 1 ether;
    string data = "Sample log data";

    function setUp() public {
        logContract = new Log();
    }

    function testHighGasCost() public {
        // Measure initial call
        uint startGas1 = gasleft();
        logContract.AddMessage(user, value, data);
        uint gasUsed1 = startGas1 - gasleft();
        console.log("Gas used for first log entry:", gasUsed1);

        // Store total gas used
        uint totalGas = gasUsed1;
        
        // Add 1000 additional log entries and track gas
        for (uint i = 0; i < 1000; i++) {
            uint startLoopGas = gasleft();
            logContract.AddMessage(user, value, data);
            uint gasUsedThisCall = startLoopGas - gasleft();
            totalGas += gasUsedThisCall;
            
            // Log gas used for the 1000th entry
            if (i == 999) {
                console.log("Gas used for last (1000th) log entry:", gasUsedThisCall);
            }
        }

        console.log("Total gas used for 1001 log entries:", totalGas);
        
        // Vulnerability verdict based on gas cost
        if (totalGas > 90_000_000) {
            console.log("Vulnerability Exists: Gas consumption too high (>90M gas)");
        } else {
            console.log("Vulnerability not Exist: Gas consumption is acceptable");
        }
    }
}