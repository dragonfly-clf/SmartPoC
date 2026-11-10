// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "../src/DRIVEN.sol";

contract MockERC20 {
    function approve(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract MockUniswapV2Router {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract DRIVENBlacklistTest is Test {
    DRIVEN token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address marketing = makeAddr("marketing");
    
    // Predefined addresses for Uniswap and reward token
    address constant UNISWAP_ROUTER_ADDRESS = 0x1B6C9c20693afDE803B27F8782156c0f892ABC2d;
    address constant UNISWAP_FACTORY_ADDRESS = 0x1111111111111111111111111111111111111111;
    address constant REWARD_TOKEN_ADDRESS = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    address constant UNISWAP_PAIR_ADDRESS = 0x2222222222222222222222222222222222222222;

    function setUp() public {
        // Deploy mocks and etch to required addresses
        MockUniswapV2Router mockRouter = new MockUniswapV2Router();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        
        // Set mock contracts at predefined addresses
        vm.etch(UNISWAP_FACTORY_ADDRESS, address(mockFactory).code);
        vm.etch(UNISWAP_ROUTER_ADDRESS, address(mockRouter).code);
        
        // Create reward token contract at expected address
        bytes memory mockTokenCode = type(MockERC20).runtimeCode;
        vm.etch(REWARD_TOKEN_ADDRESS, mockTokenCode);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new DRIVEN(
            "TestToken", 
            "TST", 
            18, 
            1000000, 
            owner, 
            marketing
        );
        vm.stopPrank();

        // Transfer tokens to Alice for test
        vm.prank(owner);
        token.transfer(alice, 100 * 10**18);
    }

    function test_blacklisted_user_transfer_revert() public {
        console.log("--- BEFORE-Trigger Blacklist ---");
        // Query initial blacklist state as owner
        vm.startPrank(owner);
        bool aliceBlacklistedBefore = token.getBAddress(alice);
        vm.stopPrank();
        console.log("Alice blacklisted (before):", aliceBlacklistedBefore);
        assertFalse(aliceBlacklistedBefore, "Alice should not be blacklisted initially");

        // Alice transfers normally first
        vm.prank(alice);
        token.transfer(owner, 10 * 10**18);

        // Execute critical action
        console.log("--- Trigger Blacklist ---");
        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        vm.prank(owner);
        token.setMutilpyBAddress(accounts, true);

        console.log("--- AFTER-Trigger Blacklist ---");
        // Query updated state as owner
        vm.startPrank(owner);
        bool aliceBlacklistedAfter = token.getBAddress(alice);
        vm.stopPrank();
        console.log("Alice blacklisted (after):", aliceBlacklistedAfter);
        
        // Validate state change
        if (aliceBlacklistedAfter) {
            console.log("State Change Verdict: Blacklist status changed successfully");
            
            // Attempted transfer from blacklisted Alice should revert
            vm.prank(alice);
            vm.expectRevert("ERC20: transfer from | to bAddress");
            token.transfer(owner, 10 * 10**18);
            
            console.log("Vulnerability Exists: Blacklist functionality works as expected");
        } else {
            console.log("State Change Verdict: Blacklist status unchanged");
            console.log("Vulnerability not Exist: Blacklist setting had no effect");
        }
    }

    function test_blacklisted_user_receive_revert() public {
        console.log("--- BEFORE-Trigger Blacklist ---");
        // Query initial blacklist state as owner
        vm.startPrank(owner);
        bool aliceBlacklistedBefore = token.getBAddress(alice);
        vm.stopPrank();
        console.log("Alice blacklisted (before):", aliceBlacklistedBefore);
        assertFalse(aliceBlacklistedBefore, "Alice should not be blacklisted initially");

        // Execute critical action
        console.log("--- Trigger Blacklist ---");
        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        vm.prank(owner);
        token.setMutilpyBAddress(accounts, true);

        console.log("--- AFTER-Trigger Blacklist ---");
        // Query updated state as owner
        vm.startPrank(owner);
        bool aliceBlacklistedAfter = token.getBAddress(alice);
        vm.stopPrank();
        console.log("Alice blacklisted (after):", aliceBlacklistedAfter);
        
        // Validate state change
        if (aliceBlacklistedAfter) {
            console.log("State Change Verdict: Blacklist status changed successfully");
            
            // Attempt to transfer to blacklisted Alice should revert
            vm.prank(owner);
            vm.expectRevert("ERC20: transfer from | to bAddress");
            token.transfer(alice, 10 * 10**18);
            
            console.log("Vulnerability Exists: Blacklist functionality works as expected");
        } else {
            console.log("State Change Verdict: Blacklist status unchanged");
            console.log("Vulnerability not Exist: Blacklist setting had no effect");
        }
    }
}