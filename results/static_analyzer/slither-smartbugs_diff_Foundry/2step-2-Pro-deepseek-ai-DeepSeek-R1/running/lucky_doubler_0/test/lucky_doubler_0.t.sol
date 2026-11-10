// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lucky_doubler.sol";

contract LuckyDoublerWeakPRNGTest is Test {
    LuckyDoubler public doubler;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address charlie = address(0x4);

    function setUp() public {
        // Setup owner and deploy contract
        vm.startPrank(owner);
        doubler = new LuckyDoubler();
        doubler.changeFee(0); // Set fee to 0
        vm.stopPrank();

        // Fund Alice and Bob
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);

        // Alice joins in block 2
        vm.roll(2);
        vm.prank(alice);
        (bool aliceSuccess, ) = payable(address(doubler)).call{value: 1 ether}("");
        require(aliceSuccess, "Alice join failed");

        // Bob joins in block 3
        vm.roll(3);
        vm.prank(bob);
        (bool bobSuccess, ) = payable(address(doubler)).call{value: 1 ether}("");
        require(bobSuccess, "Bob join failed");
    }

    // Helper to log entry states
    function _logEntriesState() internal view {
        console.log(">>> ENTRY STATE DETAILS");
        for (uint i = 0; i < 3; i++) {
            (,, bool paid, ) = doubler.entryDetails(i);
            console.log("Index: ", i);
            console.log("Paid status: ", paid);
        }
    }

    function test_WeakPRNGIsDeterministic() public {
        // Setup charlie and move to block 4
        vm.deal(charlie, 1 ether);
        vm.roll(4);
        uint snapshot = vm.snapshot();

        console.log("\n---------- FIRST RUN ----------");
        console.log("--- BEFORE-Trigger ---");
        _logEntriesState();

        console.log("\n--- Trigger (First Charlie Join) ---");
        vm.prank(charlie);
        (bool charlieSuccess, ) = payable(address(doubler)).call{value: 1 ether}("");
        require(charlieSuccess, "Charlie join failed");

        console.log("\n--- AFTER-Trigger ---");
        _logEntriesState();
        uint paidIndex1 = _getPaidEntryIndex();
        console.log("Paid Entry Index (First Run):", paidIndex1);

        // Revert and replay with same block context
        vm.revertTo(snapshot);

        console.log("\n---------- SECOND RUN ----------");
        console.log("--- BEFORE-Trigger ---");
        _logEntriesState();

        console.log("\n--- Trigger (Second Charlie Join) ---");
        vm.prank(charlie);
        (charlieSuccess, ) = payable(address(doubler)).call{value: 1 ether}("");
        require(charlieSuccess, "Charlie join failed");

        console.log("\n--- AFTER-Trigger ---");
        _logEntriesState();
        uint paidIndex2 = _getPaidEntryIndex();
        console.log("Paid Entry Index (Second Run):", paidIndex2);

        // Final comparison verdict
        console.log("\n========== VERDICT ==========");
        if (paidIndex1 == paidIndex2) {
            console.log("Vulnerability Exists: PRNG always pays same index (%s) in identical conditions", paidIndex1);
        } else {
            console.log("Vulnerability not Exist: Paid index changed (%s vs %s) in identical conditions", paidIndex1, paidIndex2);
        }
    }

    function _getPaidEntryIndex() private view returns (uint) {
        for (uint i = 0; i < 3; i++) {
            (,, bool paid, ) = doubler.entryDetails(i);
            if (paid) return i;
        }
        revert("No paid entry found");
    }
}