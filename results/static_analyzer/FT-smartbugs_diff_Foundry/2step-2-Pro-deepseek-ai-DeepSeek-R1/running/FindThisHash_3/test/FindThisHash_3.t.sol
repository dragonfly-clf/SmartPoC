// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FindThisHash.sol";

contract FindThisHashTest is Test {
    FindThisHash findThisHash;
    address user = address(1);

    function setUp() public {
        // Deploy contract with sufficient funds
        vm.deal(address(this), 1000 ether);
        findThisHash = new FindThisHash{value: 1000 ether}();

        // Set up test user
        vm.deal(user, 1 ether);
    }

    // Test that empty string is accepted without validation
    function testEmptyStringInput() public {
        // Get pre-attempt values
        (uint prePlayerAttempts,) = findThisHash.getPlayerStats(user);
        uint preTotalAttempts = findThisHash.totalAttempts();
        
        // Log pre-trigger state
        console.log("--- BEFORE-Trigger ---");
        console.log("Player attempts:", prePlayerAttempts);
        console.log("Total attempts:", preTotalAttempts);
        console.log("");

        // Execute the call with empty string
        console.log("--- Trigger: attemptHash('') ---");
        vm.prank(user);
        findThisHash.attemptHash("");

        // Get post-attempt values
        (uint postPlayerAttempts,) = findThisHash.getPlayerStats(user);
        uint postTotalAttempts = findThisHash.totalAttempts();
        
        // Log post-trigger state
        console.log("--- AFTER-Trigger ---");
        console.log("Player attempts:", postPlayerAttempts);
        console.log("Total attempts:", postTotalAttempts);
        console.log("");

        // Vulnerability verdict
        if (postPlayerAttempts == prePlayerAttempts + 1) {
            console.log("Vulnerability Exists: Player attempts increased despite empty input");
        } else {
            console.log("Vulnerability not Exist: Player attempts unchanged (rejected?)");
        }
        
        if (postTotalAttempts == preTotalAttempts + 1) {
            console.log("Vulnerability Exists: Total attempts increased despite empty input");
        } else {
            console.log("Vulnerability not Exist: Total attempts unchanged (rejected?)");
        }

        // Explicit vulnerability verdict
        if (postPlayerAttempts == prePlayerAttempts + 1 && postTotalAttempts == preTotalAttempts + 1) {
            console.log("Vulnerability Exists: Contract accepted empty string and incremented counters");
        } else {
            console.log("Vulnerability not Exist: Counters unchanged - input validation successful");
        }

        // Verify attempt counters incremented
        assertEq(postPlayerAttempts, prePlayerAttempts + 1, "Player attempts not updated");
        assertEq(postTotalAttempts, preTotalAttempts + 1, "Total attempts not updated");
    }

    // Test that excessively long strings are accepted
    function testLongStringInput() public {
        // Generate a very long string (32000 characters)
        string memory longStr = string(new bytes(32000));

        // Get pre-attempt values
        (uint prePlayerAttempts,) = findThisHash.getPlayerStats(user);
        uint preTotalAttempts = findThisHash.totalAttempts();
        
        // Log pre-trigger state
        console.log("--- BEFORE-Trigger ---");
        console.log("Player attempts:", prePlayerAttempts);
        console.log("Total attempts:", preTotalAttempts);
        console.log("");

        // Execute the call with long string
        console.log("--- Trigger: attemptHash(very long string) ---");
        vm.prank(user);
        findThisHash.attemptHash(longStr);

        // Get post-attempt values
        (uint postPlayerAttempts,) = findThisHash.getPlayerStats(user);
        uint postTotalAttempts = findThisHash.totalAttempts();
        
        // Log post-trigger state
        console.log("--- AFTER-Trigger ---");
        console.log("Player attempts:", postPlayerAttempts);
        console.log("Total attempts:", postTotalAttempts);
        console.log("");

        // Vulnerability verdict
        if (postPlayerAttempts == prePlayerAttempts + 1) {
            console.log("Vulnerability Exists: Player attempts increased despite oversized input");
        } else {
            console.log("Vulnerability not Exist: Player attempts unchanged (rejected?)");
        }
        
        if (postTotalAttempts == preTotalAttempts + 1) {
            console.log("Vulnerability Exists: Total attempts increased despite oversized input");
        } else {
            console.log("Vulnerability not Exist: Total attempts unchanged (rejected?)");
        }

        // Explicit vulnerability verdict
        if (postPlayerAttempts == prePlayerAttempts + 1 && postTotalAttempts == preTotalAttempts + 1) {
            console.log("Vulnerability Exists: Contract accepted oversized string and incremented counters");
        } else {
            console.log("Vulnerability not Exist: Counters unchanged - input validation successful");
        }

        // Verify attempt counters incremented
        assertEq(postPlayerAttempts, prePlayerAttempts + 1, "Player attempts not updated");
        assertEq(postTotalAttempts, preTotalAttempts + 1, "Total attempts not updated");
    }
}