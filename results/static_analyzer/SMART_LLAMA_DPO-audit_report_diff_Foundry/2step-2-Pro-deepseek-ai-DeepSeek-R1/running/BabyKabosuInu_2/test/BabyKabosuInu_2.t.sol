// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyKabosuInu.sol";

contract ReentrancyTest is Test {
    BabyKabosuInu token;
    address owner = makeAddr("owner");
    address trader = makeAddr("trader");
    address ecosystem = makeAddr("ecosystem");
    address marketing = makeAddr("marketing");
    address reward = makeAddr("reward");

    function setUp() public {
        // Fork BSC mainnet to access real PancakeSwap contracts
        string memory bscRpc = vm.envOr("BSC_RPC_URL", string("https://bsc-dataseed.binance.org/"));
        vm.createSelectFork(bscRpc);
        
        vm.startPrank(owner);
        token = new BabyKabosuInu();
        
        // Configure token settings
        token.setTrading(true);
        token.setSwapAndLiquifyEnabled(true);
        token.setMinTokensBeforeSwap(10**18); // 1 token
        token.setFeeActive(true);
        token.setBuyFee(1, 1, 1, 1, 1);
        token.setSellFee(1, 1, 1, 1, 1);
        
        // Initialize wallet addresses - corrected order: (marketing, ecosystem, reward)
        token.setWalletAddress(marketing, ecosystem, reward);
        
        // Distribute initial tokens (using exponential notation)
        token.transfer(trader, 100 * 10**18); // 100 tokens
        vm.stopPrank();
    }

    function testReentrancyDuringFeeCollection() public {
        address pair = token.uniswapV2Pair();
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractEthBalanceBefore = address(token).balance;
        uint256 contractTokenBalanceBefore = token.balanceOf(address(token));
        uint256 poolTokenBalanceBefore = token.balanceOf(pair);
        
        console.log("Contract ETH balance before:", contractEthBalanceBefore);
        console.log("Contract token balance before:", contractTokenBalanceBefore);
        console.log("Liquidity pool token balance before:", poolTokenBalanceBefore);

        vm.startPrank(trader);
        token.approve(address(this), type(uint256).max);
        
        console.log("--- Trigger Reentrancy Attack ---");
        token.transfer(pair, 10 * 10**18);
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        uint256 contractEthBalanceAfter = address(token).balance;
        uint256 contractTokenBalanceAfter = token.balanceOf(address(token));
        uint256 poolTokenBalanceAfter = token.balanceOf(pair);
        
        console.log("Contract ETH balance after:", contractEthBalanceAfter);
        console.log("Contract token balance after:", contractTokenBalanceAfter);
        console.log("Liquidity pool token balance after:", poolTokenBalanceAfter);

        // Verify anomalous state changes (pool tokens shouldn't change >10 tokens)
        bool abnormalStateChange = 
            (poolTokenBalanceAfter - poolTokenBalanceBefore > 10 * 10**18) ||
            (contractTokenBalanceBefore > contractTokenBalanceAfter) ||
            (contractEthBalanceBefore > contractEthBalanceAfter);
        
        if (abnormalStateChange) {
            console.log("Vulnerability Exists: Abnormal state changes detected indicating reentrancy exploit");
        } else {
            console.log("Vulnerability not Exist: No abnormal state changes detected");
        }
    }
    
    // Re-entrancy attempt simulation
    fallback() external payable {
        if (msg.sender == address(token)) {
            token.transfer(token.uniswapV2Pair(), 1 * 10**18);
        }
    }
}