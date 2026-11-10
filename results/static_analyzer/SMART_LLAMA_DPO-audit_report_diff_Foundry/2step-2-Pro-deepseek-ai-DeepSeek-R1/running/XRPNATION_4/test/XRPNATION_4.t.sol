// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/XRPNATION.sol";

contract PrivilegeEscalationTest is Test {
    XRPNATION token;
    address owner = address(0x10000);
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address fakeFactory = address(0xFAC700);
    address fakePair = address(0xFA1E5001);

    function setUp() public {
        // Compute token address before deployment
        uint256 nonce = vm.getNonce(owner);
        address predictedTokenAddr = vm.computeCreateAddress(owner, nonce);

        // Setup router factory mock
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(fakeFactory)
        );

        // Setup createPair mock with predicted address
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSignature("createPair(address,address)", WBNB, predictedTokenAddr),
            abi.encode(fakePair)
        );

        // Deploy token as owner without constructor arguments
        vm.startPrank(owner);
        token = new XRPNATION();
        token.tradingStatus(true);
        vm.stopPrank();
    }

    function testPrivilegeEscalation() public {
        uint256 totalSupply = token.totalSupply();
        uint256 dangerousPercentage = 1000; // 1000/1000 = 100%
        
        console.log("--- BEFORE-Trigger Privilege Escalation ---");
        uint256 maxBuyBefore = token.checkMaxBuyTxAmount();
        uint256 maxWalletBefore = token.checkMaxWalletToken();
        uint256 maxSellBefore = token.checkMaxSellTxAmount();
        uint256 swapThresholdBefore = token.checkSwapThreshold();
        
        console.log("Initial Max Buy Limit:     ", maxBuyBefore);
        console.log("Initial Wallet Limit:      ", maxWalletBefore);
        console.log("Initial Max Sell Limit:    ", maxSellBefore);
        console.log("Initial Swap Threshold:    ", swapThresholdBefore);

        console.log("--- Trigger Privilege Escalation ---");
        vm.startPrank(owner);
        // Perform privilege escalations
        token.setMaxBuyTxPercent_base1000(dangerousPercentage);
        token.setMaxWalletPercent_base1000(dangerousPercentage);
        token.setMaxSellTxPercent_base1000(dangerousPercentage);
        token.setSwapBackSettings(true, 5000, 10000);
        vm.stopPrank();
        console.log("Owner set parameters to dangerous levels");

        console.log("--- AFTER-Trigger Privilege Escalation ---");
        console.log("Updated Max Buy Limit:     ", token.checkMaxBuyTxAmount());
        console.log("Updated Wallet Limit:      ", token.checkMaxWalletToken());
        console.log("Updated Max Sell Limit:    ", token.checkMaxSellTxAmount());
        console.log("Updated Swap Threshold:    ", token.checkSwapThreshold());

        // Verify privilege escalations
        assertEq(token.checkMaxBuyTxAmount(), totalSupply, "Max buy limit set to 100%");
        assertEq(token.checkMaxWalletToken(), totalSupply, "Wallet limit set to 100%");
        assertEq(token.checkMaxSellTxAmount(), totalSupply, "Sell limit set to 100%");
        assertEq(token.checkSwapThreshold(), totalSupply * 5000 / 10000, "Swap threshold set to 50%");
    }
}