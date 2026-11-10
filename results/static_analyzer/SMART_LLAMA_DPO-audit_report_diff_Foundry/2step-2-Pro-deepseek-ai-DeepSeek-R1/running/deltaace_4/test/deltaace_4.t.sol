// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/deltaace.sol";

contract DeltaAcePrivilegeTest is Test {
    deltaace public token;
    address public owner = makeAddr("owner");
    address public hacker = makeAddr("hacker");
    address public deadAddress = makeAddr("deadAddress");

    function setUp() public {
        // Set up Uniswap mock addresses
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address factoryAddress = makeAddr("factory");
        address wethAddress = makeAddr("weth");
        address pairAddress = makeAddr("pair");

        // Mock router function calls
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddress)
        );
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(wethAddress)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            factoryAddress,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddress)
        );

        // Deploy contract with mock dependencies
        vm.prank(owner);
        token = new deltaace();
    }

    // Test: Owner can set swap tokens threshold to unreasonably high value
    function testSwapThresholdDrain() public {
        console.log("--- BEFORE-Trigger SetSwapTokensAtAmount ---");
        uint256 preThreshold = token.swapTokensAtAmount();
        bool preMarketing = token.marketingEnabled();
        bool preDividend = token.busdDividendEnabled();
        bool preLiquify = token.swapAndLiquifyEnabled();
        console.log("SwapThreshold Before:", preThreshold);
        console.log("MarketingEnabled Before:", preMarketing);
        console.log("BusdDividendEnabled Before:", preDividend);
        console.log("LiquifyEnabled Before:", preLiquify);
        
        console.log("--- Trigger SetSwapTokensAtAmount ---");
        // Set absolute cap for what's considered unreasonable (1 billion tokens)
        uint256 reasonableLimit = 1_000_000_000 * (10**18);
        uint256 insaneAmount = 1_000_000_001;
        vm.prank(owner);
        token.setSwapTokensAtAmount(insaneAmount);

        console.log("--- AFTER-Trigger SetSwapTokensAtAmount ---");
        uint256 postThreshold = token.swapTokensAtAmount();
        bool postMarketing = token.marketingEnabled();
        bool postDividend = token.busdDividendEnabled();
        bool postLiquify = token.swapAndLiquifyEnabled();
        console.log("SwapThreshold After:", postThreshold);
        console.log("MarketingEnabled After:", postMarketing);
        console.log("BusdDividendEnabled After:", postDividend);
        console.log("LiquifyEnabled After:", postLiquify);

        // Verify state changes
        bool thresholdChanged = (postThreshold != preThreshold);
        bool marketingUnchanged = (postMarketing == preMarketing);
        bool dividendUnchanged = (postDividend == preDividend);
        bool liquifyUnchanged = (postLiquify == preLiquify);
        
        // Final verdict with vulnerability condition
        if (thresholdChanged && marketingUnchanged && dividendUnchanged && liquifyUnchanged) {
            console.log("Vulnerability Exists: Owner modified swap threshold without affecting other features");
        } else if (!thresholdChanged) {
            console.log("Vulnerability not Exist: Swap threshold not modified by owner call");
        } else {
            console.log("Vulnerability not Exist: Unexpected side-effect observed during state change");
        }
    }

    // Test: Non-owner cannot exploit critical contract functions
    function testNonOwnerReverts() public {
        vm.startPrank(hacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapTokensAtAmount(100);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setBusdDividendEnabled(false);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingEnabled(false);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapAndLiquifyEnabled(false);
        vm.stopPrank();
        console.log("Vulnerability not Exist: Non-owner calls reverted as expected");
    }

    // Test: Owner can disable critical contract features arbitrarily
    function testCriticalFunctionDisabling() public {
        console.log("--- BEFORE-Trigger DisableFeatures ---");
        bool preMarketing = token.marketingEnabled();
        bool preDividend = token.busdDividendEnabled();
        bool preLiquify = token.swapAndLiquifyEnabled();
        console.log("MarketingEnabled Before:", preMarketing);
        console.log("BusdDividendEnabled Before:", preDividend);
        console.log("LiquifyEnabled Before:", preLiquify);
        
        console.log("--- Trigger DisableFeatures ---");
        vm.startPrank(owner);
        token.setMarketingEnabled(false);
        token.setBusdDividendEnabled(false);
        token.setSwapAndLiquifyEnabled(false);
        vm.stopPrank();

        console.log("--- AFTER-Trigger DisableFeatures ---");
        bool postMarketing = token.marketingEnabled();
        bool postDividend = token.busdDividendEnabled();
        bool postLiquify = token.swapAndLiquifyEnabled();
        console.log("MarketingEnabled After:", postMarketing);
        console.log("BusdDividendEnabled After:", postDividend);
        console.log("LiquifyEnabled After:", postLiquify);

        // Verify state changes
        bool marketingDisabled = (!postMarketing && preMarketing);
        bool dividendDisabled = (!postDividend && preDividend);
        bool liquifyDisabled = (!postLiquify && preLiquify);
        
        // Final vulnerability verdict
        if (marketingDisabled && dividendDisabled && liquifyDisabled) {
            console.log("Vulnerability Exists: Owner disabled all critical contract features");
        } else {
            console.log("Vulnerability not Exist: Some features not disabled during state change");
        }
    }
}