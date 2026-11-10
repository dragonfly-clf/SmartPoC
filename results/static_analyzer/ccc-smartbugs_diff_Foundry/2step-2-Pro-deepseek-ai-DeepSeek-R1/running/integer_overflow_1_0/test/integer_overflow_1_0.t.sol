// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_1.sol";

contract OverflowTest is Test {
    Overflow public overflow;
    address user1 = address(0x100);

    function setUp() public {
        overflow = new Overflow();
        // Fund the contract for withdrawal tests
        vm.deal(address(overflow), 10 ether);
    }

    function testAddOverflow() public {
        uint256 max = type(uint256).max;
        console.log("--- BEFORE ADD OPERATION ---");
        console.log("Setting sellerBalance to max-1 (via direct storage)");

        vm.store(address(overflow), bytes32(0), bytes32(max - 1));
        bytes32 sellerBalBefore = vm.load(address(overflow), bytes32(0));
        uint256 userBalBefore = overflow.userBalances(user1);

        console.log("Pre-state: sellerBalance =", uint256(sellerBalBefore));
        console.log("Pre-state: user1 balance =", userBalBefore);

        console.log("--- TRIGGER: add(2) ---");
        vm.prank(user1);
        overflow.add(2);

        console.log("--- AFTER ADD OPERATION ---");
        bytes32 sellerBalStorage = vm.load(address(overflow), bytes32(0));
        uint256 sellerBalance = uint256(sellerBalStorage);
        uint256 userBalance = overflow.userBalances(user1);

        console.log("Post-state: sellerBalance =", sellerBalance);
        console.log("Post-state: user1 balance =", userBalance);

        assertEq(sellerBalance, 0, "sellerBalance should overflow to 0");
        assertEq(userBalance, 2, "User balance should be 2");

        if (sellerBalance == 0) {
            console.log("Vulnerability Exists: Integer overflow successfully exploited (sellerBalance wrapped to 0)");
        } else {
            console.log("Vulnerability not Exist: Overflow did not occur as expected");
        }
    }

    function testWithdrawUnderflow() public {
        console.log("--- INITIAL SETUP ---");
        vm.prank(user1);
        overflow.add(2);
        console.log("Setup: Added 2 tokens to user1 (balance:", overflow.userBalances(user1), ")");

        console.log("--- BEFORE WITHDRAWAL OPERATION ---");
        vm.store(address(overflow), bytes32(0), bytes32(uint256(1)));
        bytes32 sellerBalBefore = vm.load(address(overflow), bytes32(0));
        uint256 userBalBefore = overflow.userBalances(user1);
        console.log("Overwrote sellerBalance to 1");
        console.log("Pre-state: sellerBalance =", uint256(sellerBalBefore));
        console.log("Pre-state: user1 balance =", userBalBefore);

        console.log("--- TRIGGER: withdraw(2) ---");
        vm.prank(user1);
        overflow.withdraw(2);

        console.log("--- AFTER WITHDRAWAL OPERATION ---");
        bytes32 newSellerBal = vm.load(address(overflow), bytes32(0));
        uint256 sellerBalance = uint256(newSellerBal);
        uint256 userBalance = overflow.userBalances(user1);
        console.log("Post-state: sellerBalance =", sellerBalance);
        console.log("Post-state: user1 balance =", userBalance);

        assertEq(
            sellerBalance, 
            type(uint256).max, 
            "sellerBalance should underflow to max value"
        );
        assertEq(userBalance, 0, "User balance should be 0");

        if (sellerBalance == type(uint256).max) {
            console.log("Vulnerability Exists: Integer underflow successfully exploited (sellerBalance wrapped to max)");
        } else {
            console.log("Vulnerability not Exist: Underflow did not occur as expected");
        }
    }
}