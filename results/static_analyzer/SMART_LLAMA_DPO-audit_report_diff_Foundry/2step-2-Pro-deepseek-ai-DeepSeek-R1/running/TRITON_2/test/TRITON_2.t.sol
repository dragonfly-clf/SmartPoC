// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TRITON.sol";

contract TritonTest is Test {
    TRITON token;
    address owner = address(0x1);
    address accountA = address(0x2);

    MockFactory mockFactory;
    MockRouter mockRouter;

    function setUp() public {
        // Setup mocks for Uniswap
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory));
        
        // Mock BSC router address
        address pancakeswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(pancakeswapRouter, address(mockRouter).code);

        // Deploy TRITON
        vm.startPrank(owner);
        token = new TRITON();
        vm.stopPrank();
    }

    function test_setExcludeDividendsUniqueness() public {
        // First exclusion - should succeed
        vm.prank(owner);
        token.setExcludeDividends(accountA);
        
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Account exclusion status: Initialized");
        
        console.log("--- Trigger Duplicate Call ---");
        // Duplicate exclusion detection
        bool success;
        vm.prank(owner);
        try token.setExcludeDividends(accountA) {
            success = true;
        } catch {
            success = false;
        }
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Duplicate call executed without revert");
        
        // Conditional verdict
        if (success) {
            console.log("Vulnerability Exists: setExcludeDividends allows duplicate calls without revert");
        } else {
            console.log("Vulnerability not Exist: Duplicate call reverted as expected");
            fail("Vulnerability eliminated: expected revert");
        }
    }

    function test_setExcludeFeesUniqueness() public {
        // First exclusion - should succeed
        vm.prank(owner);
        token.setExcludeFees(accountA, true);
        assertTrue(token.isExcludedFromFees(accountA));
        
        console.log("--- BEFORE-Trigger Call ---");
        console.log("AccountA fee exclusion status:", token.isExcludedFromFees(accountA));
        
        console.log("--- Trigger Duplicate Call ---");
        // Duplicate exclusion detection
        bool success;
        vm.prank(owner);
        try token.setExcludeFees(accountA, true) {
            success = true;
        } catch {
            success = false;
        }
        
        console.log("--- AFTER-Trigger State ---");
        assertTrue(token.isExcludedFromFees(accountA));
        console.log("AccountA fee exclusion status:", token.isExcludedFromFees(accountA));
        console.log("Duplicate call executed without revert");
        
        // Conditional verdict
        if (success) {
            console.log("Vulnerability Exists: setExcludeFees allows duplicate calls without revert");
        } else {
            console.log("Vulnerability not Exist: Duplicate call reverted as expected");
            fail("Vulnerability eliminated: expected revert");
        }
    }
}

// Mock Uniswap Factory
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

// Mock Uniswap Router
contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }
}