// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public WETH; 
    
    constructor() public {
        factory = new MockFactory();
        WETH = address(0xEE);
    }
}

contract GarfieldCentralizationTest is Test {
    GARFIELD public token;
    address public constant owner = address(0x1);
    address public constant user = address(0x2);
    MockRouter public router;

    function setUp() public {
        router = new MockRouter();
        
        vm.prank(owner);
        token = new GARFIELD(payable(address(router)));
        
        vm.prank(owner);
        token.activateContract();
    }

    function testOwnerCanChangeCriticalParameters() public {
        bool allChangesSuccessful = true;
        string memory failureMessage = "";

        // 1. setTaxFeePercent
        {
            console.log("--- BEFORE setTaxFeePercent(10) ---");
            uint256 beforeState = token._taxFee();
            console.log("_taxFee before:", beforeState);
            
            console.log("--- EXECUTING setTaxFeePercent(10) ---");
            vm.prank(owner);
            token.setTaxFeePercent(10);
            
            console.log("--- AFTER setTaxFeePercent(10) ---");
            uint256 afterState = token._taxFee();
            console.log("_taxFee after:", afterState);
            
            if (afterState != 10) {
                failureMessage = string(abi.encodePacked(failureMessage, "Tax fee not updated; "));
                allChangesSuccessful = false;
            }
        }

        // 2. setLiquidityFeePercent
        {
            console.log("\n--- BEFORE setLiquidityFeePercent(8) ---");
            uint256 beforeState = token._liquidityFee();
            console.log("_liquidityFee before:", beforeState);
            
            console.log("--- EXECUTING setLiquidityFeePercent(8) ---");
            vm.prank(owner);
            token.setLiquidityFeePercent(8);
            
            console.log("--- AFTER setLiquidityFeePercent(8) ---");
            uint256 afterState = token._liquidityFee();
            console.log("_liquidityFee after:", afterState);
            
            if (afterState != 8) {
                failureMessage = string(abi.encodePacked(failureMessage, "Liquidity fee not updated; "));
                allChangesSuccessful = false;
            }
        }

        // 3. setSwapAndLiquifyEnabled (disable)
        {
            console.log("\n--- BEFORE setSwapAndLiquifyEnabled(false) ---");
            bool beforeState = token.swapAndLiquifyEnabled();
            console.log("swapAndLiquifyEnabled before (disable):", beforeState);
            
            console.log("--- EXECUTING setSwapAndLiquifyEnabled(false) ---");
            vm.prank(owner);
            token.setSwapAndLiquifyEnabled(false);
            
            console.log("--- AFTER setSwapAndLiquifyEnabled(false) ---");
            bool afterState = token.swapAndLiquifyEnabled();
            console.log("swapAndLiquifyEnabled after:", afterState);
            
            if (afterState != false) {
                failureMessage = string(abi.encodePacked(failureMessage, "Disable swapAndLiquify failed; "));
                allChangesSuccessful = false;
            }
        }

        // 4. setSwapAndLiquifyEnabled (enable)
        {
            console.log("\n--- BEFORE setSwapAndLiquifyEnabled(true) ---");
            bool beforeState = token.swapAndLiquifyEnabled();
            console.log("swapAndLiquifyEnabled before (enable):", beforeState);
            
            console.log("--- EXECUTING setSwapAndLiquifyEnabled(true) ---");
            vm.prank(owner);
            token.setSwapAndLiquifyEnabled(true);
            
            console.log("--- AFTER setSwapAndLiquifyEnabled(true) ---");
            bool afterState = token.swapAndLiquifyEnabled();
            console.log("swapAndLiquifyEnabled after:", afterState);
            
            if (afterState != true) {
                failureMessage = string(abi.encodePacked(failureMessage, "Enable swapAndLiquify failed; "));
                allChangesSuccessful = false;
            }
        }

        // 5. setMaxTxPercent
        {
            console.log("\n--- BEFORE setMaxTxPercent(500) ---");
            uint256 beforeState = token._maxTxAmount();
            console.log("_maxTxAmount before:", beforeState);
            
            console.log("--- EXECUTING setMaxTxPercent(500) ---");
            vm.prank(owner);
            token.setMaxTxPercent(500);
            
            console.log("--- AFTER setMaxTxPercent(500) ---");
            uint256 afterState = token._maxTxAmount();
            console.log("_maxTxAmount after:", afterState);
            
            if (afterState == beforeState) {
                failureMessage = string(abi.encodePacked(failureMessage, "MaxTxAmount not updated; "));
                allChangesSuccessful = false;
            }
        }

        // 6. excludeFromFee
        {
            console.log("\n--- BEFORE excludeFromFee(user) ---");
            bool beforeState = token.isExcludedFromFee(user);
            console.log("isExcludedFromFee before:", beforeState);
            
            console.log("--- EXECUTING excludeFromFee(user) ---");
            vm.prank(owner);
            token.excludeFromFee(user);
            
            console.log("--- AFTER excludeFromFee(user) ---");
            bool afterState = token.isExcludedFromFee(user);
            console.log("isExcludedFromFee after:", afterState);
            
            if (afterState != true) {
                failureMessage = string(abi.encodePacked(failureMessage, "ExcludeFromFee failed; "));
                allChangesSuccessful = false;
            }
        }

        // 7. includeInFee
        {
            console.log("\n--- BEFORE includeInFee(user) ---");
            bool beforeState = token.isExcludedFromFee(user);
            console.log("isExcludedFromFee before:", beforeState);
            
            console.log("--- EXECUTING includeInFee(user) ---");
            vm.prank(owner);
            token.includeInFee(user);
            
            console.log("--- AFTER includeInFee(user) ---");
            bool afterState = token.isExcludedFromFee(user);
            console.log("isExcludedFromFee after:", afterState);
            
            if (afterState != false) {
                failureMessage = string(abi.encodePacked(failureMessage, "IncludeInFee failed; "));
                allChangesSuccessful = false;
            }
        }

        // 8. excludeFromReward
        {
            console.log("\n--- BEFORE excludeFromReward(user) ---");
            bool beforeState = token.isExcludedFromReward(user);
            console.log("isExcludedFromReward before:", beforeState);
            
            console.log("--- EXECUTING excludeFromReward(user) ---");
            vm.prank(owner);
            token.excludeFromReward(user);
            
            console.log("--- AFTER excludeFromReward(user) ---");
            bool afterState = token.isExcludedFromReward(user);
            console.log("isExcludedFromReward after:", afterState);
            
            if (afterState != true) {
                failureMessage = string(abi.encodePacked(failureMessage, "ExcludeFromReward failed; "));
                allChangesSuccessful = false;
            }
        }

        // 9. setExcludeFromMaxTx
        {
            console.log("\n--- EXECUTING setExcludeFromMaxTx(user, true) ---");
            // Skip state verification - private property with no getter
            console.log("Skipping state verification for _isExcludedFromMaxTx");
            console.log("(State is private property with no public getter)");
            
            vm.prank(owner);
            token.setExcludeFromMaxTx(user, true);
            
            console.log("Function executed successfully");
            // Cannot verify private state - assume success if no revert
        }

        // Final vulnerability assessment
        console.log("\n=== FINAL VULNERABILITY ASSESSMENT ===");
        if (allChangesSuccessful) {
            console.log("Vulnerability Exists: Owner successfully modified critical parameters");
        } else {
            console.log("Vulnerability not Exist: Failed parameter changes -", failureMessage);
        }
        
        // Final assertion for test framework
        assertTrue(allChangesSuccessful, failureMessage);
    }
}