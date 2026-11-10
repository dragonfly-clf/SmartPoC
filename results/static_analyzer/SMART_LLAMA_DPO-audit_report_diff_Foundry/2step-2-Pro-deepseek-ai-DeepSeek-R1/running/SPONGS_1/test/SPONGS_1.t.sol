// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPONGS.sol";

contract RewardTokenEventTest is Test {
    SPONGSDividendTracker public dividendTracker;
    address public user = address(0x123);
    address public rewardToken = address(0x456); 
    address public ammContract = address(0x789);

    function setUp() public {
        dividendTracker = new SPONGSDividendTracker();
    }

    function test_setRewardToken_EmitsNoEvent() public {
        // 記錄調用前的狀態：預計事件數量為0
        console.log("--- BEFORE-Trigger Event Check ---");
        console.log("Expected event count: 0");
        
        console.log("--- Trigger setRewardToken ---");
        // 記錄調用日誌
        vm.recordLogs();
        dividendTracker.setRewardToken(user, rewardToken, ammContract);
        
        console.log("--- AFTER-Trigger Event Check ---");
        // 驗證未發出任何事件
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log("Actual event count:", entries.length);
        
        // 根據事件數量輸出漏洞是否存在
        if (entries.length == 0) {
            console.log("Vulnerability Exists: setRewardToken did not emit an event as required");
        } else {
            console.log("Vulnerability not Exist: setRewardToken emitted events");
        }
        assertEq(entries.length, 0, "Events emitted by setRewardToken");
    }
}