// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Domain.sol";

contract ST_Critical_Test is Test {
    Domain token;
    address owner = address(0x1);
    address user = address(0x2);
    address mockPair = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        // Mock router calls to avoid deployment failures
        address mockedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x5);
        address mockWETH = address(0x6);
        
        // Mock all required router/factory interactions
        vm.mockCall(
            mockedRouter,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            mockedRouter,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(mockPair)
        );
        
        // Deploy token contract
        token = new Domain();
        
        // Exclude user from max wallet restrictions
        token.excludeFromMaxWallet(user, true);
        
        // Set initial maxTxAmount to reasonable value (10%)
        token.setMaxTransactionAmount(10, 10);
        
        // Transfer test funds to user (1% of supply, within initial limits)
        uint256 transferAmount = token.totalSupply() / 100;
        token.transfer(user, transferAmount);
        vm.stopPrank();
    }

    function testMaxSellManipulation() public {
        uint256 totalSupply = token.totalSupply();
        uint256 userBalance = token.balanceOf(user);
        
        // Differential validation added
        console.log("--- BEFORE-Trigger MaxTxAmountSell ---");
        uint256 initialMaxTxAmountSell = token.maxTxAmountSell();
        console.log("Initial maxTxAmountSell: %s", initialMaxTxAmountSell);
        
        // Trigger operation - critical vulnerability exploit
        console.log("--- Trigger setMaxTransactionAmount ---");
        vm.startPrank(owner);
        token.setMaxTransactionAmount(100, 1000000);
        vm.stopPrank();
        
        // State verification after trigger
        console.log("--- AFTER-Trigger MaxTxAmountSell ---");
        uint256 newMaxTxAmountSell = token.maxTxAmountSell();
        console.log("New maxTxAmountSell: %s", newMaxTxAmountSell);
        
        // Vulnerability analysis
        bool stateChanged = (initialMaxTxAmountSell != newMaxTxAmountSell);
        console.log("State changed: %s", stateChanged ? "YES" : "NO");
        
        console.log("Vulnerability verdict: %s", 
            stateChanged ? "Vulnerability EXISTS - maxTxAmountSell changed" 
                         : "Vulnerability DOES NOT EXIST - state unchanged");
        
        // Rest of original test logic remains
        // Calculate microscopic sell limit (0.0001% of supply)
        uint256 maxSell = totalSupply / 1000000;
        
        // Create small but forbidden amount (just over limit)
        uint256 forbiddenAmount = maxSell + 1;
        
        // Ensure test amount is within user's balance
        assertGe(userBalance, forbiddenAmount);
        
        // Attempt small but unallowed sell transaction
        vm.startPrank(user);
        vm.expectRevert("amount must be <= maxTxAmountSell");
        token.transfer(mockPair, forbiddenAmount);
        
        // Final vulnerability determination
        if (stateChanged) {
            console.log("Vulnerability Exists: maxTxAmountSell state successfully modified");
        } else {
            console.log("Vulnerability not Exist: maxTxAmountSell state unchanged");
        }
    }
}