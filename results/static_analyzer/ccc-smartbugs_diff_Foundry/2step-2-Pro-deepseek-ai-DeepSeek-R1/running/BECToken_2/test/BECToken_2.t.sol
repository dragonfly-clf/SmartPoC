// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BECToken.sol";

contract BecTokenTransferTest is Test {
    BecToken token;
    address owner;
    address payer;
    address receiver;

    function setUp() public {
        owner = makeAddr("owner");
        payer = makeAddr("payer");
        receiver = makeAddr("receiver");

        vm.prank(owner);
        token = new BecToken();

        // Mint tokens to payer
        uint256 mintAmount = 1000 * 10 ** token.decimals();
        vm.prank(owner);
        token.transfer(payer, mintAmount);
    }

    function testTransferWithInvalidPadding() public {
        console2.log("--- BEFORE-Trigger Balance ---");
        // 攻击前记录余额状态
        uint256 payerBalanceBefore = token.balanceOf(payer);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);
        console2.log("Payer initial balance:", payerBalanceBefore);
        console2.log("Receiver initial balance:", receiverBalanceBefore);

        console2.log("--- Trigger Transfer ---");
        // 构造恶意payload触发漏洞
        bytes memory data = abi.encodeCall(token.transfer, (receiver, 100));
        bytes memory malformedData = bytes.concat(data, hex"12345678");    // 添加非法padding
        vm.prank(payer);
        (bool success, ) = address(token).call(malformedData);
        console2.log("Malformed call status:", success);

        console2.log("--- AFTER-Trigger Balance ---");
        // 攻击后记录余额状态
        uint256 payerBalanceAfter = token.balanceOf(payer);
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        console2.log("Payer post-transfer balance:", payerBalanceAfter);
        console2.log("Receiver post-transfer balance:", receiverBalanceAfter);

        // 计算余额变动
        uint256 payerBalanceDiff = payerBalanceBefore - payerBalanceAfter;
        uint256 receiverBalanceDiff = receiverBalanceAfter - receiverBalanceBefore;

        console2.log("Payer balance change:", payerBalanceDiff);
        console2.log("Receiver balance change:", receiverBalanceDiff);

        // 漏洞验证条件: (1)调用成功 (2)付款人余额减少100 (3)收款人余额增加100
        bool exploited = success && payerBalanceDiff == 100 && receiverBalanceDiff == 100;
        
        if (exploited) {
            console2.log("Vulnerability Exists: Malformed transfer succeeded with invalid padding and changed balances");
        } else {
            console2.log("Vulnerability not Exist: Malformed transfer failed or balances changed incorrectly");
        }
    }
}