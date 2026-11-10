// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SportzCoin.sol";

contract SportzCoinFeeTest is Test {
    SportzCoin token;
    address owner = address(0x1);
    address mockRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockFactory = address(0x123);
    address mockWETH = address(0x456);
    address mockPair = address(0x789);

    function setUp() public {
        // Mock Uniswap router and factory calls
        vm.startPrank(owner);
        // Mock router factory() and WETH() functions
        vm.mockCall(mockRouter, abi.encodeWithSignature("factory()"), abi.encode(mockFactory));
        vm.mockCall(mockRouter, abi.encodeWithSignature("WETH()"), abi.encode(mockWETH));
        // Mock factory createPair() function
        vm.mockCall(
            mockFactory, 
            abi.encodeWithSignature("createPair(address,address)"), 
            abi.encode(mockPair)
        );
        token = new SportzCoin();
        vm.stopPrank();
    }

    function testSetFeeExceedsLimit() public {
        uint256 initialFees = token.totalFees();
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 marketingFeeBefore = token.marketingFee();
        uint256 totalFeesBefore = token.totalFees();
        console.log("Initial marketing fee: %s%", marketingFeeBefore);
        console.log("Initial total fees: %s%", totalFeesBefore);

        // Set other fees to 0 before setting high marketing fee
        console.log("--- Trigger Action: Setting Fees ---");
        vm.startPrank(owner);
        token.setBUSDRewardsFee(0);
        token.setLiquiditFee(0);
        token.setDeveloperFee(0);
        
        // Set marketing fee to 26% (exceeding 25% limit)
        token.setMarketingFee(26);
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        uint256 marketingFeeAfter = token.marketingFee();
        uint256 totalFeesAfter = token.totalFees();
        console.log("Post-attack marketing fee: %s%", marketingFeeAfter);
        console.log("Post-attack total fees: %s%", totalFeesAfter);

        console.log("--- Differential Comparison ---");
        bool marketingFeeChanged = (marketingFeeAfter != marketingFeeBefore);
        bool totalFeesChanged = (totalFeesAfter != totalFeesBefore);
        bool totalFeesExceeded = (token.totalFees() > 25);
        
        console.log("Marketing fee changed: %s", marketingFeeChanged ? "Yes" : "No");
        console.log("Total fees changed: %s", totalFeesChanged ? "Yes" : "No");
        console.log("Total fees exceeded 25%% limit: %s", totalFeesExceeded ? "Yes" : "No");

        // Final vulnerability verdict
        if (marketingFeeAfter == 26 && totalFeesExceeded) {
            console.log("Vulnerability Exists: Marketing fee set to 26%% and total fees (%s%%) exceeded 25%% limit", token.totalFees());
        } else {
            console.log("Vulnerability not Exist: Fees are within permitted limits");
        }
    }
}