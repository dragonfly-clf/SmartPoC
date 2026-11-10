// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

// Mock token for testing transfers
contract MockToken {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // Revert if sender lacks sufficient balance
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MockToken public token;
    address owner = makeAddr("owner");
    address receiver = makeAddr("receiver");

    function setUp() public {
        // Deploy contracts
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        token = new MockToken();
        
        // Fund TokenBank with 100 tokens
        token.mint(address(tokenBank), 100);
        vm.stopPrank();
    }

    function test_WithdrawToken_IgnoresTransferUnderflow() public {
        vm.startPrank(owner);
        
        // Verify initial balances
        assertEq(token.balanceOf(address(tokenBank)), 100, "Initial balance incorrect");
        assertEq(token.balanceOf(receiver), 0, "Receiver balance not zero");

        console.log("--- BEFORE-Trigger WithdrawToken ---");
        uint256 tokenBankBalanceBefore = token.balanceOf(address(tokenBank));
        uint256 receiverBalanceBefore = token.balanceOf(receiver);
        console.log("TokenBank balance:", tokenBankBalanceBefore);
        console.log("Receiver balance:", receiverBalanceBefore);

        console.log("--- Trigger WithdrawToken ---");
        tokenBank.WithdrawToken(address(token), 101, receiver);
        console.log("Called WithdrawToken(amount=101)");

        console.log("--- AFTER-Trigger WithdrawToken ---");
        uint256 tokenBankBalanceAfter = token.balanceOf(address(tokenBank));
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        console.log("TokenBank balance:", tokenBankBalanceAfter);
        console.log("Receiver balance:", receiverBalanceAfter);

        // Verify balances unchanged (transfer failed silently)
        assertEq(tokenBankBalanceAfter, 100, "TokenBank balance changed");
        assertEq(receiverBalanceAfter, 0, "Receiver received tokens");

        // Final vulnerability verdict
        if (tokenBankBalanceAfter == tokenBankBalanceBefore && receiverBalanceAfter == receiverBalanceBefore) {
            console.log("Vulnerability Exists: Token balances unchanged after overwithdrawal, proving underflow was ignored");
        } else {
            console.log("Vulnerability not Exist: Token balances changed indicating proper overflow handling");
        }
        vm.stopPrank();
    }
}