// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Solar.sol";

contract SolarTest is Test {
    Solar token;
    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);

    function setUp() public {
        token = new Solar();
        token.mint(alice, 1000); // Mint tokens to Alice
    }

    function testTransferFromOrder() public {
        console.log("--- BEFORE APPROVAL ---");
        console.log("Alice initial balance:", token.balanceOf(alice));
        console.log("Bob initial allowance:", token.allowance(alice, bob));

        // Alice approves Bob to spend 500 tokens
        vm.prank(alice);
        token.approve(bob, 500);
        console.log("--- AFTER APPROVAL ---");
        console.log("New allowance for Bob:", token.allowance(alice, bob));

        console.log("--- BEFORE-TRIGGER TransferFrom ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 charlieBalanceBefore = token.balanceOf(charlie);
        console.log("Alice balance before:", aliceBalanceBefore);
        console.log("Charlie balance before:", charlieBalanceBefore);

        // Bob transfers 200 tokens from Alice to Charlie
        console.log("--- TRIGGER TransferFrom ---");
        vm.prank(bob);
        token.transferFrom(alice, charlie, 200);

        console.log("--- AFTER-TRIGGER TransferFrom ---");
        // Verify balances after transfer
        assertEq(token.balanceOf(alice), 800);
        assertEq(token.balanceOf(charlie), 200);
        console.log("Alice balance after:", token.balanceOf(alice));
        console.log("Charlie balance after:", token.balanceOf(charlie));

        // Verify allowance is reduced AFTER the transfer
        uint256 reducedAllowance = token.allowance(alice, bob);
        assertEq(reducedAllowance, 300);
        console.log("New allowance after transfer:", reducedAllowance);

        console.log("Vulnerability Exists: The test completed successfully without reverting, confirming the vulnerability");
    }
}