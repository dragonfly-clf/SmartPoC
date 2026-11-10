// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MCG.sol";

contract MockUniswapV2Router02 {
    function factory() external pure returns (address) {
        return address(0xABCD);
    }
    
    function WETH() external pure returns (address) {
        return address(0x1234);
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x5678);
    }
}

contract PrivilegeEscalationTest is Test {
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY_ADDR = address(0xABCD);
    address constant MOCK_WETH_ADDR = address(0x1234);
    
    MCG public mcg;
    MCGDividendTracker public dividendTracker;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock contracts to get bytecode
        MockUniswapV2Router02 mockRouter = new MockUniswapV2Router02();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        
        // Patch existing addresses with mock contracts
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        vm.etch(MOCK_FACTORY_ADDR, address(mockFactory).code);

        // Deploy main contract
        mcg = new MCG();
        dividendTracker = mcg.dividendTracker();
        
        vm.stopPrank();
    }
    
    function test_AllowCustomTokensToggle() public {
        console.log("--- BEFORE-Trigger State---");
        bool initialState = dividendTracker.allowCustomTokens();
        console.log("allowCustomTokens before:", initialState);

        console.log("--- Trigger setAllowCustomTokens ---");
        vm.prank(owner);
        mcg.setAllowCustomTokens(!initialState);

        console.log("--- AFTER-Trigger State---");
        bool newState = dividendTracker.allowCustomTokens();
        console.log("allowCustomTokens after:", newState);
        console.log("State change detected:", newState != initialState ? "YES" : "NO");

        // Final vulnerability verdict
        if (newState != initialState) {
            console.log("Vulnerability Exists: allowCustomTokens state was successfully modified");
        } else {
            console.log("Vulnerability not Exist: allowCustomTokens state remains unchanged");
        }
        
        assertEq(
            newState, 
            !initialState, 
            "Custom tokens toggle failed"
        );
    }
    
    function test_AllowAutoReinvestToggle() public {
        console.log("--- BEFORE-TriggerState ---");
        bool initialState = dividendTracker.allowAutoReinvest();
        console.log("allowAutoReinvest before:", initialState);

        console.log("--- Trigger setAllowAutoReinvest ---");
        vm.prank(owner);
        mcg.setAllowAutoReinvest(!initialState);

        console.log("--- AFTER-TriggerState ---");
        bool newState = dividendTracker.allowAutoReinvest();
        console.log("allowAutoReinvest after:", newState);
        console.log("State change detected:", newState != initialState ? "YES" : "NO");

        // Final vulnerability verdict
        if (newState != initialState) {
            console.log("Vulnerability Exists: allowAutoReinvest state was successfully modified");
        } else {
            console.log("Vulnerability not Exist: allowAutoReinvest state remains unchanged");
        }
        
        assertEq(
            newState, 
            !initialState, 
            "Auto reinvest toggle failed"
        );
    }
}