// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract IntegerOverflowSingleTransactionTest is Test {
    IntegerOverflowSingleTransaction public overflowContract;
    uint256 public constant MAX_UINT256 = type(uint256).max;

    function setUp() public {
        overflowContract = new IntegerOverflowSingleTransaction();
    }

    function test_overflowaddtostate_overflow() public {
        // Get initial state
        uint256 currentCount = overflowContract.count();

        // Calculate the required input to update state to MAX_UINT256
        uint256 inputRequired = MAX_UINT256 - currentCount;
        overflowContract.overflowaddtostate(inputRequired);
        assertEq(overflowContract.count(), MAX_UINT256, "Count not set to max");

        console.log("--- BEFORE-Trigger Overflow ---");
        uint256 beforeOverflow = overflowContract.count();
        console.log("Count before overflow: %s", beforeOverflow);

        console.log("--- Trigger Overflow by adding 1 ---");
        overflowContract.overflowaddtostate(1);

        console.log("--- AFTER-Trigger Overflow ---");
        uint256 afterOverflow = overflowContract.count();
        console.log("Count after overflow: %s", afterOverflow);

        // Differential verification
        bool vulnerabilityExists = (beforeOverflow == MAX_UINT256 && afterOverflow == 0);
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Integer overflow caused state to wrap to 0");
        } else {
            console.log("Vulnerability not Exist: State did not wrap to zero after overflow");
        }
        
        // Final verdict (exactly one final line)
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: The count overflowed from MAX_UINT256 to 0 via single transaction");
        } else {
            console.log("Vulnerability not Exist: Overflow operation did not cause state wrap to zero");
        }
    }
}