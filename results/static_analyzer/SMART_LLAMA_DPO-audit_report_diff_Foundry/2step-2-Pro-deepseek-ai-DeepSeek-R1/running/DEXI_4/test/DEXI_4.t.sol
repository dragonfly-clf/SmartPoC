// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEXIPrivilegeEscalationTest is Test {
    DEXI public token;
    address deployer = makeAddr("deployer");
    address normalUser = makeAddr("normalUser");
    
    function setUp() public {
        vm.startPrank(deployer);
        token = new DEXI();
        vm.stopPrank();
    }

    // Verify only owner can call setExcludeEnabled()
    function test_OnlyOwnerCanCallSetExcludeEnabled() public {
        vm.prank(deployer);
        token.setExcludeEnabled(true);
        
        // Before non-owner call
        console.log("--- BEFORE-Trigger State ---");
        bool excludeEnabledBefore = token.excludeEnabled();
        console.log("excludeEnabled state before non-owner call:", excludeEnabledBefore ? "true" : "false");

        console.log("--- Trigger Non-Owner Call ---");
        // Should revert if called by non-owner
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setExcludeEnabled(false);
        
        // After non-owner call
        console.log("--- AFTER-Trigger State ---");
        bool excludeEnabledAfter = token.excludeEnabled();
        console.log("excludeEnabled state after non-owner call:", excludeEnabledAfter ? "true" : "false");
        
        // Vulnerability verdict
        if (excludeEnabledBefore == excludeEnabledAfter) {
            console.log("Vulnerability not Exist: State unchanged, access control enforced for setExcludeEnabled()");
        } else {
            console.log("Vulnerability Exists: State changed by non-owner call to setExcludeEnabled()");
        }
    }

    // Verify only owner can call setEnableTaxOnlyForSell()
    function test_OnlyOwnerCanCallSetEnableTaxOnlyForSell() public {
        vm.prank(deployer);
        token.setEnableTaxOnlyForSell(true);
        
        // Before non-owner call
        console.log("--- BEFORE-Trigger State ---");
        bool taxOnlySellBefore = token.enableTaxOnlyForSell();
        console.log("enableTaxOnlyForSell state before non-owner call:", taxOnlySellBefore ? "true" : "false");

        console.log("--- Trigger Non-Owner Call ---");
        // Should revert if called by non-owner
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setEnableTaxOnlyForSell(false);
        
        // After non-owner call
        console.log("--- AFTER-Trigger State ---");
        bool taxOnlySellAfter = token.enableTaxOnlyForSell();
        console.log("enableTaxOnlyForSell state after non-owner call:", taxOnlySellAfter ? "true" : "false");
        
        // Vulnerability verdict
        if (taxOnlySellBefore == taxOnlySellAfter) {
            console.log("Vulnerability not Exist: State unchanged, access control enforced for setEnableTaxOnlyForSell()");
        } else {
            console.log("Vulnerability Exists: State changed by non-owner call to setEnableTaxOnlyForSell()");
        }
    }

    // Verify only owner can call setEnableTaxOnlyForTransfer()
    function test_OnlyOwnerCanCallSetEnableTaxOnlyForTransfer() public {
        vm.prank(deployer);
        token.setEnableTaxOnlyForTransfer(true);
        
        // Before non-owner call
        console.log("--- BEFORE-Trigger State ---");
        bool taxOnlyTransferBefore = token.enableTaxOnlyForTransfer();
        console.log("enableTaxOnlyForTransfer state before non-owner call:", taxOnlyTransferBefore ? "true" : "false");

        console.log("--- Trigger Non-Owner Call ---");
        // Should revert if called by non-owner
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setEnableTaxOnlyForTransfer(false);
        
        // After non-owner call
        console.log("--- AFTER-Trigger State ---");
        bool taxOnlyTransferAfter = token.enableTaxOnlyForTransfer();
        console.log("enableTaxOnlyForTransfer state after non-owner call:", taxOnlyTransferAfter ? "true" : "false");
        
        // Vulnerability verdict
        if (taxOnlyTransferBefore == taxOnlyTransferAfter) {
            console.log("Vulnerability not Exist: State unchanged, access control enforced for setEnableTaxOnlyForTransfer()");
        } else {
            console.log("Vulnerability Exists: State changed by non-owner call to setEnableTaxOnlyForTransfer()");
        }
    }
}