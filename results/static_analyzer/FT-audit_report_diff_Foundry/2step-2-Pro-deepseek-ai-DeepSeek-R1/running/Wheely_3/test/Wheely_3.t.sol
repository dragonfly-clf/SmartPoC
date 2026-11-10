// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyEventTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    Wheely token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address feeReceiver = makeAddr("feeReceiver");
    
    uint8 constant DECIMALS = 18;
    uint256 constant TOTAL_SUPPLY = 10**2 * (10**DECIMALS); // 100 tokens
    uint256 constant TRANSFER_AMOUNT = 10 * (10**DECIMALS); // 10 tokens
    uint256 constant FEE_AMOUNT = TRANSFER_AMOUNT / 10000; // 0.01% fee

    function setUp() public {
        vm.startPrank(owner);
        token = new Wheely(
            "WheelyToken", 
            "WHEEL", 
            DECIMALS, 
            TOTAL_SUPPLY / (10**DECIMALS), // Constructor expects total supply units
            feeReceiver
        );
        vm.stopPrank();

        // Transfer enough tokens to Alice (accounting for initial transfer fee)
        uint256 transferToAlice = TRANSFER_AMOUNT * 2;
        vm.prank(owner);
        token.transfer(alice, transferToAlice);
    }

    function testEventMismatch() public {
        uint256 aliceInitialBal = token.balanceOf(alice);
        uint256 bobInitialBal = token.balanceOf(bob);
        uint256 feeInitialBal = token.balanceOf(feeReceiver);

        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("Alice balance:", aliceInitialBal);
        console.log("Bob balance:", bobInitialBal);
        console.log("FeeReceiver balance:", feeInitialBal);

        console.log("--- Trigger Transfer ---");
        // Expect event with full amount (includes fee)
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, TRANSFER_AMOUNT);

        // Execute transfer
        vm.prank(alice);
        token.transfer(bob, TRANSFER_AMOUNT);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 aliceFinalBal = token.balanceOf(alice);
        uint256 bobFinalBal = token.balanceOf(bob);
        uint256 feeFinalBal = token.balanceOf(feeReceiver);
        console.log("Alice balance:", aliceFinalBal);
        console.log("Bob balance:", bobFinalBal);
        console.log("FeeReceiver balance:", feeFinalBal);

        // Calculate balance changes
        uint256 aliceChange = aliceInitialBal - aliceFinalBal;
        uint256 bobChange = bobFinalBal - bobInitialBal;
        uint256 feeReceiverChange = feeFinalBal - feeInitialBal;

        console.log("Alice balance change (expected %d): %d", TRANSFER_AMOUNT, aliceChange);
        console.log("Bob balance change (exptected %d): %d", TRANSFER_AMOUNT - FEE_AMOUNT, bobChange);
        console.log("FeeReceiver balance change (expected %d): %d", FEE_AMOUNT, feeReceiverChange);

        // Final vulnerability verdict
        bool stateCorrect = aliceChange == TRANSFER_AMOUNT &&
                           bobChange == TRANSFER_AMOUNT - FEE_AMOUNT &&
                           feeReceiverChange == FEE_AMOUNT;

        if (stateCorrect) {
            console.log("Vulnerability Exists: Transfer event logs entire amount without fee deduction");
        } else {
            console.log("Vulnerability not Exist: State change did not match expected fee pattern");
        }

        // Original balance assertions remain for fail-safe
        assertEq(
            aliceFinalBal,
            aliceInitialBal - TRANSFER_AMOUNT,
            "Alice should be debited full amount"
        );
        assertEq(
            bobFinalBal,
            bobInitialBal + TRANSFER_AMOUNT - FEE_AMOUNT,
            "Bob should receive amount minus fee"
        );
        assertEq(
            feeFinalBal,
            feeInitialBal + FEE_AMOUNT,
            "Fee address should get exact fee"
        );
    }
}