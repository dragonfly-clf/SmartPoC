// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/Test.sol";
import "../src/unchecked_return_value.sol";

contract FailingContract {
    fallback() external payable {
        revert("Call always fails");
    }
}

contract ReturnValueTest is Test {
    ReturnValue public returnValue;
    FailingContract public failingContract;

    function setUp() public {
        returnValue = new ReturnValue();
        failingContract = new FailingContract();
    }

    function test_UncheckedCallFailureUpdatesState() public {
        // Check initial state values
        (uint256 initialCalls, uint256 initialSuccess) = returnValue.getCallStats(address(failingContract));
        uint256 initialTotalCalls = returnValue.totalCalls();
        uint256 initialTotalSuccessCalls = returnValue.totalSuccessfulCalls();
        assertEq(initialCalls, 0, "Unexpected initial calls");
        assertEq(initialSuccess, 0, "Unexpected initial successes");
        assertEq(initialTotalCalls, 0, "Unexpected initial total calls");
        assertEq(initialTotalSuccessCalls, 0, "Unexpected initial successful calls");
        
        console.log("--- BEFORE-Trigger Call Stats ---");
        console.log("Contract calls: %s, successes: %s", initialCalls, initialSuccess);
        console.log("Total calls: %s, total successes: %s", initialTotalCalls, initialTotalSuccessCalls);

        console.log("--- Trigger Unchecked Call ---");
        returnValue.callnotchecked(address(failingContract));
        
        // Verify state after unchecked call
        (uint256 afterCalls, uint256 afterSuccess) = returnValue.getCallStats(address(failingContract));
        uint256 afterTotalCalls = returnValue.totalCalls();
        uint256 afterTotalSuccessCalls = returnValue.totalSuccessfulCalls();
        
        console.log("--- AFTER-Trigger Call Stats ---");
        console.log("Contract calls: %s, successes: %s", afterCalls, afterSuccess);
        console.log("Total calls: %s, total successes: %s", afterTotalCalls, afterTotalSuccessCalls);
        
        // Differential: Compare BEFORE and AFTER state
        bool vulExists = (afterCalls != initialCalls) || 
                         (afterTotalCalls != initialTotalCalls) ||
                         (afterTotalSuccessCalls != initialTotalSuccessCalls);
        
        if (vulExists) {
            console.log("Vulnerability Exists: State variables updated despite failed external call");
        } else {
            console.log("Vulnerability not Exist: State variables remain unchanged after failed call");
        }
        
        // Final verdict detection
        assertTrue(vulExists, "Vulnerability not detected: state should update on failing call");
    }

    function test_CheckedCallFailureReverts() public {
        // Check initial state values
        (uint256 initialCalls, uint256 initialSuccess) = returnValue.getCallStats(address(failingContract));
        assertEq(initialCalls, 0);
        assertEq(initialSuccess, 0);
        
        // Expect revert when performing checked call to failing contract
        vm.expectRevert();
        returnValue.callchecked(address(failingContract));
        
        // Verify state was NOT updated after revert
        (uint256 afterCalls, uint256 afterSuccess) = returnValue.getCallStats(address(failingContract));
        assertEq(afterCalls, 0);
        assertEq(afterSuccess, 0);
    }
}