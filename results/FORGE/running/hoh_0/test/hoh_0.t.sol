// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HoldingHands.sol";

contract HoldingHandsTest is Test {
    HoldingHands public token;
    address owner = address(0x1234);

    // Router address from HoldingHands constructor
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // Mock addresses
    address mockFactory = address(0x222);
    address mockWETH = address(0x111);
    address mockPair = address(0x333);

    function setUp() public {
        vm.startPrank(owner);

        // Mock router factory()
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        // Mock router WETH()
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        // Mock factory createPair()
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        token = new HoldingHands();
        vm.stopPrank();
    }

    function testTaxFeeManipulation() public {
        uint256 excessiveFee = 26; // More than alleged 25% limit

        console.log("--- BEFORE-Trigger ---");
        console.log("State: N/A (_taxFee is private)");

        console.log("--- Trigger setTaxFeePercent ---");
        bool success26;
        bool success100;
        vm.startPrank(owner);
        (success26, ) = address(token).call(abi.encodeWithSignature("setTaxFeePercent(uint256)", excessiveFee));
        (success100, ) = address(token).call(abi.encodeWithSignature("setTaxFeePercent(uint256)", 100));
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        console.log("State: N/A (_taxFee is private)");

        if (success26 && success100) {
            console.log("Vulnerability Exists: setTaxFeePercent accepted values beyond 25% without reverting");
        } else {
            console.log("Vulnerability not Exist: Setting fee beyond 25% reverted");
        }
    }
}