// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract HomeyJarTest is Test {
    HomeyJar public jar;
    address public owner = address(0x123);
    address public attacker = address(0x456);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);
        vm.prank(owner);
        jar = new HomeyJar();
    }

    function testArbitraryWithdrawalVulnerability() public {
        // Fund the contract with 5 ether from owner
        vm.prank(owner);
        (bool success,) = address(jar).call{value: 5 ether}("");
        require(success, "Transfer failed");

        uint initialJarBalance = address(jar).balance;
        uint initialAttackerBalance = address(attacker).balance;
        uint initialOwnerBalance = address(owner).balance;
        
        assertEq(initialJarBalance, 5 ether, "Initial contract balance should be 5 ether");
        console.log("--- BEFORE-Trigger Contract State ---");
        console.log("Contract balance:", initialJarBalance);
        console.log("Owner balance:", initialOwnerBalance);
        console.log("Attacker balance:", initialAttackerBalance);

        console.log("--- Trigger: Attacker calls GetHoneyFromJar with 1.1 ether ---");
        // Attacker calls GetHoneyFromJar with >1 ether (1.1 ether)
        vm.prank(attacker);
        jar.GetHoneyFromJar{value: 1.1 ether}();

        uint newJarBalance = address(jar).balance;
        uint newAttackerBalance = address(attacker).balance;
        uint newOwnerBalance = address(owner).balance;
        
        console.log("--- AFTER-Trigger Contract State ---");
        console.log("Contract balance:", newJarBalance);
        console.log("Owner balance:", newOwnerBalance);
        console.log("Attacker balance:", newAttackerBalance);

        // Verify contract is drained
        assertEq(newJarBalance, 0, "Contract balance should be 0");
        
        // Verify owner received entire balance (5 + 1.1 = 6.1 ether)
        assertEq(
            newOwnerBalance,
            initialOwnerBalance + initialJarBalance + 1.1 ether,
            "Owner should receive contract balance plus attacker's deposit"
        );
        
        // Verify attacker lost their 1.1 ether deposit
        assertEq(
            newAttackerBalance,
            initialAttackerBalance - 1.1 ether,
            "Attacker should lose deposited ether"
        );

        // Differential verdict
        if (newJarBalance == 0 && 
            newOwnerBalance == initialOwnerBalance + initialJarBalance + 1.1 ether &&
            newAttackerBalance == initialAttackerBalance - 1.1 ether) {
            console.log("Vulnerability Exists: Non-owner arbitrary withdrawal drains contract funds");
        } else {
            console.log("Vulnerability not Exist: Balances unchanged after exploit attempt");
        }
    }
}