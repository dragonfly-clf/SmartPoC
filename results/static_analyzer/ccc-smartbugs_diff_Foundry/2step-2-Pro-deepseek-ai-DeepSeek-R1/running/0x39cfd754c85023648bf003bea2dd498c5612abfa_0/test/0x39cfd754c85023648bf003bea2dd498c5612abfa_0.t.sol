// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    bool public transferShouldFail;

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }

    function setTransferResult(bool shouldFail) public {
        transferShouldFail = shouldFail;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        if (transferShouldFail) {
            return false;
        } else {
            balanceOf[msg.sender] -= amount;
            balanceOf[to] += amount;
            return true;
        }
    }
}

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MockToken public mockToken;
    address owner = address(0x123);
    address holder = address(0x456);

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();
        mockToken = new MockToken();
        
        // Initialize tokenBank with sufficient balance
        mockToken.mint(address(tokenBank), 1000);
    }

    function testWithdrawToken_doesNotRevertOnFailure() public {
        // Capture initial states
        uint256 holderBalanceBefore = mockToken.balanceOf(holder);
        uint256 tokenBankBalanceBefore = mockToken.balanceOf(address(tokenBank));
        
        console.log("--- BEFORE-Trigger WithdrawToken ---");
        console.log("Holder token balance:", holderBalanceBefore);
        console.log("TokenBank contract token balance:", tokenBankBalanceBefore);
        require(tokenBankBalanceBefore == 1000, "Initial TokenBank balance invalid");
        
        console.log("--- Trigger Operation: Force transfer failure ---");
        // Make external token transfer fail
        mockToken.setTransferResult(true);
        
        console.log("--- Trigger Operation: Execute WithdrawToken ---");
        // WithdrawToken should complete without reverting despite transfer failure
        vm.startPrank(owner);
        tokenBank.WithdrawToken(address(mockToken), 100, holder);
        vm.stopPrank();
        
        // Check post-trigger states
        uint256 holderBalanceAfter = mockToken.balanceOf(holder);
        uint256 tokenBankBalanceAfter = mockToken.balanceOf(address(tokenBank));
        
        console.log("--- AFTER-Trigger WithdrawToken ---");
        console.log("Holder token balance:", holderBalanceAfter);
        console.log("TokenBank contract token balance:", tokenBankBalanceAfter);
        
        // Compare state changes
        bool balancesUnchanged = 
            (holderBalanceBefore == holderBalanceAfter) &&
            (tokenBankBalanceBefore == tokenBankBalanceAfter);
        console.log("Comparison: Balances unchanged?", balancesUnchanged);

        // Vulnerability verdict
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: WithdrawToken executed without reverting while token transfer failed, leaving balances unchanged");
        } else {
            console.log("Vulnerability not Exist: Token balances changed during WithdrawToken execution indicating successful transfer");
        }
    }
}