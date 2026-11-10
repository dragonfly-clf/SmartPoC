// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/unchecked_return_value.sol";

contract ReturnValueTest is Test {
    ReturnValue public targetContract;
    
    // Fail contract with reverting fallback
    address constant FAIL_ADDRESS = address(0xDEAF);
    // Success contract with successful fallback
    address constant SUCCESS_ADDRESS = address(0xBEEF);

    function setUp() public {
        targetContract = new ReturnValue();
        
        // Set up fail contract
        vm.etch(FAIL_ADDRESS, hex"6005600C60003960056000F3");
        vm.label(FAIL_ADDRESS, "FailContract");

        // Set up success contract
        vm.etch(SUCCESS_ADDRESS, hex"6001600C60003960016000F3");
        vm.label(SUCCESS_ADDRESS, "SuccessContract");
    }

    function test_callnotchecked_failure() public {
        console.log("--- BEFORE-Trigger Call ---");
        (uint256 prevCalls, uint256 prevSuccesses) = targetContract.getCallStats(FAIL_ADDRESS);
        uint256 prevTotalCalls = targetContract.totalCalls();
        console.log("Pre-call stats for FAIL_ADDRESS:");
        console.log("  Calls: ", prevCalls);
        console.log("  Successes: ", prevSuccesses);
        console.log("Pre-call totalCalls: ", prevTotalCalls);

        console.log("--- Trigger callnotchecked to FAIL_ADDRESS ---");
        targetContract.callnotchecked(FAIL_ADDRESS);

        console.log("--- AFTER-Trigger Call ---");
        (uint256 postCalls, uint256 postSuccesses) = targetContract.getCallStats(FAIL_ADDRESS);
        uint256 postTotalCalls = targetContract.totalCalls();
        console.log("Post-call stats for FAIL_ADDRESS:");
        console.log("  Calls: ", postCalls);
        console.log("  Successes: ", postSuccesses);
        console.log("Post-call totalCalls: ", postTotalCalls);

        bool callsIncreased = postCalls == prevCalls + 1;
        bool successesUnchanged = postSuccesses == prevSuccesses;
        bool totalCallsIncreased = postTotalCalls == prevTotalCalls + 1;
        bool vulnerabilityExists = callsIncreased && successesUnchanged && totalCallsIncreased;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: call counters increased despite failed external call");
        } else {
            console.log("Vulnerability not Exist: call counters update behavior is correct");
        }
    }

    function test_callnotchecked_success() public {
        // Verified working call for comparison
        targetContract.callnotchecked(SUCCESS_ADDRESS);
    }
}