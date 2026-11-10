// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/zpet_1.sol";

contract ZeusPetFeeTest is Test {
    ZeusPet token;
    address owner = address(0x1);
    address marketingWallet = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new ZeusPet(10, 10, marketingWallet);
        vm.stopPrank();
    }

    function testFeeComparison() public {
        // Abnormal behavior - fees exceed limit (30% each)
        vm.prank(owner);
        token.setFeePercent(30, 30);
    }
}