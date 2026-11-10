// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/Jesus.sol";

contract JesusTradingTest is Test {
    Jesus public token;
    address public owner;
    address public alice;
    address public bob;
    
    // Mock addresses
    address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address mockFactory = address(0x123);
    address mockWETH = address(0x456);
    address mockPair = address(0x789);

    function setUp() public {
        // Setup accounts
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        
        // Initialize router address with empty contract code
        vm.etch(routerAddress, hex"00");
        
        // Mock router calls
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token as owner
        vm.prank(owner);
        token = new Jesus();

        // Transfer tokens to alice
        vm.prank(owner);
        token.transfer(alice, 1000 * 1e18);
    }

    function testTransferWhenTradingDisabled() public {
        // Alice attempts transfer - should fail (non-excluded)
        vm.prank(alice);
        vm.expectRevert("Trading is not active.");
        token.transfer(bob, 100 * 1e18);
    }

    function testEnableTrading() public {
        // Record initial state
        uint256 initialAliceBalance = token.balanceOf(alice);
        uint256 initialBobBalance = token.balanceOf(bob);
        bool tradingActiveBefore = token.tradingActive();

        console2.log("--- BEFORE-Trigger Transfer ---");
        console2.log("Trading active: %s", tradingActiveBefore);
        console2.log("Alice balance: %d", initialAliceBalance);
        console2.log("Bob balance: %d", initialBobBalance);

        // Attempt to transfer before trading enabled (should fail)
        vm.prank(alice);
        vm.expectRevert("Trading is not active.");
        token.transfer(bob, 100 * 1e18);
        uint256 bobBalanceAfterFail = token.balanceOf(bob);

        console2.log("--- Trigger: Owner enableTrading ---");
        // Owner enables trading - critical action to test
        vm.prank(owner);
        token.enableTrading();

        // Get state after trigger
        bool tradingActiveAfter = token.tradingActive();

        console2.log("--- AFTER-Trigger Transfer ---");
        console2.log("Trading active: %s", tradingActiveAfter);
        console2.log("Alice balance: %d", token.balanceOf(alice));
        console2.log("Bob balance: %d", bobBalanceAfterFail);

        // Attempt transfer after trading enabled (should succeed)
        vm.prank(alice);
        token.transfer(bob, 100 * 1e18);
        uint256 bobBalanceAfterSuccess = token.balanceOf(bob);

        console2.log("Transfer result: %d tokens received by Bob", bobBalanceAfterSuccess - bobBalanceAfterFail);

        // Vulnerability verification logic
        bool transferSucceeded = bobBalanceAfterSuccess > bobBalanceAfterFail;
        bool tradingEnabledChanged = !tradingActiveBefore && tradingActiveAfter;
        bool vulnerabilityExists = transferSucceeded && tradingEnabledChanged;

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Trading status can be changed enabling transfers");
        } else {
            console2.log("Vulnerability not Exist: Trading status change didn't enable transfers as expected");
        }

        // Continue with original verification
        assertEq(token.balanceOf(bob), 100 * 1e18, "Initial transfer failed after enabling");
        vm.prank(alice);
        token.transfer(bob, 100 * 1e18);
        assertEq(token.balanceOf(bob), 200 * 1e18, "Secondary transfer failed");
    }
}