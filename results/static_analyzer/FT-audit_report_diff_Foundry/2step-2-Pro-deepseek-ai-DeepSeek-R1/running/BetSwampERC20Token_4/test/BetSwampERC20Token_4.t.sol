// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetSwampERC20Token.sol";

contract TestEnumerableSet {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private addressSet;

    function add(address value) external {
        addressSet.add(value);
    }

    function getValues() external view returns (address[] memory) {
        return addressSet.getValues();
    }
}

contract EnumerableSetIssueTest is Test {
    TestEnumerableSet testContract;

    function setUp() public {
        testContract = new TestEnumerableSet();
    }

    function testGetValuesRevertsWhenSetLengthIsOne() public {
        console.log("--- BEFORE-Trigger State ---");
        bool beforeReverted = false;
        try testContract.getValues() {
            console.log("BEFORE getValues executed successfully (empty set)");
        } catch {
            beforeReverted = true;
            console.log("BEFORE getValues reverted (unexpected - empty set)");
        }

        console.log("--- Trigger Action: Add one element ---");
        testContract.add(address(0x123));
        
        console.log("--- AFTER-Trigger State ---");
        bool afterReverted = false;
        try testContract.getValues() {
            console.log("AFTER getValues executed successfully (set length=1)");
        } catch {
            afterReverted = true;
            console.log("AFTER getValues reverted (expected for length=1)");
        }
        
        // Vulnerability verdict
        if (afterReverted) {
            console.log("Vulnerability Exists: getValues reverts when set length=1");
        } else {
            console.log("Vulnerability not Exist: getValues works correctly");
        }
    }
}