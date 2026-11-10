// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x78c2a1e91b52bca4130b6ed9edd9fbcfd4671c37.sol";

contract FailingContract {
    fallback() external payable {
        revert("FailingContract: always failing");
    }
}

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 public giveaway;
    FailingContract public failingContract;

    function setUp() public {
        giveaway = new WhaleGiveaway1();
        failingContract = new FailingContract();
    }

    function testUncheckedCall() public {
        // Ensure test contract has enough ETH
        vm.deal(address(this), 1 ether);

        console.log("--- BEFORE-Trigger Balances ---");
        // 记录初始余额
        uint initialGiveawayBalance = address(giveaway).balance;
        uint initialFailingBalance = address(failingContract).balance;
        console.log("WhaleGiveaway1 initial balance:", initialGiveawayBalance);
        console.log("FailingContract initial balance:", initialFailingBalance);

        console.log("--- Trigger ExecuteCommand ---");
        // 执行对失败合约的调用
        (bool success, ) = address(giveaway).call{value: 1 ether}(
            abi.encodeWithSelector(
                giveaway.Command.selector,
                address(failingContract),
                ""
            )
        );
        console.log("Call status:", success ? "Success" : "Reverted");

        console.log("--- AFTER-Trigger Balances ---");
        // 记录调用后余额
        uint postGiveawayBalance = address(giveaway).balance;
        uint postFailingBalance = address(failingContract).balance;
        console.log("WhaleGiveaway1 post balance:", postGiveawayBalance);
        console.log("FailingContract post balance:", postFailingBalance);

        // 比较余额变化
        bool fundsRemained = (postGiveawayBalance == initialGiveawayBalance + 1 ether) &&
                            (postFailingBalance == initialFailingBalance);

        console.log("--- Result Verification ---");
        console.log("1 ETH remained in WhaleGiveaway1:", (postGiveawayBalance - initialGiveawayBalance) == 1 ether);
        console.log("FailingContract unchanged:", postFailingBalance == initialFailingBalance);

        // 最终漏洞判断
        if (success && fundsRemained) {
            console.log("Vulnerability Exists: ETH remained in WhaleGiveaway1 after failed call");
        } else {
            console.log("Vulnerability not Exist: Transaction reverted or funds not retained");
        }

        // 原始断言保留
        assertTrue(success, "Call to Command should not revert");
        assertEq(
            address(failingContract).balance,
            initialFailingBalance,
            "FailingContract should not receive ETH"
        );
        assertEq(
            address(giveaway).balance,
            initialGiveawayBalance + 1 ether,
            "ETH should remain in WhaleGiveaway1"
        );
    }
}