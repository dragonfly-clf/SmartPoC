// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZeusPet.sol";

contract ZeusPetPrivilegeTest is Test {
    ZeusPet token;
    address owner = address(0xABCD);
    address attacker = address(0x1337);
    address initialMarketingWallet = address(0x999);

    function setUp() public {
        vm.prank(owner);
        token = new ZeusPet(300, 200, initialMarketingWallet);
    }

    function test_MarketingWallet_Escalation() public {
        console2.log("--- BEFORE-Trigger State ---");
        address preMarketingWallet = token.marketingWallet();
        bool preInitialExcluded = token.excludeFromFee(initialMarketingWallet);
        bool preAttackerExcluded = token.excludeFromFee(attacker);
        
        console2.log("Current Marketing Wallet:", preMarketingWallet);
        console2.log("Initial Wallet Excluded:", preInitialExcluded);
        console2.log("Attacker Excluded:", preAttackerExcluded);

        console2.log("--- Trigger MarketingWallet Change (Attack) ---");
        vm.startPrank(owner);
        token.setMarketingWallet(attacker);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        address postMarketingWallet = token.marketingWallet();
        bool postInitialExcluded = token.excludeFromFee(initialMarketingWallet);
        bool postAttackerExcluded = token.excludeFromFee(attacker);
        
        console2.log("Updated Marketing Wallet:", postMarketingWallet);
        console2.log("Initial Wallet Still Excluded:", postInitialExcluded);
        console2.log("Attacker Now Excluded:", postAttackerExcluded);

        bool marketingWalletChanged = (postMarketingWallet == attacker);
        bool attackerGainedExemption = (!preAttackerExcluded && postAttackerExcluded);
        bool initialWalletRemainsExempt = (preInitialExcluded && postInitialExcluded);
        
        if (marketingWalletChanged && attackerGainedExemption && initialWalletRemainsExempt) {
            console2.log("\nVulnerability Exists: Marketing wallet changed to attacker & excluded");
        } else {
            console2.log("\nVulnerability not Exist: State manipulation failed");
        }
    }

    function test_FeeExclusion_Escalation() public {
        console2.log("--- BEFORE-Trigger State ---");
        bool preExcluded = token.excludeFromFee(attacker);
        console2.log("Attacker Initially Excluded:", preExcluded);

        console2.log("--- Trigger FeeExclusion Change (Attack) ---");
        vm.startPrank(owner);
        token.setExcludeFromFee(attacker, true);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger State ---");
        bool postExcluded = token.excludeFromFee(attacker);
        console2.log("Attacker Excluded After Attack:", postExcluded);
        
        if (!preExcluded && postExcluded) {
            console2.log("\nVulnerability Exists: Attacker gained fee-excluded status");
        } else {
            console2.log("\nVulnerability not Exist: Fee-exclusion unchanged");
        }
    }
}