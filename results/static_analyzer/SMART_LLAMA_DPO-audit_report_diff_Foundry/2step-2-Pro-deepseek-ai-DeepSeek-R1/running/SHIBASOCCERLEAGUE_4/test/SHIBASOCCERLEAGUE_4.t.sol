// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBASOCCERLEAGUE.sol";

contract PrivilegeEscalationTest is Test {
    SHIBASOCCERLEAGUE token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Setup mock addresses
        address mockWETH = address(0xdead);
        address mockFactory = address(0xbeef);
        address mockPair = address(0xabcdef);
        
        // Mock router.WETH() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock router.factory() call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock factory.createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        vm.prank(owner);
        token = new SHIBASOCCERLEAGUE();
    }

    function testParameterManipulation() public {
        // Record initial state before any changes
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialTotalFee = token.totalFee();
        bool initialSwapEnabled = token.swapEnabled();
        uint256 initialSwapThreshold = token.swapThreshold();
        uint256 initialMaxWalletToken = token._maxWalletToken();
        uint256 initialMaxTxAmount = token._maxTxAmount();
        address initialMarketingFeeReceiver = token.marketingFeeReceiver();
        address initialTeamFeeReceiver = token.teamFeeReceiver();
        uint256 totalSupply = token.totalSupply();
        
        console.log("Initial totalFee:", initialTotalFee);
        console.log("Initial swapEnabled:", initialSwapEnabled);
        console.log("Initial swapThreshold:", initialSwapThreshold);
        console.log("Initial maxWalletToken:", initialMaxWalletToken);
        console.log("Initial maxTxAmount:", initialMaxTxAmount);
        console.log("Initial marketingFeeReceiver:", initialMarketingFeeReceiver);
        console.log("Initial teamFeeReceiver:", initialTeamFeeReceiver);
        
        // Calculate expected final values
        uint256 expectedSwapThreshold = token.totalSupply() / 10 - 1;
        uint256 expectedMaxWalletToken = token.totalSupply();
        uint256 expectedMaxTxAmount = token.totalSupply();
        address expectedMarketingFeeReceiver = address(0x123);
        address expectedTeamFeeReceiver = address(0x456);

        console.log("--- Triggering Parameter Changes ---");
        // Temporarily set fees to 0% to avoid validation revert
        vm.prank(owner);
        token.setFees_base1000(0, 0, 0);
        
        // Set multipliers to maximum allowed values
        vm.prank(owner);
        token.setMultipliers(100, 120, 50); // Buy:10%, Sell:12%, Transfer:5%
        
        // Set base fees to maximum (10% total)
        vm.prank(owner);
        token.setFees_base1000(100, 0, 0);
        
        // Set maximum allowed swap threshold (just below 10% of total supply)
        uint256 maxThreshold = token.totalSupply() / 10 - 1;
        vm.prank(owner);
        token.setSwapBackSettings(true, maxThreshold);

        // Set max wallet and transaction limits to maximum (100%)
        vm.prank(owner);
        token.setMaxWalletPercent_base1000(1000);
        vm.prank(owner);
        token.setMaxTxPercent_base1000(1000);

        // Modify fee recipients
        vm.prank(owner);
        token.setFeeReceivers(address(0x123), address(0x456));
        
        console.log("--- AFTER-Trigger State ---");
        // Record final state after all changes
        uint256 finalTotalFee = token.totalFee();
        bool finalSwapEnabled = token.swapEnabled();
        uint256 finalSwapThreshold = token.swapThreshold();
        uint256 finalMaxWalletToken = token._maxWalletToken();
        uint256 finalMaxTxAmount = token._maxTxAmount();
        address finalMarketingFeeReceiver = token.marketingFeeReceiver();
        address finalTeamFeeReceiver = token.teamFeeReceiver();
        
        console.log("Final totalFee:", finalTotalFee);
        console.log("Final swapEnabled:", finalSwapEnabled);
        console.log("Final swapThreshold:", finalSwapThreshold);
        console.log("Final maxWalletToken:", finalMaxWalletToken);
        console.log("Final maxTxAmount:", finalMaxTxAmount);
        console.log("Final marketingFeeReceiver:", finalMarketingFeeReceiver);
        console.log("Final teamFeeReceiver:", finalTeamFeeReceiver);
        
        // Compare actual vs expected state changes
        bool vulnerable = true;
        if (finalTotalFee != 100) {
            console.log("Validation Failed: totalFee not set to 100 (expected:100, actual:%s)", finalTotalFee);
            vulnerable = false;
        }
        if (!finalSwapEnabled) {
            console.log("Validation Failed: swapEnabled not set to true");
            vulnerable = false;
        }
        if (finalSwapThreshold != expectedSwapThreshold) {
            console.log("Validation Failed: swapThreshold not set correctly (expected:%s, actual:%s)", 
                        expectedSwapThreshold, finalSwapThreshold);
            vulnerable = false;
        }
        if (finalMaxWalletToken != expectedMaxWalletToken) {
            console.log("Validation Failed: maxWalletToken not set to totalSupply (expected:%s, actual:%s)",
                        expectedMaxWalletToken, finalMaxWalletToken);
            vulnerable = false;
        }
        if (finalMaxTxAmount != expectedMaxTxAmount) {
            console.log("Validation Failed: maxTxAmount not set to totalSupply (expected:%s, actual:%s)",
                        expectedMaxTxAmount, finalMaxTxAmount);
            vulnerable = false;
        }
        if (finalMarketingFeeReceiver != expectedMarketingFeeReceiver) {
            console.log("Validation Failed: marketingFeeReceiver not changed to 0x123 (actual:%s)",
                        finalMarketingFeeReceiver);
            vulnerable = false;
        }
        if (finalTeamFeeReceiver != expectedTeamFeeReceiver) {
            console.log("Validation Failed: teamFeeReceiver not changed to 0x456 (actual:%s)",
                        finalTeamFeeReceiver);
            vulnerable = false;
        }
        
        // Final vulnerability verdict
        console.log("--- Vulnerability Validation ---");
        if (vulnerable) {
            console.log("Vulnerability Exists: Owner can bypass constraints and arbitrarily modify all protected parameters");
        } else {
            console.log("Vulnerability not Exist: Owner cannot bypass constraints for all parameters, security controls prevent full privilege escalation");
        }
    }
}