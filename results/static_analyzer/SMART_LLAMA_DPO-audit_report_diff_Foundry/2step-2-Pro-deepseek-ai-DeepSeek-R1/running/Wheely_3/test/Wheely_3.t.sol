// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyTest is Test {
    Wheely public token;
    address payable owner = payable(address(0x1));
    address payable user = payable(address(0x2));
    address payable zeroAddress = payable(address(0));

    function setUp() public {
        vm.startPrank(owner);
        token = new Wheely(
            "WheelyToken", 
            "WHLY", 
            18, 
            1000000, 
            address(0x3)
        );
        token.transfer(user, 1000 * 10**18);
        vm.stopPrank();
    }

    function testTransferToZeroAddress() public {
        // 验证用户向零地址转账会回退
        vm.prank(user);
        vm.expectRevert("BEP20: transfer to the zero address");
        token.transfer(zeroAddress, 100);
        console.log("Vulnerability not Exist: transfer to zero address reverted successfully");
    }

    function testTransferFromToZeroAddress() public {
        // 批准测试合约操作代币
        vm.prank(user);
        token.approve(address(this), 1000 * 10**18);

        // 验证从用户向零地址代转账会回退
        vm.expectRevert("BEP20: transfer to the zero address");
        token.transferFrom(user, zeroAddress, 100);
        console.log("Vulnerability not Exist: transferFrom to zero address reverted successfully");
    }
}