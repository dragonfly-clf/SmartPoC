// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    MoBaToken token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new MoBaToken("TestToken", "TST");
        vm.stopPrank();
    }

    // Test the cross function and transfer functionality
    function test_tokenOperations() public {
        // Mint tokens to Alice using cross function
        uint256 mintAmount = 1000 ether;
        vm.prank(owner);
        token.cross(alice, mintAmount);
        
        // Verify Alice's balance
        assertEq(token.balanceOf(alice), mintAmount, "Alice should have minted tokens");
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 allowanceBefore = token.allowance(alice, bob);
        console.log("allowance(Alice -> Bob) before transfer:", allowanceBefore);

        console.log("--- Trigger Transfer ---");
        // Test token transfer from Alice to Bob
        uint256 transferAmount = 100 ether;
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 allowanceAfter = token.allowance(alice, bob);
        console.log("allowance(Alice -> Bob) after transfer:", allowanceAfter);

        // Vulnerability verdict
        if (allowanceAfter != allowanceBefore) {
            console.log("Vulnerability Exists: Transfer operation incorrectly modified authorization allowance");
        } else {
            console.log("Vulnerability not Exist: Allowance remained unchanged during transfer");
        }
        
        // Verify balances after transfer
        assertEq(token.balanceOf(alice), mintAmount - transferAmount, "Alice balance incorrect after transfer");
        assertEq(token.balanceOf(bob), transferAmount, "Bob balance incorrect after transfer");
    }

    // Test managerBurn functionality (unchanged)
    function test_managerBurn() public {
        // Mint tokens to Alice
        uint256 mintAmount = 1000 ether;
        vm.prank(owner);
        token.cross(alice, mintAmount);

        // Burn tokens from Alice's account
        uint256 burnAmount = 100 ether;
        vm.prank(owner);
        token.managerBurn(alice, burnAmount);
        
        // Verify Alice's new balance
        assertEq(token.balanceOf(alice), mintAmount - burnAmount, "Burn unsuccessful");
        
        // Verify total supply reduction
        assertEq(token.totalSupply(), mintAmount - burnAmount, "Total supply incorrect after burn");
    }
}