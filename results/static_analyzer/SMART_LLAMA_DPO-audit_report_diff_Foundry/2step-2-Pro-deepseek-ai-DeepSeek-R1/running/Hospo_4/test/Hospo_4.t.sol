// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Hospo.sol";

// Mock implementation for Uniswap V2 Router
contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
    
    function WETH() external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

// Mock implementation for Uniswap V2 Factory
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x3333333333333333333333333333333333333333);
    }
}

contract HospoPrivilegeTest is Test {
    Hospo public hosposToken;
    address public owner = address(0xABCD);
    uint256 expectedValue;
    address newPair = address(0x123456);
    address mainPair;
    
    // Events for verifying state changes
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    function setUp() public {
        // Mock external contracts
        address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        address factoryAddress = 0x1111111111111111111111111111111111111111;
        
        // Set mock implementations
        vm.etch(routerAddress, type(MockRouter).runtimeCode);
        vm.etch(factoryAddress, type(MockFactory).runtimeCode);

        vm.startPrank(owner);
        hosposToken = new Hospo();
        mainPair = hosposToken.uniswapV2Pair();
        vm.stopPrank();
    }

    // Test setMaxWallet arbitrary change by owner
    function test_OwnerCanSetMaxWalletArbitrarily() public {
        console.log("--- BEFORE-Trigger setMaxWallet ---");
        uint256 preMaxWallet = hosposToken.maxWalletAmount();
        console.log("Pre-MaxWallet: %s", preMaxWallet);

        uint256 newValue = 2200000002;
        expectedValue = newValue * (10 ** 18);
        
        console.log("--- Trigger setMaxWallet(%s) ---", newValue);
        vm.prank(owner);
        hosposToken.setMaxWallet(newValue);
        
        console.log("--- AFTER-Trigger setMaxWallet ---");
        uint256 postMaxWallet = hosposToken.maxWalletAmount();
        console.log("Post-MaxWallet: %s", postMaxWallet);
        
        if (postMaxWallet == expectedValue && preMaxWallet != postMaxWallet) {
            console.log("Vulnerability Exists: Owner can setMaxWallet arbitrarily");
        } else {
            console.log("Vulnerability not Exist: State change not verified");
        }
        assertEq(postMaxWallet, expectedValue);
    }

    // Test setMaxTx arbitrary change by owner
    function test_OwnerCanSetMaxTxArbitrarily() public {
        console.log("--- BEFORE-Trigger setMaxTx ---");
        uint256 preMaxTx = hosposToken.maxTxAmount();
        console.log("Pre-MaxTx: %s", preMaxTx);

        uint256 newValue = 2200000002;
        expectedValue = newValue * (10 ** 18);
        
        console.log("--- Trigger setMaxTx(%s) ---", newValue);
        vm.prank(owner);
        hosposToken.setMaxTx(newValue);
        
        console.log("--- AFTER-Trigger setMaxTx ---");
        uint256 postMaxTx = hosposToken.maxTxAmount();
        console.log("Post-MaxTx: %s", postMaxTx);
        
        if (postMaxTx == expectedValue && preMaxTx != postMaxTx) {
            console.log("Vulnerability Exists: Owner can setMaxTx arbitrarily");
        } else {
            console.log("Vulnerability not Exist: State change not verified");
        }
        assertEq(postMaxTx, expectedValue);
    }

    // Test setSwapAtAmount arbitrary change by owner
    function test_OwnerCanSetSwapAtAmountArbitrarily() public {
        console.log("--- BEFORE-Trigger setSwapAtAmount ---");
        uint256 preSwapAmount = hosposToken.swapTokensAtAmount();
        console.log("Pre-SwapAtAmount: %s", preSwapAmount);

        uint256 newValue = 2000001;
        expectedValue = newValue * (10 ** 18);
        
        console.log("--- Trigger setSwapAtAmount(%s) ---", newValue);
        vm.prank(owner);
        hosposToken.setSwapAtAmount(newValue);
        
        console.log("--- AFTER-Trigger setSwapAtAmount ---");
        uint256 postSwapAmount = hosposToken.swapTokensAtAmount();
        console.log("Post-SwapAtAmount: %s", postSwapAmount);
        
        if (postSwapAmount == expectedValue && preSwapAmount != postSwapAmount) {
            console.log("Vulnerability Exists: Owner can setSwapAtAmount arbitrarily");
        } else {
            console.log("Vulnerability not Exist: State change not verified");
        }
        assertEq(postSwapAmount, expectedValue);
    }

    // Test setAutomatedMarketMakerPair arbitrary change by owner
    function test_OwnerCanSetAMMPairsArbitrarily() public {
        console.log("--- BEFORE-Trigger setAutomatedMarketMakerPair ---");
        bool preSetPair = hosposToken.automatedMarketMakerPairs(newPair);
        console.log("Pre-PairSet: %s", preSetPair);

        console.log("--- Trigger setAutomatedMarketMakerPair(%s, true) ---", newPair);
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit SetAutomatedMarketMakerPair(newPair, true);
        hosposToken.setAutomatedMarketMakerPair(newPair, true);
        
        console.log("--- AFTER-Trigger setPair(true) ---");
        bool postSetPairTrue = hosposToken.automatedMarketMakerPairs(newPair);
        console.log("Post-PairSet(true): %s", postSetPairTrue);
        
        console.log("--- Trigger setAutomatedMarketMakerPair(%s, false) ---", newPair);
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit SetAutomatedMarketMakerPair(newPair, false);
        hosposToken.setAutomatedMarketMakerPair(newPair, false);
        
        console.log("--- AFTER-Trigger setPair(false) ---");
        bool postSetPairFalse = hosposToken.automatedMarketMakerPairs(newPair);
        console.log("Post-PairSet(false): %s", postSetPairFalse);
        
        if (postSetPairTrue && !postSetPairFalse) {
            console.log("Vulnerability Exists: Owner can set AM pairs arbitrarily");
        } else {
            console.log("Vulnerability not Exist: State change verification failed");
        }
    }

    // Verify owner can't modify the main Uniswap pair
    function test_CannotModifyUniswapPair() public {
        console.log("--- BEFORE-Trigger modifyUniswapPair ---");
        bool preSetPairMain = hosposToken.automatedMarketMakerPairs(mainPair);
        console.log("Pre-MainPairSet: %s", preSetPairMain);

        console.log("--- Trigger removeUniswapPair(%s, false) ---", mainPair);
        vm.prank(owner);
        vm.expectRevert(
            bytes("Hospo: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs")
        );
        hosposToken.setAutomatedMarketMakerPair(mainPair, false);
        
        console.log("--- AFTER-Trigger modifyUniswapPair ---");
        bool postSetPairMain = hosposToken.automatedMarketMakerPairs(mainPair);
        console.log("Post-MainPairSet: %s", postSetPairMain);
        
        if (preSetPairMain == postSetPairMain && preSetPairMain) {
            console.log("Vulnerability not Exist: Owner cannot modify main pair");
        } else {
            console.log("Vulnerability Exists: Main pair state modified");
        }
    }
}