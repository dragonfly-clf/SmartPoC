// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract MockERC20 {
    mapping(address => uint256) public balances;
    
    constructor() {
        balances[msg.sender] = 100 ether;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract WizardPayDrainTest is Test {
    WizardPay public wizardPay;
    MockERC20 public mockToken;
    address public owner = address(0x1);
    address public attacker = address(0x2);
    
    function setUp() public {
        vm.startPrank(owner);
        wizardPay = new WizardPay();
        mockToken = new MockERC20();
        // Transfer initial tokens from owner to contract
        mockToken.transfer(address(wizardPay), 50 ether);
        vm.stopPrank();
        
        // Send initial ETH to contract
        vm.deal(address(wizardPay), 10 ether);
    }

    // Test ETH draining via TransferETH function
    function test_ETHDrain() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(wizardPay).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract ETH balance: %d wei", contractBalanceBefore);
        console.log("Attacker ETH balance: %d wei", attackerBalanceBefore);
        
        console.log("--- Trigger: TransferETH ---");
        vm.prank(owner);
        wizardPay.TransferETH(payable(attacker), contractBalanceBefore);
        
        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(wizardPay).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract ETH balance: %d wei", contractBalanceAfter);
        console.log("Attacker ETH balance: %d wei", attackerBalanceAfter);
        
        // Verify differential
        bool contractBalanceDrained = contractBalanceAfter == 0;
        bool attackerReceivedETH = attackerBalanceAfter == attackerBalanceBefore + contractBalanceBefore;
        
        console.log("--- Verification ---");
        console.log("Contract ETH drained: %s", contractBalanceDrained ? "YES" : "NO");
        console.log("Attacker received ETH: %s", attackerReceivedETH ? "YES" : "NO");
        
        // Final verdict
        if (contractBalanceDrained && attackerReceivedETH) {
            console.log("Vulnerability Exists: Owner can drain ETH");
        } else {
            console.log("Vulnerability not Exist: ETH drain failed");
        }
    }

    // Test ERC20 token draining via transferAnyERC20Tokens function
    function test_ERC20Drain() public {
        uint256 contractTokenBalanceBefore = mockToken.balanceOf(address(wizardPay));
        
        console.log("--- BEFORE-Trigger ---");
        uint256 attackerTokenBalanceBefore = mockToken.balanceOf(attacker);
        console.log("Contract ERC20 balance: %d tokens", contractTokenBalanceBefore);
        console.log("Attacker ERC20 balance: %d tokens", attackerTokenBalanceBefore);
        
        console.log("--- Trigger: transferAnyERC20Tokens ---");
        vm.prank(owner);
        wizardPay.transferAnyERC20Tokens(
            address(mockToken), 
            attacker, 
            contractTokenBalanceBefore
        );
        
        console.log("--- AFTER-Trigger ---");
        uint256 attackerTokenBalanceAfter = mockToken.balanceOf(attacker);
        uint256 contractBalanceAfter = mockToken.balanceOf(address(wizardPay));
        console.log("Contract ERC20 balance: %d tokens", contractBalanceAfter);
        console.log("Attacker ERC20 balance: %d tokens", attackerTokenBalanceAfter);
        
        // Verify differential
        bool tokensDrained = contractBalanceAfter == 0;
        bool tokensReceived = attackerTokenBalanceAfter == attackerTokenBalanceBefore + contractTokenBalanceBefore;
        
        console.log("--- Verification ---");
        console.log("Contract ERC20 drained: %s", tokensDrained ? "YES" : "NO");
        console.log("Attacker received tokens: %s", tokensReceived ? "YES" : "NO");
        
        // Final verdict
        if (tokensDrained && tokensReceived) {
            console.log("Vulnerability Exists: Owner can drain ERC20 tokens");
        } else {
            console.log("Vulnerability not Exist: ERC20 drain failed");
        }
    }
}