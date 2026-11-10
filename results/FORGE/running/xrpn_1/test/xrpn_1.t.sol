// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/XRPNATION.sol";

contract XRPNATIONFeeTest is Test {
    XRPNATION token;
    address owner = address(0x1);

    // Hardcoded addresses from contract
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address factory = address(0xFAC70);
    address pair = address(0x1234);

    function setUp() public {
        // Mock all required router and factory calls
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(factory)
        );
        vm.mockCall(
            factory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pair)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WBNB)
        );
        
        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new XRPNATION();
        token.tradingStatus(true);
        vm.stopPrank();
    }

    function testSellFeeExceedsLimit() public {
        // Set total fees to 26% (exceeds 25% max limit)
        uint256 liquidityFee = 8; 
        uint256 reflectionFee = 7;
        uint256 marketingFee = 6;
        uint256 DevFee = 5;
        uint256 totalFee = liquidityFee + reflectionFee + marketingFee + DevFee;

        console.log("--- BEFORE-Trigger SelltotalFee ---");
        uint256 preSellTotalFee = token.SelltotalFee();
        console.log("Initial Sell Fee (%):", preSellTotalFee);

        // Owner sets excessive fees (vulnerability trigger)
        console.log("--- Trigger: setSellFees(26%) ---");
        vm.prank(owner);
        token.setSellFees(liquidityFee, reflectionFee, marketingFee, DevFee);

        console.log("--- AFTER-Trigger SelltotalFee ---");
        uint256 postSellTotalFee = token.SelltotalFee();
        console.log("Updated Sell Fee (%):", postSellTotalFee);

        // Validate state change
        bool feeChanged = preSellTotalFee != postSellTotalFee;
        bool exceedsLimit = postSellTotalFee > 25;
        console.log("Fee changed?:", feeChanged ? "YES" : "NO");
        console.log("Exceeds 25% limit?:", exceedsLimit ? "YES" : "NO");

        // Final vulnerability verdict
        if (exceedsLimit) {
            console.log("Vulnerability Exists: Fee successfully set to %d%% (exceeds 25%% max)", postSellTotalFee);
        } else {
            console.log("Vulnerability not Exist: Fee (%d%%) within 25%% limit", postSellTotalFee);
        }
    }
}