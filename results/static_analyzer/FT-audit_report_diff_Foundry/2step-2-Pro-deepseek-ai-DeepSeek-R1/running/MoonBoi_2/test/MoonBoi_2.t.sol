// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoonBoi.sol";

contract MoonBoiTest is Test {
    MoonBoi token;
    address private constant MOCK_ROUTER_ADDR = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant USER = address(0x123);
    
    function setUp() public {
        // Mock WETH address for calls
        address mockWETH = address(0x000000000000000000000000000000000000dEaD);
        
        // Setup mock responses for Pancake router functions
        vm.mockCall(
            MOCK_ROUTER_ADDR,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0))
        );
        vm.mockCall(
            address(0),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0))
        );
        vm.mockCall(
            MOCK_ROUTER_ADDR,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Deploy token - router initialization is mocked
        token = new MoonBoi();
        
        // Enable trading for the token
        token.SetupEnableTrading();
    }

    function testBasicFunctionality() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        // Verify initial USER balance
        uint256 initialBalance = token.balanceOf(USER);
        console.log("USER initial balance:", initialBalance);

        uint256 amount = 100;
        console.log("--- Trigger Transfer ---");
        // Execute transfer
        token.transfer(USER, amount);
        console.log("Transferred %s tokens to USER", amount);

        console.log("--- AFTER-Trigger Transfer ---");
        // Verify post-transfer USER balance
        uint256 finalBalance = token.balanceOf(USER);
        console.log("USER final balance:", finalBalance);
        
        // Calculate and log balance change
        uint256 balanceChange = finalBalance - initialBalance;
        console.log("Expected change: +%s", amount);
        console.log("Actual change: +%s", balanceChange);

        // Validate functionality
        if (balanceChange == amount) {
            console.log("Verdict: Balance change matches transfer amount");
            console.log("Vulnerability not Exist: Standard transfer functionality works as expected");
        } else {
            console.log("Verdict: Balance change does NOT match transfer amount");
            console.log("Vulnerability Exists: Transfer operation malfunction detected");
        }
    }
}