// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/open_address_lottery.sol";

contract OpenAddressLotteryTest is Test {
    OpenAddressLottery lottery;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        lottery = new OpenAddressLottery();
        vm.stopPrank();
    }

    function testUninitializedStorageInForceReseed() public {
        console.log("--- Trigger forceReseed ---");
        try lottery.forceReseed() {
            console.log("Vulnerability Exists: forceReseed function uses uninitialized storage without reverting");
        } catch {
            console.log("Vulnerability not Exist: forceReseed function reverted");
        }
    }

    function testNonOwnerCannotForceReseed() public {
        address nonOwner = address(0x2);
        vm.prank(nonOwner);
        vm.expectRevert();
        lottery.forceReseed();
    }
}