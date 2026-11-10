// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_benign_1.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowBenign1 public overflowContract;
    address testUser = address(0x123);

    function setUp() public {
        overflowContract = new IntegerOverflowBenign1();
    }

    function testIntegerUnderflow() public {
        // Initially count is 0 (default uint value)
        // Attempt to subtract a value larger than current count
        uint256 largeInput = 1;
        
        // Since the subtraction is in an unchecked block, it won't revert
        vm.prank(testUser);
        overflowContract.run(largeInput);
        
        // Verify user operations were still incremented despite underflow
        assertEq(overflowContract.getUserOperationCount(testUser), 1);
        
        // Vulnerability verdict: No state corruption from underflow
        console.log("Vulnerability not Exist: Unchecked underflow in local variable 'res' does not corrupt state");
    }

    function testNoUnderflowWithValidInput() public {
        // First increment count by performing some operations
        vm.prank(testUser);
        overflowContract.run(0); // This will increment operations without subtraction
        
        // Now we have count = 1, we can safely subtract 1
        vm.prank(testUser);
        overflowContract.run(1);
        
        // Verify operations were properly recorded
        assertEq(overflowContract.getUserOperationCount(testUser), 2);
    }
}