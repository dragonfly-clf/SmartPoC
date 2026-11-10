// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetSwampERC20Token.sol";

contract MockSetUser {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet internal set_;

    function insert(uint256 index, address value) external returns (bool) {
        return set_.insert(index, value);
    }

    function length() external view returns (uint256) {
        return set_.length();
    }
}

contract EnumerableSetTest is Test {
    MockSetUser mockSet;

    function setUp() public {
        mockSet = new MockSetUser();
    }

    function test_InsertRevertsOnEmptySet() public {
        // Ensure the set is initially empty
        uint256 initialLength = mockSet.length();
        console.log("--- BEFORE-Trigger Call Insert ---");
        console.log("Set length:");
        console.log(initialLength);
        assertEq(initialLength, 0, "Set should be empty initially");

        address addr = address(0x123);

        console.log("--- Trigger Call Insert ---");
        // Track if the insert operation reverts
        bool vulnerable;
        string memory revertMessage;

        try mockSet.insert(0, addr) {
            // The call did not revert -> vulnerability exists
            vulnerable = true;
            revertMessage = "No revert";
        } catch Error(string memory reason) {
            // The call reverted with a reason string -> safe
            vulnerable = false;
            revertMessage = reason;
        } catch (bytes memory) {
            // The call reverted without a reason string -> safe
            vulnerable = false;
            revertMessage = "Unknown revert (no reason string)";
        }

        console.log("--- AFTER-Trigger Call ---");
        uint256 afterLength = mockSet.length();
        console.log("Set length after insert attempt:");
        console.log(afterLength);
        console.log("Revert message:");
        console.log(revertMessage);
        
        // Final verdict based on revert detection
        if (vulnerable) {
            // Show state change evidence if insertion succeeded
            if (afterLength == 1) {
                console.log("State changed: insertion unexpectedly succeeded");
            }
            console.log("Vulnerability Exists: Insert at index0 did not revert");
        } else {
            console.log("Vulnerability not Exist: Insert at index0 reverted as expected");
        }
    }
}