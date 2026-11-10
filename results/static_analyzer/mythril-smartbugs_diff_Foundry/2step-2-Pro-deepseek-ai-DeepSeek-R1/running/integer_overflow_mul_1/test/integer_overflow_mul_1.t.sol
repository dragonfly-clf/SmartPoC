// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, Vm} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/integer_overflow_mul.sol";

contract IntegerOverflowMulTest is Test {
    IntegerOverflowMul public overflowContract;
    event OperationPerformed(address indexed user, uint256 input, uint256 count);

    function setUp() public {
        overflowContract = new IntegerOverflowMul();
    }

    function test_integerOverflowInRun() public {
        address contractAddr = address(overflowContract);
        uint256 storageSlot = 0; // Correct slot for count variable
        uint256 maxUint = type(uint256).max;
        // Set starting count to (maxUint/2 + 1) = 2^255 to cause overflow
        uint256 startValue = maxUint / 2 + 1;
        vm.store(contractAddr, bytes32(storageSlot), bytes32(startValue));
        
        console2.log("--- BEFORE-Trigger Count ---");
        uint256 countBefore = overflowContract.count();
        console2.log("Count before run:", countBefore);

        console2.log("--- Trigger run(2) ---");
        vm.expectEmit(true, true, true, true);
        emit OperationPerformed(address(this), 2, 0); // Count becomes 0 after overflow
        overflowContract.run(2);

        console2.log("--- AFTER-Trigger Count ---");
        uint256 countAfter = overflowContract.count();
        console2.log("Count after run:", countAfter);

        console2.log("--- Comparison ---");
        // Check if overflow occurred (count wraps to 0)
        bool overflowOccurred = (countAfter == 0);
        console2.log("Overflow observed:", overflowOccurred);
        
        // Final vulnerability verdict
        if (overflowOccurred) {
            console2.log("Vulnerability Exists: Integer multiplication overflow occurred");
        } else {
            console2.log("Vulnerability not Exist: No integer overflow detected");
        }
    }
}