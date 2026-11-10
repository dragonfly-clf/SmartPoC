// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/overflow_simple_add.sol";

contract OverflowAddTest is Test {
    Overflow_Add public overflowAdd;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        overflowAdd = new Overflow_Add();
    }

    function testArithmeticOverflow() public {
        // Store initial total deposits
        uint initialTotalDeposits = overflowAdd.totalDeposits();

        // Initial deposit by user1
        vm.prank(user1);
        overflowAdd.add(100);

        // Verify total deposits increased
        assertEq(overflowAdd.totalDeposits(), initialTotalDeposits + 100, "Total deposits should increase");

        // Attempt to cause overflow by adding maximum possible value - (1) Trigger operation
        console.log("--- Trigger Attempted Overflow Operation ---");
        vm.prank(user1);
        vm.expectRevert();
        overflowAdd.add(type(uint256).max);

        // Verify total deposits didn't change - (2) Post-trigger validation
        assertEq(overflowAdd.totalDeposits(), initialTotalDeposits + 100, "Total deposits should remain unchanged");
        
        // Vulnerability verdict - (3) Final analysis
        console.log("Vulnerability not Exist: Overflow attempt reverted as expected in Solidity 0.8.x, no state change occurred");
    }

    function testUncheckedArithmetic() public {
        // Store initial total deposits
        uint initialTotalDeposits = overflowAdd.totalDeposits();

        // Initial deposit by user2
        vm.prank(user2);
        overflowAdd.add(100);

        // Verify total deposits increased
        assertEq(overflowAdd.totalDeposits(), initialTotalDeposits + 100, "Total deposits should increase");

        // Attempt arithmetic operation that would overflow if unchecked - (1) Trigger operation
        console.log("--- Trigger Attempted Overflow Operation ---");
        vm.prank(user2);
        vm.expectRevert();
        overflowAdd.add(type(uint256).max - (initialTotalDeposits + 100) + 1);

        // Verify total deposits didn't change - (2) Post-trigger validation
        assertEq(overflowAdd.totalDeposits(), initialTotalDeposits + 100, "Total deposits should remain unchanged");
        
        // Vulnerability verdict - (3) Final analysis
        console.log("Vulnerability not Exist: Overflow attempt reverted as expected in Solidity 0.8.x, no state change occurred");
    }
}