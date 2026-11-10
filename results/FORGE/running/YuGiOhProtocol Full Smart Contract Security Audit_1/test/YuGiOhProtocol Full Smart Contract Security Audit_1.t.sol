// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YuGiOhProtocol.sol";

contract GasExhaustionTest is Test {
    YuGiOhProtocol token;
    address owner;
    address constant HARDCODED_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockFactory = address(0x2);
    address mockWETH = address(0x4);
    address mockPair = address(0x3);
    
    address[] excludedAccounts;
    address nonExcludedAccount = address(0x9999);
    
    function setUp() public {
        owner = address(this);
        excludedAccounts = new address[](400);
        
        // Set up mock calls for router
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Set up mock call for factory
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)", address(this), mockWETH),
            abi.encode(mockPair)
        );

        // Deploy token
        token = new YuGiOhProtocol();
        
        // Exclude large number of accounts
        for (uint256 i = 0; i < excludedAccounts.length; i++) {
            address account = address(uint160(i + 100));
            token.excludeFromReward(account);
            excludedAccounts[i] = account;
        }
        
        // Transfer tokens to a non-excluded account
        token.transfer(nonExcludedAccount, 1 ether);
    }

    function testIncludeInRewardGasExhaustion() public {
        address account = excludedAccounts[excludedAccounts.length - 1];
        
        console.log("--- BEFORE-Trigger includeInReward ---");
        uint256 gasBefore = gasleft();
        
        console.log("--- Trigger includeInReward ---");
        token.includeInReward(account);
        
        console.log("--- AFTER-Trigger includeInReward ---");
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for includeInReward: %s", gasUsed);
        
        // Check against threshold and determine vulnerability
        uint256 threshold = 500_000;
        bool gasExceedsThreshold = gasUsed > threshold;
        
        if (gasExceedsThreshold) {
            console.log("Vulnerability Exists: includeInReward gas consumption exceeds threshold of %s", threshold);
        } else {
            console.log("Vulnerability not Exist: includeInReward gas consumption is within threshold of %s", threshold);
        }
        assertTrue(gasExceedsThreshold, "Gas consumption too low - possible fix applied");
    }

    function testGetCurrentSupplyGasExhaustion() public {
        console.log("--- BEFORE-Trigger balanceOf (non-excluded) ---");
        uint256 gasBefore = gasleft();
        
        console.log("--- Trigger balanceOf (non-excluded) ---");
        token.balanceOf(nonExcludedAccount);
        
        console.log("--- AFTER-Trigger balanceOf (non-excluded) ---");
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for balanceOf (non-excluded): %s", gasUsed);
        
        // Check against threshold and determine vulnerability
        uint256 threshold = 100_000;
        bool gasExceedsThreshold = gasUsed > threshold;
        
        if (gasExceedsThreshold) {
            console.log("Vulnerability Exists: balanceOf gas consumption exceeds threshold of %s", threshold);
        } else {
            console.log("Vulnerability not Exist: balanceOf gas consumption is within threshold of %s", threshold);
        }
        assertTrue(gasExceedsThreshold, "Gas consumption too low - possible fix applied");
    }
}