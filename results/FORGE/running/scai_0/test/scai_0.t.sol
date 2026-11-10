// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCAI.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
}

contract MockPair {
    function sync() external {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address immutable factoryAddr;
    address immutable wethAddr;
    
    constructor(address _factory, address _weth) {
        factoryAddr = _factory;
        wethAddr = _weth;
    }
    
    function factory() external view returns (address) {
        return factoryAddr;
    }
    
    function WETH() external view returns (address) {
        return wethAddr;
    }
}

contract TradingEnableTest is Test {
    SCAI token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address constant MAINNET_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    function setUp() public {
        // Set chain ID to meet contract's router condition
        vm.chainId(1);
        
        // Deploy mock WETH and factory
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router at mainnet router address
        vm.etch(
            MAINNET_ROUTER, 
            address(new MockRouter(address(mockFactory), address(mockWETH))).code
        );
        
        // Deploy token
        vm.startPrank(owner);
        token = new SCAI();
        
        // Distribute tokens for testing
        uint256 aliceAmount = token.totalSupply() / 10; // 10% of supply
        token.transfer(alice, aliceAmount);
        vm.stopPrank();
    }

    function test_TradingEnablePermanence() public {
        console.log("--- BEFORE-Trigger enableTrading ---");
        bool tradingStatusBefore = token.isTradingEnabled();
        console.log("isTradingEnabled(): %s", tradingStatusBefore);
        assertFalse(tradingStatusBefore, "Trading should be disabled initially");
        
        // Verify trading disabled initially
        vm.prank(alice);
        vm.expectRevert("Trading is not enabled");
        token.transfer(bob, 100 ether);
        
        console.log("--- Trigger enableTrading ---");
        vm.prank(owner);
        token.enableTrading();
        
        console.log("--- AFTER-Trigger enableTrading ---");
        bool tradingStatusAfter = token.isTradingEnabled();
        console.log("isTradingEnabled(): %s", tradingStatusAfter);
        assertTrue(tradingStatusAfter, "Trading should be enabled after call");
        
        // Verify transfers succeed after enablement
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100 ether);
        
        // Verify trading remains enabled
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 200 ether, "Trading should remain enabled");
        
        console.log("--- FINAL Trading Status ---");
        bool tradingFinalStatus = token.isTradingEnabled();
        console.log("Final isTradingEnabled(): %s", tradingFinalStatus);
        
        // Vulnerability verdict based on permanent enablement
        if (tradingFinalStatus) {
            console.log("Vulnerability Exists: Trading is permanently enabled and cannot be disabled");
        } else {
            console.log("Vulnerability not Exist: Trading was disabled after enablement");
        }
    }
}