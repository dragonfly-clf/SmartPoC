// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SantaCoin.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint) external returns (bool) { return true; }
    function withdraw(uint) external {}
}

contract MockPair {
    // Minimal implementation for testing
}

contract MockFactory {
    MockPair public pair;
    
    constructor() {
        pair = new MockPair();
    }
    
    function createPair(address, address) external view returns (address pairAddr) {
        return address(pair);
    }
}

contract MockRouter {
    address private immutable _factory;
    address private immutable _weth;
    
    constructor(address __factory, address __weth) {
        _factory = __factory;
        _weth = __weth;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract SantaCoinTest is Test {
    SantaCoin public token;
    address constant owner = 0xc70327c3C21F6B3922f3a843B9fF77677140bfee;
    
    function setUp() public {
        vm.chainId(97); // Set to BSC testnet chain ID
        
        // Set up mock Uniswap ecosystem
        address mockWETH = address(new MockWETH());
        address mockFactory = address(new MockFactory());
        MockRouter mockRouter = new MockRouter(mockFactory, mockWETH);
        
        // Make MockRouter available at expected testnet address (0xD99D1c...)
        vm.etch(0xD99D1c33F9fC3444f8101754aBC46c52416550D1, address(mockRouter).code);
        
        token = new SantaCoin();
    }

    function test_setSwapTokensAtAmount_UnsafeValue() public {
        uint256 arbitraryValue = type(uint256).max;
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 beforeSwapAmount = token.swapTokensAtAmount();
        console.log("Initial swapTokensAtAmount: %s", beforeSwapAmount);

        console.log("--- Trigger Operation: setSwapTokensAtAmount ---");
        vm.prank(owner);
        token.setSwapTokensAtAmount(arbitraryValue);

        console.log("--- AFTER-Trigger State ---");
        uint256 afterSwapAmount = token.swapTokensAtAmount();
        console.log("After swapTokensAtAmount: %s", afterSwapAmount);
        
        bool stateChanged = (afterSwapAmount != beforeSwapAmount);
        bool exploitationSuccess = (afterSwapAmount == arbitraryValue);
        
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Swap threshold successfully set to unsafe value");
        } else if (!stateChanged) {
            console.log("Vulnerability not Exists: Swap threshold unchanged");
        } else {
            console.log("Vulnerability not Exists: Swap threshold changed but not to expected unsafe value");
        }

        assertEq(
            token.swapTokensAtAmount(), 
            arbitraryValue,
            "Should set swap threshold to unsafe value"
        );
    }

    function test_setMaxWalletAmount_MinimumAllowed() public {
        uint256 minAllowedValue = token.totalSupply() / 100 / (10 ** token.decimals());
        uint256 expectedAmount = minAllowedValue * (10 ** token.decimals());
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 beforeMaxWallet = token.maxWalletAmount();
        console.log("Max wallet amount before: %s", beforeMaxWallet);

        console.log("--- Trigger Operation: setMaxWalletAmount ---");
        vm.prank(owner);
        token.setMaxWalletAmount(minAllowedValue);

        console.log("--- AFTER-Trigger State ---");
        uint256 afterMaxWallet = token.maxWalletAmount();
        console.log("Max wallet amount after: %s", afterMaxWallet);
        
        bool stateChanged = (afterMaxWallet != beforeMaxWallet);
        bool exploitationSuccess = (afterMaxWallet == expectedAmount);
        
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Max wallet amount successfully set to dangerous minimum");
        } else if (!stateChanged) {
            console.log("Vulnerability not Exists: Max wallet amount unchanged");
        } else {
            console.log("Vulnerability not Exists: Max wallet amount changed but not to minimum allowed");
        }

        assertEq(
            token.maxWalletAmount(),
            expectedAmount,
            "Max wallet should be set to minimum allowed 1%"
        );
    }

    function test_flipMaxWalletLimitRepeatedly() public {
        vm.startPrank(owner);
        
        console.log("--- BEFORE-Trigger State ---");
        bool initialState = token.maxWalletLimitEnabled();
        console.log("Initial max wallet limit enabled: %s", initialState);
        
        console.log("--- Trigger Operation: Repeated toggling ---");
        token.setEnableMaxWalletLimit(!initialState);
        token.setEnableMaxWalletLimit(initialState);
        token.setEnableMaxWalletLimit(!initialState);
        
        console.log("--- AFTER-Trigger State ---");
        bool finalState = token.maxWalletLimitEnabled();
        console.log("Final max wallet limit enabled: %s", finalState);
        
        bool stateChanged = (finalState != initialState);
        bool exploitationSuccess = (finalState == !initialState);
        
        if (exploitationSuccess) {
            console.log("Vulnerability Exists: Successfully manipulated wallet limit through repeated toggling");
        } else if (!stateChanged) {
            console.log("Vulnerability not Exists: Wallet limit state unchanged");
        } else {
            console.log("Vulnerability not Exists: Wallet limit changed but not to expected state");
        }

        assertTrue(
            token.maxWalletLimitEnabled() == !initialState,
            "Should toggle wallet limit multiple times"
        );
    }
}