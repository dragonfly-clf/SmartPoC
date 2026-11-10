// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x84d9ec85c9c568eb332b7226a8f826d897e0a4a8.sol";

contract WedIndexTest is Test {
    WedIndex public wedIndex;
    
    function setUp() public {
        wedIndex = new WedIndex();
    }

    function testTimestampManipulation() public {
        // Define parameters to write to index
        uint dummyId = 0;
        string memory addressA = "123 Main St";
        string memory partnersA = "Alice & Bob";
        uint weddingDateA = block.timestamp + 365 days;
        uint displayValueA = 1;
        
        bool vulnerabilityExists = true;
        string memory verdictReason = "";

        console.log("--- BEFORE-Trigger Write1 ---");
        uint initialCount = wedIndex.numberOfIndex();
        console.log("Initial index count:", initialCount);
        if (initialCount != 0) {
            verdictReason = "Initial count should be 0";
            vulnerabilityExists = false;
            console.log("FAIL:", verdictReason);
        }

        uint originalTimestamp = block.timestamp;

        console.log("--- Trigger Write1 Operation ---");
        wedIndex.writeIndex(dummyId, addressA, partnersA, weddingDateA, displayValueA);

        console.log("--- AFTER-Trigger Write1 ---");
        uint countAfterFirst = wedIndex.numberOfIndex();
        console.log("Number of entries after first write:", countAfterFirst);
        
        // Validate state after first write
        if (countAfterFirst != 1) {
            verdictReason = "Should have 1 entry after first write";
            console.log("FAIL:", verdictReason);
            vulnerabilityExists = false;
        }

        console.log("--- Trigger Warp Operation ---");
        uint warpAmount = 1 hours;
        uint newTimestamp = block.timestamp + warpAmount;
        vm.warp(newTimestamp);
        console.log("Advanced timestamp by %s seconds to: %s", warpAmount, newTimestamp);

        console.log("--- Trigger Write2 Operation ---");
        bool secondWriteSuccess = true;
        try wedIndex.writeIndex(dummyId, addressA, partnersA, weddingDateA, displayValueA) {
            console.log("Second write succeeded");
        } catch {
            secondWriteSuccess = false;
            console.log("Second write failed (reverted)");
        }

        console.log("--- AFTER-Trigger Write2 ---");
        uint countAfterSecond = wedIndex.numberOfIndex();
        console.log("Final entry count:", countAfterSecond);

        // Validate state after second write
        if (secondWriteSuccess) {
            if (countAfterSecond != 2) {
                verdictReason = "Should have 2 entries after second write";
                console.log("FAIL:", verdictReason);
                vulnerabilityExists = false;
            }
        } else {
            verdictReason = "Second write reverted";
            vulnerabilityExists = false;
            console.log("FAIL:", verdictReason);
        }

        // Final vulnerability verdict (FIXED: proper empty string check)
        if (vulnerabilityExists && countAfterSecond == 2) {
            console.log("Vulnerability Exists: Duplicate records created through timestamp manipulation");
        } else {
            if (bytes(verdictReason).length == 0) {
                verdictReason = "Validation checks failed";
            }
            console.log("Vulnerability not Exist: %s", verdictReason);
        }
    }
}