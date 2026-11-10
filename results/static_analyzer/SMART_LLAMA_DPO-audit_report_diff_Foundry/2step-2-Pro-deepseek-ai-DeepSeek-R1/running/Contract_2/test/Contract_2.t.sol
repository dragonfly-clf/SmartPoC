// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Contract.sol";

contract ContractTest is Test {
    Contract token;
    address owner = address(0x1234);
    address sampleWallet = address(0x5678);
    
    // BSC mainnet fork URL - replace with your RPC URL if needed
    string BSC_RPC_URL = "https://bsc-dataseed.binance.org/";

    function setUp() public {
        // Create a fork of BSC mainnet
        vm.createSelectFork(BSC_RPC_URL);
        
        vm.startPrank(owner);
        token = new Contract(
            "TestToken", 
            "TEST", 
            1_000_000 * 10**18, // Total supply
            18, // Decimals
            payable(owner), // Owner wallet
            payable(address(0)), // Discount code
            0 // Contract fee
        );
        vm.stopPrank();
    }

    // Test for ID uniqueness violation in Maintenance_02__Add_Liquidity_Pair
    function testDuplicateLiquidityPair() public {
        console2.log("--- BEFORE-Trigger: First Add_Liquidity_Pair call ---");
        vm.prank(owner);
        token.Maintenance_02__Add_Liquidity_Pair(sampleWallet, true);
        console2.log("First call succeeded");

        console2.log("--- Trigger: Second Add_Liquidity_Pair call (duplicate) ---");
        bool success;
        vm.prank(owner);
        try token.Maintenance_02__Add_Liquidity_Pair(sampleWallet, true) {
            success = true;
        } catch {
            success = false;
        }

        console2.log("--- AFTER-Trigger: Duplicate call result ---");
        if (success) {
            console2.log("Vulnerability Exists: Duplicate call succeeded");
        } else {
            console2.log("Vulnerability not Exist: Duplicate call reverted");
        }
    }

    // Test for ID uniqueness violation in Launch_Settings_01__Blacklist_Bots
    function testDuplicateBlacklist() public {
        console2.log("--- BEFORE-Trigger: First Blacklist_Bots call ---");
        vm.prank(owner);
        token.Launch_Settings_01__Blacklist_Bots(sampleWallet, true);
        console2.log("First call succeeded");

        console2.log("--- Trigger: Second Blacklist_Bots call (duplicate) ---");
        bool success;
        vm.prank(owner);
        try token.Launch_Settings_01__Blacklist_Bots(sampleWallet, true) {
            success = true;
        } catch {
            success = false;
        }

        console2.log("--- AFTER-Trigger: Duplicate call result ---");
        if (success) {
            console2.log("Vulnerability Exists: Duplicate call succeeded");
        } else {
            console2.log("Vulnerability not Exist: Duplicate call reverted");
        }
    }

    // Test for ID uniqueness violation in Wallet_Settings_01__PreLaunch_Access
    function testDuplicatePreLaunchAccess() public {
        console2.log("--- BEFORE-Trigger: First PreLaunch_Access call ---");
        vm.prank(owner);
        token.Wallet_Settings_01__PreLaunch_Access(sampleWallet, true);
        console2.log("First call succeeded");

        console2.log("--- Trigger: Second PreLaunch_Access call (duplicate) ---");
        bool success;
        vm.prank(owner);
        try token.Wallet_Settings_01__PreLaunch_Access(sampleWallet, true) {
            success = true;
        } catch {
            success = false;
        }

        console2.log("--- AFTER-Trigger: Duplicate call result ---");
        if (success) {
            console2.log("Vulnerability Exists: Duplicate call succeeded");
        } else {
            console2.log("Vulnerability not Exist: Duplicate call reverted");
        }
    }
}