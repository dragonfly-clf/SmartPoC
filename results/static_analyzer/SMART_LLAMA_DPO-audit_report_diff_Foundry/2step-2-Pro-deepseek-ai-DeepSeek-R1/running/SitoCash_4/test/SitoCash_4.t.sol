// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SitoCash.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public weth;

    constructor(address factoryAddr) {
        factory = factoryAddr;
        weth = address(0xC0FFEE);
    }

    function WETH() external pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract SitoCashPrivilegeTest is Test {
    SitoCash token;
    MockUniswapV2Router router;
    MockUniswapV2Factory factory;
    
    address owner = address(0xdeadbeef);
    address alice = address(0x1);
    address newWallet = address(0x999);
    address uniswapAddr = 0x509c97d4A7b98C91f1264304f228e3639416F118;

    function setUp() public {
        // Deploy mock Uniswap components
        factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router(address(factory));
        
        // Setup mock router at fixed address
        vm.etch(uniswapAddr, address(router).code);
        // Initialize storage: slot0 = factory address
        vm.store(
            uniswapAddr,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(factory))))
        );
        
        // Deploy token contract
        vm.prank(owner);
        token = new SitoCash(owner);
    }

    function testPrivilegedFunctions() public {
        vm.startPrank(owner);
        bool vulnerabilityExists = false;

        // Test 1: Change marketing wallet
        {
            console2.log("======= Test: setMarketingWallet =======");
            address marketingWalletBefore = token._marketingWallet();
            console2.log("Before: marketing wallet =", marketingWalletBefore);
            token.setMarketingWallet(newWallet);
            address marketingWalletAfter = token._marketingWallet();
            console2.log("After: marketing wallet =", marketingWalletAfter);
            if (marketingWalletAfter == newWallet) {
                console2.log("State changed: YES");
                vulnerabilityExists = true;
            } else {
                console2.log("State changed: NO");
            }
            console2.log("");
        }
        
        // Test 2: Set min token balance & max wallet size
        {
            console2.log("======= Test: setMinimumTokenBalance(0) & setMaxWalletTokens(1) =======");
            token.setMinimumTokenBalance(0);
            token.setMaxWalletTokens(1);
            console2.log("Function called - state verification skipped (no available getters)");
            console2.log("");
        }
        
        // Test 3: Set marketing allocation
        {
            console2.log("======= Test: setPercentageOfLiquidityForMarketing(1000) =======");
            uint256 marketingPercBefore = token._percentageOfLiquidityForMarketing();
            console2.log("Before: marketing percentage =", marketingPercBefore);
            token.setPercentageOfLiquidityForMarketing(1000);
            uint256 marketingPercAfter = token._percentageOfLiquidityForMarketing();
            console2.log("After: marketing percentage =", marketingPercAfter);
            if (marketingPercAfter == 1000) {
                console2.log("State changed: YES");
                vulnerabilityExists = true;
            } else {
                console2.log("State changed: NO");
            }
            console2.log("");
        }
        
        // Test 4: Disable swap
        {
            console2.log("======= Test: setSwapAndLiquifyEnabled(false) =======");
            bool swapEnabledBefore = token._swapAndLiquifyEnabled();
            console2.log("Before: swap enabled? =", swapEnabledBefore);
            token.setSwapAndLiquifyEnabled(false);
            bool swapEnabledAfter = token._swapAndLiquifyEnabled();
            console2.log("After: swap enabled? =", swapEnabledAfter);
            if (!swapEnabledAfter) {
                console2.log("State changed: YES");
                vulnerabilityExists = true;
            } else {
                console2.log("State changed: NO");
            }
            console2.log("");
        }
        
        // Test 5: Change Uniswap router
        {
            console2.log("======= Test: setUniswapRouter(0x1234) =======");
            address routerBefore = address(token._uniswapV2Router());
            console2.log("Before: Uniswap router =", routerBefore);
            token.setUniswapRouter(address(0x1234));
            address routerAfter = address(token._uniswapV2Router());
            console2.log("After: Uniswap router =", routerAfter);
            if (routerAfter == address(0x1234)) {
                console2.log("State changed: YES");
                vulnerabilityExists = true;
            } else {
                console2.log("State changed: NO");
            }
            console2.log("");
        }
        
        // Test 6: Change Uniswap pair
        {
            console2.log("======= Test: setUniswapPair(0x5678) =======");
            address pairBefore = address(token._uniswapV2Pair());
            console2.log("Before: Uniswap pair =", pairBefore);
            token.setUniswapPair(address(0x5678));
            address pairAfter = address(token._uniswapV2Pair());
            console2.log("After: Uniswap pair =", pairAfter);
            if (pairAfter == address(0x5678)) {
                console2.log("State changed: YES");
                vulnerabilityExists = true;
            } else {
                console2.log("State changed: NO");
            }
            console2.log("");
        }
        
        // Test 7: Modify fee exclusions
        {
            console2.log("======= Test: setExcludedFromFee(alice, true) =======");
            bool excludedBefore = token.isExcludedFromFee(alice);
            console2.log("Before: alice excluded? =", excludedBefore);
            token.setExcludedFromFee(alice, true);
            bool excludedAfter = token.isExcludedFromFee(alice);
            console2.log("After: alice excluded? =", excludedAfter);
            if (excludedAfter) {
                console2.log("State changed: YES");
                vulnerabilityExists = true;
            } else {
                console2.log("State changed: NO");
            }
            console2.log("");
        }
        
        // Test 8: Validate safeguards for liquidity fee
        {
            console2.log("======= Test: setLiquidityFeePercent(5) =======");
            uint256 liqFeeBefore = token._liquidityFee();
            console2.log("Before: liquidity fee =", liqFeeBefore);
            token.setLiquidityFeePercent(5);
            uint256 liqFeeAfter = token._liquidityFee();
            console2.log("After: liquidity fee =", liqFeeAfter);
            if (liqFeeAfter == 5) {
                console2.log("State changed: YES (within limits)");
            } else {
                console2.log("State changed: NO (unexpected)");
                vulnerabilityExists = true;
            }
            console2.log("");
        }
        
        // Test 9: Validate safeguards for tax fee
        {
            console2.log("======= Test: setTaxFeePercent(3) =======");
            uint256 taxFeeBefore = token._taxFee();
            console2.log("Before: tax fee =", taxFeeBefore);
            token.setTaxFeePercent(3);
            uint256 taxFeeAfter = token._taxFee();
            console2.log("After: tax fee =", taxFeeAfter);
            if (taxFeeAfter == 3) {
                console2.log("State changed: YES (within limits)");
            } else {
                console2.log("State changed: NO (unexpected)");
                vulnerabilityExists = true;
            }
            console2.log("");
        }
        
        // Test 10: Validate fee limiter for liquidity fee
        {
            console2.log("======= Test: setLiquidityFeePercent(10) =======");
            uint256 badLiqBefore = token._liquidityFee();
            console2.log("Before: liquidity fee =", badLiqBefore);
            try vm.expectRevert("Liquidity Fee cannot exceed 16%") {
                token.setLiquidityFeePercent(10);
            } catch (bytes memory) {
                console2.log("Revert caught as expected");
            }
            uint256 badLiqAfter = token._liquidityFee();
            console2.log("After: liquidity fee =", badLiqAfter);
            if (badLiqAfter == badLiqBefore) {
                console2.log("State unchanged: YES (safeguard worked)");
            } else {
                console2.log("State changed: YES (safeguard bypassed)");
                vulnerabilityExists = true;
            }
            console2.log("");
        }
        
        // Test 11: Validate fee limiter for tax fee
        {
            console2.log("======= Test: setTaxFeePercent(5) =======");
            uint256 badTaxBefore = token._taxFee();
            console2.log("Before: tax fee =", badTaxBefore);
            try vm.expectRevert("Holder Reflection cannot exceed 4%") {
                token.setTaxFeePercent(5);
            } catch (bytes memory) {
                console2.log("Revert caught as expected");
            }
            uint256 badTaxAfter = token._taxFee();
            console2.log("After: tax fee =", badTaxAfter);
            if (badTaxAfter == badTaxBefore) {
                console2.log("State unchanged: YES (safeguard worked)");
            } else {
                console2.log("State changed: YES (safeguard bypassed)");
                vulnerabilityExists = true;
            }
            console2.log("");
        }
        
        vm.stopPrank();
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Owner can arbitrarily modify critical contract parameters without safeguards");
        } else {
            console2.log("Vulnerability not Exist: All privileged functions have proper access controls and safeguards");
        }
    }
}