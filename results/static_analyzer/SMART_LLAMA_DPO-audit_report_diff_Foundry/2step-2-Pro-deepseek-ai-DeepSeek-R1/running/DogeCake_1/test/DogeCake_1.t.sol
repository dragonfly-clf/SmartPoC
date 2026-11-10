// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DogeCake.sol";

contract GasManipulationTest is Test {
    CakeDividendTracker public tracker;
    address public holder = address(0xB);
    uint256 public constant MIN_TOKEN_BALANCE = 200000 * (10**18);

    function setUp() public {
        tracker = new CakeDividendTracker();
        tracker.setBalance(payable(holder), MIN_TOKEN_BALANCE);
        vm.warp(block.timestamp + 3601);
    }

    function testLowGasProcessing() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialIndex = tracker.lastProcessedIndex();
        uint256 initialClaimTime = tracker.lastClaimTimes(holder);
        console.log("Last Processed Index (before):", initialIndex);
        console.log("Last Claim Time (before):", initialClaimTime);

        console.log("--- Trigger: tracker.process(0) ---");
        (uint256 iterations, uint256 claims, uint256 newIndex) = tracker.process(0);

        console.log("--- AFTER-Trigger State ---");
        uint256 currentIndex = tracker.lastProcessedIndex();
        uint256 currentClaimTime = tracker.lastClaimTimes(holder);
        console.log("Last Processed Index (after):", currentIndex);
        console.log("Last Claim Time (after):", currentClaimTime);

        // Compare state changes
        bool isIndexChanged = (currentIndex != initialIndex);
        bool isClaimTimeChanged = (currentClaimTime != initialClaimTime);
        bool vulnerabilityExists = isIndexChanged || isClaimTimeChanged;

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Unauthorized state change in processing state or claim time");
        } else {
            console.log("Vulnerability not Exist: No changes in processing state or claim times");
        }

        // Original assertions
        assertEq(iterations, 0, "Iterations should be 0");
        assertEq(claims, 0, "Claims should be 0");
        assertEq(newIndex, initialIndex, "Last processed index should not change");
    }
}