// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract HomeyJarTest is Test {
    HomeyJar public jar;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address user = makeAddr("user");
    
    uint256 constant INITIAL_CONTRACT_BALANCE = 1 ether;
    uint256 constant ATTACK_AMOUNT = 1.1 ether;

    function setUp() public {
        // Deploy contract by owner
        vm.startPrank(owner);
        jar = new HomeyJar();
        vm.stopPrank();
        
        // Fund contract via user transfer (using receive function)
        vm.deal(user, INITIAL_CONTRACT_BALANCE);
        vm.prank(user);
        (bool success, ) = address(jar).call{value: INITIAL_CONTRACT_BALANCE}("");
        require(success, "Failed to fund contract");
    }

    function testAttackerCanDrainContract() public {
        console.log("--- BEFORE-Trigger State ---");
        // Fund attacker and capture state AFTER funding
        vm.deal(attacker, ATTACK_AMOUNT);
        
        // Record initial balances using differential-specified queries
        uint256 initialContractBalance = jar.getJarBalance();
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialAttackerBalance = attacker.balance;
        
        console.log("Contract ETH balance:", initialContractBalance);
        console.log("Owner ETH balance:", initialOwnerBalance);
        console.log("Attacker ETH balance:", initialAttackerBalance);
        
        console.log("--- Trigger DrainContract ---");
        // Attack call
        vm.prank(attacker);
        jar.GetHoneyFromJar{value: ATTACK_AMOUNT}();

        console.log("--- AFTER-Trigger State ---");
        // Record post-attack balances
        uint256 finalContractBalance = jar.getJarBalance();
        uint256 finalOwnerBalance = owner.balance;
        uint256 finalAttackerBalance = attacker.balance;
        
        console.log("Contract ETH balance:", finalContractBalance);
        console.log("Owner ETH balance:", finalOwnerBalance);
        console.log("Attacker ETH balance:", finalAttackerBalance);

        // Differential Comparison
        console.log("--- Differential Verification ---");
        uint256 contractBalanceDecrease = initialContractBalance - finalContractBalance;
        uint256 ownerBalanceIncrease = finalOwnerBalance - initialOwnerBalance;
        uint256 attackerSpent = initialAttackerBalance - finalAttackerBalance;
        
        console.log("Contract ETH decrease:", contractBalanceDecrease);
        console.log("Owner ETH increase:", ownerBalanceIncrease);
        console.log("Attacker spent ETH:", attackerSpent);

        // Vulnerability condition verification
        bool fundsDrained = contractBalanceDecrease == initialContractBalance && 
                            finalContractBalance == 0;
        bool ownerReceivedAll = ownerBalanceIncrease == initialContractBalance + ATTACK_AMOUNT;
        bool attackerSpentCorrect = attackerSpent == ATTACK_AMOUNT;
        
        if (fundsDrained && ownerReceivedAll && attackerSpentCorrect) {
            console.log("Vulnerability Exists: ETH fully drained from contract to owner");
        } else {
            console.log("Vulnerability not Exist: ETH not drained according to expected pattern");
        }

        // Final assertions using properly timed balances
        assertEq(finalContractBalance, 0, "Contract balance not drained");
        assertEq(
            finalOwnerBalance,
            initialOwnerBalance + initialContractBalance + ATTACK_AMOUNT,
            "Owner did not receive full contract balance"
        );
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance - ATTACK_AMOUNT,
            "Attacker should have spent the attack amount"
        );
    }
}