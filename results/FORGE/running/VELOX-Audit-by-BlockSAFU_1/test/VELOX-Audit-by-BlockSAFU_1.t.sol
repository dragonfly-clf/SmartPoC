// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract CoinToken_HighFee_Test is Test {
    CoinToken token;
    address owner;
    address devWallet;
    address service;
    address userA = address(0x10);
    address userB = address(0x11);
    uint256 decimals;
    uint256 testAmount;
    
    function tokenAmount(uint256 amount) internal view returns (uint256) {
        return amount * 10**decimals;
    }

    function setUp() public {
        owner = address(this);
        devWallet = address(0xABCD);
        service = address(0xABCDE);
        
        decimals = 18;
        uint256 supply = 1000000 * 10**decimals;
        testAmount = tokenAmount(1000);
        
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        MockUniswapV2Router router = new MockUniswapV2Router(address(factory));
        
        token = new CoinToken{value: 0}(
            "TestToken",
            "TST",
            decimals,
            supply,
            1,  // _txFee (1%)
            1,  // _lpFee (1%)
            1,  // _DexFee (1%)
            address(router),
            devWallet,
            owner,
            service
        );
        
        // Allow large transfers by setting max transfer to 100% of supply
        token.setMaxTxPercent(100);

        // Fund test accounts
        token.transfer(userA, testAmount);
        token.transfer(userB, testAmount / 10);
    }

    function test_OwnerCanSetFeesTo100Percent() public {
        console.log("=== SET FEES TO 100% ===");
        token.setTaxFeePercent(100);
        token.setDevFeePercent(100);
        token.setLiquidityFeePercent(100);
        token.setMaxTxPercent(100);
        console.log("Fees set to 100%");

        console.log("\n=== TESTING TRANSFER WITH 100% FEES ===");
        uint256 userABalanceBefore = token.balanceOf(userA);
        uint256 userBBalanceBefore = token.balanceOf(userB);
        console.log("UserA balance before transfer:", userABalanceBefore);
        console.log("UserB balance before transfer:", userBBalanceBefore);

        uint256 transferAmount = 1; // Transfer 1 wei (smallest unit)
        vm.prank(userA);
        token.transfer(userB, transferAmount);

        uint256 userABalanceAfter = token.balanceOf(userA);
        uint256 userBBalanceAfter = token.balanceOf(userB);
        console.log("UserA balance after transfer: ", userABalanceAfter);
        console.log("UserB balance after transfer: ", userBBalanceAfter);
        
        uint256 feeDetected = (userABalanceBefore - userABalanceAfter) - (userBBalanceAfter - userBBalanceBefore);
        console.log("Total fee deducted:", feeDetected);
        
        console.log("\n=== VULNERABILITY VERIFICATION ===");
        if (feeDetected > 0.9 * transferAmount) { // Account for potential precision issues
            console.log("Vulnerability Exists: Fee deduction reached 100%%");
            console.log("Vulnerability Exists: Owner can set 100% fees");
        } else {
            console.log("Vulnerability not Exist: Fee deduction was minimal");
        }
    }
}