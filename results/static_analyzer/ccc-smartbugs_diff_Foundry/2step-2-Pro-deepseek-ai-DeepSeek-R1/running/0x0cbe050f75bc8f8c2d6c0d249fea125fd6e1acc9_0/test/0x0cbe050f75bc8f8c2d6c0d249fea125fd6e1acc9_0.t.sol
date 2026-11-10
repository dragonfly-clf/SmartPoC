// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x0cbe050f75bc8f8c2d6c0d249fea125fd6e1acc9.sol";

contract CallerTest is Test {
    Caller public caller;
    Reverter public reverter;

    function setUp() public {
        // Deploy original vulnerable contract and helper reverter contract
        caller = new Caller();
        reverter = new Reverter();
    }

    function test_CallAddressWithRevertingContract() public {
        // Setup: Create new reverter instance
        Reverter newReverter = new Reverter();

        // Verify that external call to reverter contract always fails
        (bool directCallSuccess, ) = address(newReverter).call("");
        assertFalse(directCallSuccess, "Direct call to Reverter should fail");

        // Record state before vulnerability trigger
        uint256 totalCallsBefore = caller.totalCalls();
        uint256 callCountsBefore = caller.callCounts(address(this));
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Total calls before:", totalCallsBefore);
        console.log("Call counts (test contract) before:", callCountsBefore);

        console.log("--- Trigger CallAddress ---");
        // Execute the vulnerable function
        caller.callAddress(address(newReverter));

        // Record state after vulnerability trigger
        console.log("--- AFTER-Trigger State ---");
        uint256 totalCallsAfter = caller.totalCalls();
        uint256 callCountsAfter = caller.callCounts(address(this));
        console.log("Total calls after:", totalCallsAfter);
        console.log("Call counts (test contract) after:", callCountsAfter);

        // Compare state differences
        bool totalCallsIncreased = totalCallsAfter > totalCallsBefore;
        bool callCountsIncreased = callCountsAfter > callCountsBefore;
        
        console.log("Vulnerability verification:");
        console.log("- Total calls increased?", totalCallsIncreased ? "YES" : "NO");
        console.log("- Call counts increased?", callCountsIncreased ? "YES" : "NO");
        
        // Final verdict based on state changes
        if (totalCallsIncreased && callCountsIncreased) {
            console.log("Vulnerability Exists: State variables updated despite failed external call");
        } else {
            console.log("Vulnerability not Exist: No unexpected state changes detected");
        }
    }
}

contract Reverter {
    fallback() external payable {
        revert("Reverter: always reverts");
    }
}