// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/NUTGAIN.sol";

contract NUTGAINTest is Test {
    NUTGAIN nutGain;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    MockRouter router;

    function setUp() public {
        router = new MockRouter();
        vm.startPrank(owner);
        nutGain = new NUTGAIN(address(router));
        vm.stopPrank();
    }

    function test_OwnerCanEnableTrading() public {
        // Initial state check
        console.log("--- BEFORE-Trigger TradingState ---");
        assertFalse(nutGain.tradingEnabled(), "Initial state should be disabled");
        
        // Owner enables trading
        console.log("--- Trigger EnableTrading ---");
        vm.prank(owner);
        nutGain.setTradingStatus(true, 0, 0, 0, 0, 0, 0, 0);
        
        // Post-state validation
        console.log("--- AFTER-Trigger TradingState ---");
        assertTrue(nutGain.tradingEnabled(), "State should be enabled after owner action");
        console.log("Vulnerability not Exist: Owner successfully enabled trading as expected");
    }

    function test_OwnerCanDisableTrading() public {
        // First enable trading
        vm.prank(owner);
        nutGain.setTradingStatus(true, 0, 0, 0, 0, 0, 0, 0);
        
        // Pre-disable state check
        console.log("--- BEFORE-Trigger TradingState ---");
        assertTrue(nutGain.tradingEnabled(), "State should be enabled pre-disable");
        
        // Owner disables trading
        console.log("--- Trigger DisableTrading ---");
        vm.prank(owner);
        nutGain.setTradingStatus(false, 0, 0, 0, 0, 0, 0, 0);
        
        // Post-disable validation
        console.log("--- AFTER-Trigger TradingState ---");
        assertFalse(nutGain.tradingEnabled(), "State should be disabled after owner action");
        console.log("Vulnerability not Exist: Owner successfully disabled trading as expected");
    }

    function test_NonOwnerCannotEnableTrading() public {
        // Initial state snapshot
        console.log("--- BEFORE-Trigger TradingState ---");
        bool initialTradingState = nutGain.tradingEnabled();
        assertFalse(initialTradingState, "Initial state should be disabled");
        
        // Attempt attack from non-owner address
        console.log("--- Trigger NonOwnerEnableTrading ---");
        vm.startPrank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        nutGain.setTradingStatus(true, 0, 0, 0, 0, 0, 0, 0);
        vm.stopPrank();
        
        // Post-attack state validation
        console.log("--- AFTER-Trigger TradingState ---");
        bool postAttackState = nutGain.tradingEnabled();
        assertFalse(postAttackState, "State should remain disabled post-attack");
        
        // Vulnerability verification
        if (initialTradingState != postAttackState) {
            console.log("Vulnerability Exists: Non-owner changed trading state");
        } else {
            console.log("Vulnerability not Exist: Trading state unchanged after non-owner call (correct behavior)");
        }
    }

    function test_NonOwnerCannotDisableTrading() public {
        // First enable trading as owner
        vm.prank(owner);
        nutGain.setTradingStatus(true, 0, 0, 0, 0, 0, 0, 0);
        
        // Pre-attack state snapshot
        console.log("--- BEFORE-Trigger TradingState ---");
        bool initialTradingState = nutGain.tradingEnabled();
        assertTrue(initialTradingState, "Initial state should be enabled");
        
        // Attempt attack from non-owner address
        console.log("--- Trigger NonOwnerDisableTrading ---");
        vm.startPrank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        nutGain.setTradingStatus(false, 0, 0, 0, 0, 0, 0, 0);
        vm.stopPrank();
        
        // Post-attack state validation
        console.log("--- AFTER-Trigger TradingState ---");
        bool postAttackState = nutGain.tradingEnabled();
        assertTrue(postAttackState, "State should remain enabled post-attack");
        
        // Vulnerability verification
        if (initialTradingState != postAttackState) {
            console.log("Vulnerability Exists: Non-owner changed trading state");
        } else {
            console.log("Vulnerability not Exist: Trading state unchanged after non-owner call (correct behavior)");
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234); 
    }
}

contract MockRouter {
    MockFactory public factoryContract;
    address public weth;
    
    constructor() {
        factoryContract = new MockFactory();
        weth = address(0x5678);
    }
    
    function factory() external view returns (address) {
        return address(factoryContract);
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}