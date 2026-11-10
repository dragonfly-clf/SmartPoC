// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/overflow_single_tx.sol";

contract TestIntegerOverflowMultiToState is Test {
    IntegerOverflowSingleTransaction public counterContract;

    function setUp() public {
        counterContract = new IntegerOverflowSingleTransaction();
        counterContract.resetCounter(); // Reset counter to a known initial state
    }

    function testOverflowMultostate() public {
        // Set the counter to 2^255
        uint256 largeInput = 2 ** 255;
        
        // First call: set counter to 2^255
        vm.expectEmit(true, true, true, true, address(counterContract));
        emit IntegerOverflowSingleTransaction.OperationPerformed(
            address(this), "multiply", largeInput, largeInput);
        counterContract.overflowmultostate(largeInput);

        uint256 triggerInput = 2;
        uint256 expectedOverflowValue = 0;
        
        // Pre-trigger: get counter state before overflow
        console.log("--- BEFORE-Trigger Operation ---");
        uint256 countBefore = counterContract.count();
        console.log("counter value before overflow:", countBefore);
        require(countBefore == (2**255), "State not initialized properly");

        // Verify the emitted event
        vm.expectEmit(true, true, true, true, address(counterContract));
        emit IntegerOverflowSingleTransaction.OperationPerformed(
            address(this), "multiply", triggerInput, expectedOverflowValue);
            
        console.log("--- Trigger Overflow Operation ---");
        counterContract.overflowmultostate(triggerInput);

        // Post-trigger: get counter state after overflow
        console.log("--- AFTER-Trigger Operation ---");
        uint256 countAfter = counterContract.count();
        console.log("counter value after overflow:", countAfter);

        // Compare state changes and determine vulnerability status
        if (countBefore > 0 && countAfter == 0) {
            console.log("VULNERABILITY CONFIRMED: Integer overflow occurred (2^255 * 2 overflowed to 0)");
            console.log("Vulnerability Exists: Arithmetic overflow vulnerability demonstrated by counter state change from %s to 0", countBefore);
        } else {
            console.log("SAFE: No integer overflow detected");
            console.log("Vulnerability not Exist: Counter state remained at %s", countAfter);
        }
    }
}