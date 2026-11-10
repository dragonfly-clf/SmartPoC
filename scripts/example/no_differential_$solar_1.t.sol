// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/$solar_1.sol";

contract SOLIUMRISEFeeTest is Test {
    SOLIUMRISE token;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        token = new SOLIUMRISE();
        token.tradingStatus(true);
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        // Owner sets fees to maximum allowed (<50%)
        vm.prank(owner);
        token.setFees(10, 10, 10, 10, 5, 4, 100);

        // Owner sets sell multiplier to high value
        vm.prank(owner);
        token.set_sell_multiplier(1000);
    }
}