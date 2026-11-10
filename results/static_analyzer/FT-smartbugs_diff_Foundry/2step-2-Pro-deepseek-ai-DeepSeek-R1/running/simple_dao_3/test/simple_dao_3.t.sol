// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract MaliciousAttacker {
    SimpleDAO public dao;
    bool public failFallback;

    constructor(SimpleDAO _dao) {
        dao = _dao;
    }

    // Allow setting failure mode for fallback
    function setFailFallback(bool _fail) external {
        failFallback = _fail;
    }

    function donateToDAO() public payable {
        dao.donate{value: msg.value}(address(this));
    }

    function withdrawFromDAO(uint amount) public {
        dao.withdraw(amount);
    }

    fallback() external payable {
        if (failFallback) {
            revert("Forced failure");
        }
    }

    receive() external payable {
        if (failFallback) {
            revert("Forced failure");
        }
    }
}

contract SimpleDAO_Test is Test {
    SimpleDAO public dao;
    MaliciousAttacker public attacker;
    uint256 constant DONATION_AMOUNT = 1 ether;

    function setUp() public {
        // Deploy contracts
        dao = new SimpleDAO();
        attacker = new MaliciousAttacker(dao);
        
        // Configure attacker to fail fallback/receive
        attacker.setFailFallback(true);
        
        // Fund attacker and donate to DAO
        vm.deal(address(attacker), DONATION_AMOUNT);
        attacker.donateToDAO{value: DONATION_AMOUNT}();
    }

    function testWithdrawFailureStateUpdate() public {
        console.log("--- BEFORE-Trigger State Snapshot ---");
        // Capture initial states
        uint256 initialCredit = dao.queryCredit(address(attacker));
        uint256 initialDAOBalance = dao.getContractBalance();
        uint256 initialAttackerBalance = address(attacker).balance;
        uint256 initialTotalWithdrawals = dao.totalWithdrawals();
        
        // Log initial state
        console.log("Initial Credit:", initialCredit);
        console.log("Initial DAO Balance:", initialDAOBalance);
        console.log("Initial Attacker Balance:", initialAttackerBalance);
        console.log("Initial Total Withdrawals:", initialTotalWithdrawals);

        console.log("\n--- Trigger Action (Attempt Withdrawal) ---");
        // Attempt withdrawal (will fail due to forced receive failure)
        vm.prank(address(attacker));
        attacker.withdrawFromDAO(DONATION_AMOUNT);
        console.log("Withdrawal attempt triggered (expected to fail)");

        console.log("\n--- AFTER-Trigger State Snapshot ---");
        // Capture final states
        uint256 finalCredit = dao.queryCredit(address(attacker));
        uint256 finalDAOBalance = dao.getContractBalance();
        uint256 finalAttackerBalance = address(attacker).balance;
        uint256 finalTotalWithdrawals = dao.totalWithdrawals();
        
        // Log final state
        console.log("Final Credit:", finalCredit);
        console.log("Final DAO Balance:", finalDAOBalance);
        console.log("Final Attacker Balance:", finalAttackerBalance);
        console.log("Final Total Withdrawals:", finalTotalWithdrawals);

        console.log("\n--- State Comparison Verdict ---");
        // Check state changes
        bool creditChanged = finalCredit != initialCredit;
        bool daoBalanceChanged = finalDAOBalance != initialDAOBalance;
        bool attackerBalanceChanged = finalAttackerBalance != initialAttackerBalance;
        bool withdrawalsChanged = finalTotalWithdrawals != initialTotalWithdrawals;
        
        // Vulnerability exists if credit changed but no other state updated
        bool vulnerabilityExists = finalCredit == (initialCredit - DONATION_AMOUNT) &&
                                    !daoBalanceChanged &&
                                    !attackerBalanceChanged &&
                                    !withdrawalsChanged;
        
        // Log vulnerability status
        if (vulnerabilityExists) {
            console.log("Vulnerability Exploited: credit reduced by %d while other states unchanged", DONATION_AMOUNT);
            console.log("Vulnerability Exists: State update occurs even when transfer fails");
        } else {
            console.log("Vulnerability not Exist: State changes not matching vulnerability pattern");
            console.log("Vulnerability not Exist: Contract properly handles failed transfers");
        }

        // Final verdict in required format
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State updates occur for failed transfers");
        } else {
            console.log("Vulnerability not Exist: Contract handles failed transfers correctly");
        }
    }
}