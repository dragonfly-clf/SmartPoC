// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unchecked_return_value.sol";

contract ReturnValueTest is Test {
    ReturnValue returnValueContract;
    address maliciousContract;

    function setUp() public {
        returnValueContract = new ReturnValue();
        
        // Deploy a malicious contract that will fail when receiving ETH
        maliciousContract = address(new MaliciousContract());
    }

    function testUncheckedCallVulnerability() public {
        console2.log("--- BEFORE-Trigger State ---");
        (uint256 initialCalls, uint256 initialSuccessful) = returnValueContract.getCallStats(maliciousContract);
        uint256 initialTotalCalls = returnValueContract.totalCalls();
        console2.log("Malicious contract calls count: %s", initialCalls);
        console2.log("Malicious contract successful calls: %s", initialSuccessful);
        console2.log("Total calls in contract: %s", initialTotalCalls);

        console2.log("--- Trigger callnotchecked ---");
        returnValueContract.callnotchecked(maliciousContract);
        console2.log("Called vulnerable function with malicious contract");

        console2.log("--- AFTER-Trigger State ---");
        (uint256 afterCalls, uint256 afterSuccessful) = returnValueContract.getCallStats(maliciousContract);
        uint256 afterTotalCalls = returnValueContract.totalCalls();
        console2.log("Malicious contract calls count: %s", afterCalls);
        console2.log("Malicious contract successful calls: %s", afterSuccessful);
        console2.log("Total calls in contract: %s", afterTotalCalls);

        console2.log("--- Comparison ---");
        bool callsIncreased = afterCalls == initialCalls + 1;
        bool successfulUnchanged = afterSuccessful == initialSuccessful;
        bool totalCallsIncreased = afterTotalCalls == initialTotalCalls + 1;
        
        console2.log("Calls to malicious contract increased: %s", callsIncreased ? "YES" : "NO");
        console2.log("Successful calls unchanged: %s", successfulUnchanged ? "YES" : "NO");
        console2.log("Total calls increased: %s", totalCallsIncreased ? "YES" : "NO");
        
        // Vulnerability exists if all three conditions are met
        if (callsIncreased && successfulUnchanged && totalCallsIncreased) {
            console2.log("Vulnerability Exists: Counters increased despite failed call");
        } else {
            console2.log("Vulnerability not Exist: Counters not increased as expected after failed call");
        }

        // Keep original assertions for test integrity
        assertEq(afterCalls, initialCalls + 1, "Call count should increase even when call fails");
        assertEq(afterSuccessful, initialSuccessful, "Successful calls should not increase");
        assertEq(afterTotalCalls, initialTotalCalls + 1, "Total calls should increase even when call fails");
    }
}

contract MaliciousContract {
    // This contract will make any call to it fail
    fallback() external {
        revert("I reject all calls");
    }
}