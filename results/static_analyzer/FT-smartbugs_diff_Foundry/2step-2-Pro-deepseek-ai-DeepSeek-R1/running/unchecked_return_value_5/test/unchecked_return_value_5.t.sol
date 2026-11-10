// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/unchecked_return_value.sol";

contract AlwaysSucceed {
    fallback() external payable {}
}

contract ReturnValueTest is Test {
    ReturnValue public target;
    AlwaysSucceed public mockCallee;
    address owner = makeAddr("owner");
    address attacker = makeAddr("unauthorized");

    function setUp() public {
        vm.prank(owner);
        target = new ReturnValue();
        mockCallee = new AlwaysSucceed();
    }

    // Test unauthorized address can call callchecked
    function test_UnauthorizedCallChecked() public {
        // 查询攻击前的统计状态
        console.log("--- BEFORE-Trigger-State ---");
        (uint256 initialCalls, uint256 initialSuccessful) = target.getCallStats(address(mockCallee));
        uint256 initialTotalCalls = target.totalCalls();
        uint256 initialTotalSuccessful = target.totalSuccessfulCalls();
        console.log("Per-Address Calls:", initialCalls);
        console.log("Per-Address Successful:", initialSuccessful);
        console.log("Total Calls:", initialTotalCalls);
        console.log("Total Successful Calls:", initialTotalSuccessful);
        console.log();

        // 执行攻击操作
        console.log("--- Trigger Action: callchecked by attacker ---");
        vm.prank(attacker);
        target.callchecked(address(mockCallee));

        // 查询攻击后的统计状态
        console.log("--- AFTER-Trigger-State ---");
        (uint256 afterCalls, uint256 afterSuccessful) = target.getCallStats(address(mockCallee));
        uint256 afterTotalCalls = target.totalCalls();
        uint256 afterTotalSuccessful = target.totalSuccessfulCalls();
        console.log("Per-Address Calls:", afterCalls);
        console.log("Per-Address Successful:", afterSuccessful);
        console.log("Total Calls:", afterTotalCalls);
        console.log("Total Successful Calls:", afterTotalSuccessful);

        // 验证状态变化
        bool statsChanged = 
            (afterCalls == initialCalls + 1) &&
            (afterSuccessful == initialSuccessful + 1) &&
            (afterTotalCalls == initialTotalCalls + 1) &&
            (afterTotalSuccessful == initialTotalSuccessful + 1);
        
        // 输出最终漏洞判断
        if (statsChanged) {
            console.log("Vulnerability not Exist: State updated correctly by unauthorized call");
        } else {
            console.log("Vulnerability Exists: Unauthorized call changed state unpredictably");
        }
    }

    // Test unauthorized address can call callnotchecked
    function test_UnauthorizedCallNotChecked() public {
        // 查询攻击前的统计状态
        console.log("--- BEFORE-Trigger-State ---");
        (uint256 initialCalls, uint256 initialSuccessful) = target.getCallStats(address(mockCallee));
        uint256 initialTotalCalls = target.totalCalls();
        uint256 initialTotalSuccessful = target.totalSuccessfulCalls();
        console.log("Per-Address Calls:", initialCalls);
        console.log("Per-Address Successful:", initialSuccessful);
        console.log("Total Calls:", initialTotalCalls);
        console.log("Total Successful Calls:", initialTotalSuccessful);
        console.log();

        // 执行攻击操作
        console.log("--- Trigger Action: callnotchecked by attacker ---");
        vm.prank(attacker);
        target.callnotchecked(address(mockCallee));

        // 查询攻击后的统计状态
        console.log("--- AFTER-Trigger-State ---");
        (uint256 afterCalls, uint256 afterSuccessful) = target.getCallStats(address(mockCallee));
        uint256 afterTotalCalls = target.totalCalls();
        uint256 afterTotalSuccessful = target.totalSuccessfulCalls();
        console.log("Per-Address Calls:", afterCalls);
        console.log("Per-Address Successful:", afterSuccessful);
        console.log("Total Calls:", afterTotalCalls);
        console.log("Total Successful Calls:", afterTotalSuccessful);

        // 验证状态变化
        bool statsChanged = 
            (afterCalls == initialCalls + 1) &&
            (afterTotalCalls == initialTotalCalls + 1);
        
        // 注意：callnotchecked 漏洞是即使调用失败也会统计为成功
        // 但本次调用实际成功，所以成功次数应正常增加
        bool successStatsConsistent = 
            (afterSuccessful == initialSuccessful + 1) &&
            (afterTotalSuccessful == initialTotalSuccessful + 1);
        
        // 输出最终漏洞判断
        if (statsChanged) {
            if (successStatsConsistent) {
                console.log("Vulnerability not Exist: State updated correctly (call succeeded)");
            } else {
                console.log("Vulnerability Exists: Successful call incorrectly counted");
            }
        } else {
            console.log("Vulnerability Exists: Call counts not updated");
        }
    }
}