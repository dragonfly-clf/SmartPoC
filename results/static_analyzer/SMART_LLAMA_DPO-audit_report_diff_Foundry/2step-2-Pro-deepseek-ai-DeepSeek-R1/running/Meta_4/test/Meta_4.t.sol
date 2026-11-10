// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Meta.sol";

contract MetaPrivilegeTest is Test {
    Meta public token;
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address deployer = address(0x1);
    address marketingWallet = makeAddr("marketingWallet");
    address teamWallet = makeAddr("teamWallet");
    
    function setUp() public {
        // Setup router mock
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0xcafe1))
        );
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xdead))
        );
        
        // Setup factory mock
        vm.mockCall(
            address(0xcafe1),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0xbeef))
        );
        
        // Deploy contract from deployer account
        vm.startPrank(deployer);
        token = new Meta();
        vm.stopPrank();
    }

    function test_PrivilegeEscalation() public {
        vm.startPrank(deployer);
        bool allPassed = true;
    
        console.log("\n===== Testing setMaxTxAmount =====");
        // Test setMaxTxAmount
        console.log("--- BEFORE: setMaxTxAmount ---");
        uint256 initialMaxTx = token._maxTxAmount();
        console.log("Initial _maxTxAmount: ", initialMaxTx);
        
        // Set and verify first value
        console.log("--- Trigger: setMaxTxAmount(1) ---");
        token.setMaxTxAmount(1);
        console.log("--- AFTER: setMaxTxAmount(1) ---");
        uint256 afterFirstSet = token._maxTxAmount();
        console.log("New _maxTxAmount: ", afterFirstSet);
        bool maxTxPass1 = afterFirstSet == 1;
        if (!maxTxPass1) {
            console.log("FAIL: _maxTxAmount should be 1");
            allPassed = false;
        }
        
        // Set and verify max value
        console.log("--- Trigger: setMaxTxAmount(max) ---");
        token.setMaxTxAmount(type(uint256).max);
        console.log("--- AFTER: setMaxTxAmount(max) ---");
        uint256 afterSecondSet = token._maxTxAmount();
        console.log("New _maxTxAmount: ", afterSecondSet);
        bool maxTxPass2 = afterSecondSet == type(uint256).max;
        if (!maxTxPass2) {
            console.log("FAIL: _maxTxAmount should be max uint256");
            allPassed = false;
        }

        console.log("\n===== Testing setSwapAndLiquifyByLimitOnly =====");
        // Test setSwapAndLiquifyByLimitOnly
        console.log("--- BEFORE: setSwapAndLiquifyByLimitOnly ---");
        bool initialSwapLimit = token.swapAndLiquifyByLimitOnly();
        console.log("Initial swapAndLiquifyByLimitOnly: ", initialSwapLimit);
        
        // Set and verify true
        console.log("--- Trigger: setSwapAndLiquifyByLimitOnly(true) ---");
        token.setSwapAndLiquifyByLimitOnly(true);
        console.log("--- AFTER: setSwapAndLiquifyByLimitOnly(true) ---");
        bool afterTrueSet = token.swapAndLiquifyByLimitOnly();
        console.log("New swapAndLiquifyByLimitOnly: ", afterTrueSet);
        if (afterTrueSet != true) {
            console.log("FAIL: Should be true after setting");
            allPassed = false;
        }
        
        // Set and verify false
        console.log("--- Trigger: setSwapAndLiquifyByLimitOnly(false) ---");
        token.setSwapAndLiquifyByLimitOnly(false);
        console.log("--- AFTER: setSwapAndLiquifyByLimitOnly(false) ---");
        bool afterFalseSet = token.swapAndLiquifyByLimitOnly();
        console.log("New swapAndLiquifyByLimitOnly: ", afterFalseSet);
        if (afterFalseSet != false) {
            console.log("FAIL: Should be false after setting");
            allPassed = false;
        }

        console.log("\n===== Testing setMarketingWalletAddress =====");
        // Test setMarketingWalletAddress
        console.log("--- BEFORE: setMarketingWalletAddress ---");
        address initialMarketing = token.marketingWalletAddress();
        console.log("Initial marketingWallet: ", initialMarketing);
        
        console.log("--- Trigger: setMarketingWalletAddress(new) ---");
        token.setMarketingWalletAddress(marketingWallet);
        console.log("--- AFTER: setMarketingWalletAddress(new) ---");
        address newMarketing = token.marketingWalletAddress();
        console.log("New marketingWallet: ", newMarketing);
        if (newMarketing != marketingWallet) {
            console.log("FAIL: Marketing wallet should be updated");
            allPassed = false;
        }

        console.log("\n===== Testing setTeamWalletAddress =====");
        // Test setTeamWalletAddress
        console.log("--- BEFORE: setTeamWalletAddress ---");
        address initialTeam = token.teamWalletAddress();
        console.log("Initial teamWallet: ", initialTeam);
        
        console.log("--- Trigger: setTeamWalletAddress(new) ---");
        token.setTeamWalletAddress(teamWallet);
        console.log("--- AFTER: setTeamWalletAddress(new) ---");
        address newTeam = token.teamWalletAddress();
        console.log("New teamWallet: ", newTeam);
        if (newTeam != teamWallet) {
            console.log("FAIL: Team wallet should be updated");
            allPassed = false;
        }

        console.log("\n===== Testing setNumTokensBeforeSwap =====");
        // Test setNumTokensBeforeSwap
        console.log("--- BEFORE: setNumTokensBeforeSwap ---");
        uint256 initialMinTokens = token.numTokensBeforeSwap();
        console.log("Initial numTokensBeforeSwap: ", initialMinTokens);
        
        console.log("--- Trigger: setNumTokensBeforeSwap(0) ---");
        token.setNumTokensBeforeSwap(0);
        console.log("--- AFTER: setNumTokensBeforeSwap(0) ---");
        uint256 afterZeroSet = token.numTokensBeforeSwap();
        console.log("New numTokensBeforeSwap: ", afterZeroSet);
        if (afterZeroSet != 0) {
            console.log("FAIL: Should be 0 after setting");
            allPassed = false;
        }
        
        console.log("--- Trigger: setNumTokensBeforeSwap(max) ---");
        token.setNumTokensBeforeSwap(type(uint256).max);
        console.log("--- AFTER: setNumTokensBeforeSwap(max) ---");
        uint256 afterMaxSet = token.numTokensBeforeSwap();
        console.log("New numTokensBeforeSwap: ", afterMaxSet);
        if (afterMaxSet != type(uint256).max) {
            console.log("FAIL: Should be max uint256 after setting");
            allPassed = false;
        }

        console.log("\n===== Testing setSwapAndLiquifyEnabled =====");
        // Test setSwapAndLiquifyEnabled
        console.log("--- BEFORE: setSwapAndLiquifyEnabled ---");
        bool initialSwapEnabled = token.swapAndLiquifyEnabled();
        console.log("Initial swapAndLiquifyEnabled: ", initialSwapEnabled);
        
        console.log("--- Trigger: setSwapAndLiquifyEnabled(false) ---");
        token.setSwapAndLiquifyEnabled(false);
        console.log("--- AFTER: setSwapAndLiquifyEnabled(false) ---");
        bool afterDisable = token.swapAndLiquifyEnabled();
        console.log("New swapAndLiquifyEnabled: ", afterDisable);
        if (afterDisable != false) {
            console.log("FAIL: Should be false after disabling");
            allPassed = false;
        }
        
        console.log("--- Trigger: setSwapAndLiquifyEnabled(true) ---");
        token.setSwapAndLiquifyEnabled(true);
        console.log("--- AFTER: setSwapAndLiquifyEnabled(true) ---");
        bool afterEnable = token.swapAndLiquifyEnabled();
        console.log("New swapAndLiquifyEnabled: ", afterEnable);
        if (afterEnable != true) {
            console.log("FAIL: Should be true after enabling");
            allPassed = false;
        }

        vm.stopPrank();

        // Final vulnerability verdict
        if (allPassed) {
            console.log("\nVulnerability Exists: Owner successfully modified all protected state variables");
        } else {
            console.log("\nVulnerability not Exist: One or more state changes failed");
        }
    }
}