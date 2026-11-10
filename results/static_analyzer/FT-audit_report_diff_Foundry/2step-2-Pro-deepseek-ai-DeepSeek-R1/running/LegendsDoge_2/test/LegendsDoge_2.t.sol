// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LegendsDoge.sol";

contract LegendsDogeTest is Test {
    LegendsDoge token;
    address owner = address(0x1);
    address feeAddress = address(0x2);
    address user = address(0x3);
    address recipient = address(0x4);
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000; // 1 billion tokens

    function setUp() public {
        // Deploy token with initial parameters
        vm.prank(owner);
        token = new LegendsDoge(
            "LegendsDoge",
            "LDOGE",
            9,                      // decimals
            INITIAL_SUPPLY,         // supply
            1,                      // _txFee = 1%
            1,                      // _burnFee = 1%
            1,                      // _charityFee = 1%
            feeAddress, 
            owner
        );

        // Give user some tokens (1% of total supply)
        uint256 userAmount = INITIAL_SUPPLY * (10 ** token.decimals()) / 100;
        vm.prank(owner);
        token.transfer(user, userAmount);
    }

    function testFeeManipulationCausesTransferRevert() public {
        uint256 decimals = token.decimals();
        uint256 transferAmount = 1 * (10 ** decimals);

        // User has initial tokens
        uint256 userBalance = token.balanceOf(user);
        assertGt(userBalance, 0, "User should have tokens");

        // First transfer: With initial fees (1% each)
        console.log("--- BEFORE-Trigger: Transfer with initial fees ---");
        uint256 senderBalanceBefore1 = token.balanceOf(user);
        uint256 recipientBalanceBefore1 = token.balanceOf(recipient);

        vm.prank(user);
        token.transfer(recipient, transferAmount); // Should succeed

        uint256 senderBalanceAfter1 = token.balanceOf(user);
        uint256 recipientBalanceAfter1 = token.balanceOf(recipient);

        console.log("First transfer:");
        console.log("  Sender balance:   %s -> %s", senderBalanceBefore1, senderBalanceAfter1);
        console.log("  Recipient balance: %s -> %s", recipientBalanceBefore1, recipientBalanceAfter1);

        // Trigger: Set dangerous fees (50% each)
        console.log("--- Trigger: Setting high fees (txFee=50%, burnFee=50%, charityFee=50%) ---");
        vm.prank(owner);
        token.updateFee(50, 50, 50);

        // Second transfer: Attempt same transfer after fee change
        console.log("--- AFTER-Trigger: Transfer attempt with high fees ---");
        uint256 senderBalanceBefore2 = token.balanceOf(user);
        uint256 recipientBalanceBefore2 = token.balanceOf(recipient);

        vm.prank(user);
        vm.expectRevert();  // Underflow in fee calculation
        token.transfer(recipient, transferAmount);

        uint256 senderBalanceAfter2 = token.balanceOf(user);
        uint256 recipientBalanceAfter2 = token.balanceOf(recipient);

        console.log("Second transfer:");
        console.log("  Sender balance:   %s -> %s", senderBalanceBefore2, senderBalanceAfter2);
        console.log("  Recipient balance: %s -> %s", recipientBalanceBefore2, recipientBalanceAfter2);

        // Validate vulnerability
        bool unchanged = (senderBalanceBefore2 == senderBalanceAfter2) && 
                         (recipientBalanceBefore2 == recipientBalanceAfter2);

        if (unchanged) {
            console.log("Vulnerability Exists: Fee manipulation causes transfer to revert and balances unchanged");
        } else {
            console.log("Vulnerability not Exist: Balances changed after transfer revert");
        }
    }
}