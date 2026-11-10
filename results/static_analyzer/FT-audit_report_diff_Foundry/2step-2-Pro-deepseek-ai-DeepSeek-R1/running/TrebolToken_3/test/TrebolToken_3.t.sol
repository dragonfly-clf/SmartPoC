// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TrebolToken.sol";

contract TrebolTokenTest is Test {
    TrebolToken internal token;
    address internal sender;
    address internal recipient;
    address internal owner;
    address internal spender;

    function setUp() public {
        token = new TrebolToken();
        sender = address(100);
        recipient = address(101);
        owner = address(102);
        spender = address(103);
    }

    // Test overflow protection during transfer()
    function testTransferRecipientOverflow() public {
        // Set sender balance to 100
        setStorageBalance(sender, 100);
        
        // Set recipient balance near overflow (MAX_UINT256 - 50)
        setStorageBalance(recipient, type(uint256).max - 50);

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 senderBalanceBefore = token.balanceOf(sender);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("Sender balance before:", senderBalanceBefore);
        console.log("Recipient balance before:", recipientBalanceBefore);

        console.log("--- Trigger Transfer (expected to revert due to overflow) ---");
        // Attempt transfer; expect overflow revert
        vm.prank(sender);
        vm.expectRevert(stdError.arithmeticError);
        token.transfer(recipient, 100);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 senderBalanceAfter = token.balanceOf(sender);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Sender balance after:", senderBalanceAfter);
        console.log("Recipient balance after:", recipientBalanceAfter);

        // Verify balances remain unchanged
        assertEq(senderBalanceBefore, senderBalanceAfter, "Sender balance changed unexpectedly");
        assertEq(recipientBalanceBefore, recipientBalanceAfter, "Recipient balance changed unexpectedly");

        // Final vulnerability verdict
        if (senderBalanceBefore != senderBalanceAfter || recipientBalanceBefore != recipientBalanceAfter) {
            console.log("Vulnerability Exists: State changed despite overflow reversal");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged as expected after revert");
        }
    }

    // Test overflow protection during transferFrom()
    function testTransferFromRecipientOverflow() public {
        // Set parameters for transferFrom
        setStorageBalance(owner, 100);
        setStorageBalance(recipient, type(uint256).max - 50);
        
        // Approve spender for owner's tokens
        vm.prank(owner);
        token.approve(spender, 100);

        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("Owner balance before:", ownerBalanceBefore);
        console.log("Recipient balance before:", recipientBalanceBefore);

        console.log("--- Trigger TransferFrom (expected to revert due to overflow) ---");
        // Attempt transferFrom; expect overflow revert
        vm.prank(spender);
        vm.expectRevert(stdError.arithmeticError);
        token.transferFrom(owner, recipient, 100);

        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Owner balance after:", ownerBalanceAfter);
        console.log("Recipient balance after:", recipientBalanceAfter);

        // Verify balances remain unchanged
        assertEq(ownerBalanceBefore, ownerBalanceAfter, "Owner balance changed unexpectedly");
        assertEq(recipientBalanceBefore, recipientBalanceAfter, "Recipient balance changed unexpectedly");

        // Final vulnerability verdict
        if (ownerBalanceBefore != ownerBalanceAfter || recipientBalanceBefore != recipientBalanceAfter) {
            console.log("Vulnerability Exists: State changed despite overflow reversal");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged as expected after revert");
        }
    }

    // Helper to modify storage slots directly
    function setStorageBalance(address account, uint256 amount) internal {
        // Slot computed as: keccak256(abi.encode(account, uint256(0)))
        bytes32 balanceSlot = keccak256(abi.encode(account, uint256(0)));
        vm.store(address(token), balanceSlot, bytes32(amount));
    }
}