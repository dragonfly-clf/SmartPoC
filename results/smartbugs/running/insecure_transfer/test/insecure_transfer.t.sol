// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/insecure_transfer.sol";

contract IntegerOverflowTest is Test {
    IntegerOverflowAdd token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new IntegerOverflowAdd();
        vm.stopPrank();
    }

    function testTransferUnderflow() public {
        // Mint some tokens to user1
        vm.prank(owner);
        token.mint(user1, 100);

        // Verify initial balance
        assertEq(token.getBalance(user1), 100);

        // Attempt to transfer more than balance - should revert due to require check
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 101); // Should revert before underflow can occur

        // Verify balances remain unchanged
        assertEq(token.getBalance(user1), 100);
        assertEq(token.getBalance(user2), 0);
    }

    function testTransferOverflow() public {
        // Mint tokens to user1 and user2
        vm.prank(owner);
        token.mint(user1, type(uint256).max);
        vm.prank(owner);
        token.mint(user2, 1);

        // Verify initial balances
        assertEq(token.getBalance(user1), type(uint256).max);
        assertEq(token.getBalance(user2), 1);

        // Attempt transfer that would cause overflow
        vm.prank(user2);
        vm.expectRevert(); // Should revert due to require check
        token.transfer(user1, 2); // Trying to transfer more than balance

        // Verify balances remain unchanged
        assertEq(token.getBalance(user1), type(uint256).max);
        assertEq(token.getBalance(user2), 1);
    }

    function testValidTransfer() public {
        // Mint tokens to user1
        vm.prank(owner);
        token.mint(user1, 100);

        // Verify initial balance
        assertEq(token.getBalance(user1), 100);

        // Perform valid transfer
        vm.prank(user1);
        token.transfer(user2, 50);

        // Verify balances updated correctly
        assertEq(token.getBalance(user1), 50);
        assertEq(token.getBalance(user2), 50);
    }

    // New test to demonstrate receiver overflow vulnerability
    function testReceiverOverflowVulnerability() public {
        // Set up receiver to be near overflow threshold
        vm.prank(owner);
        token.mint(user2, type(uint256).max - 50);
        vm.prank(owner);
        token.mint(user1, 51); // Exactly enough for 1 transaction

        // Record initial state
        console.log("--- BEFORE-Trigger State ---");
        uint256 senderBefore = token.getBalance(user1);
        uint256 receiverBefore = token.getBalance(user2);
        console.log("Sender balance before transfer:", senderBefore);
        console.log("Receiver balance before transfer:", receiverBefore);
        
        // Trigger overflow vulnerability
        console.log("--- Trigger OverflowTransfer ---");
        vm.prank(user1);
        token.transfer(user2, 51);

        // Record final state
        console.log("--- AFTER-Trigger State ---");
        uint256 senderAfter = token.getBalance(user1);
        uint256 receiverAfter = token.getBalance(user2);
        console.log("Sender balance after transfer:", senderAfter);
        console.log("Receiver balance after transfer:", receiverAfter);

        // Check sender balance reduced by transfer amount
        assertEq(senderAfter, senderBefore - 51, "Sender balance incorrect");

        // Vulnerability detection logic - avoid arithmetic overflow by checking for 0
        if (receiverAfter == 0) {
            console.log("Differential Verdict: Receiver balance overflow occurred");
            console.log("Vulnerability Exists: Receiver balance += causes overflow");
        } else {
            console.log("Differential Verdict: Receiver balance update normal");
            console.log("Vulnerability not Exist: Proper overflow checks exist");
        }
    }
}