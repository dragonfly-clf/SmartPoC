// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x96edbe868531bd23a6c05e9d0c424ea64fb1b78b.sol";

contract PennyByPennyTest is Test {
    PENNY_BY_PENNY public penny;
    LogFile public dummyLog;
    address public testUser = makeAddr("testUser");

    function setUp() public {
        // Deploy contracts
        penny = new PENNY_BY_PENNY();
        dummyLog = new LogFile();
    }

    function test_Put_Revert_If_Log_Not_Set() public {
        // Fund test user with Ether
        vm.deal(testUser, 1 ether);
        
        // User tries to deposit without Log initialized
        vm.prank(testUser);
        vm.expectRevert();
        penny.Put{value: 1 ether}(0);
    }

    function test_Put_Success_After_Log_Set() public {
        // Set up log file
        penny.SetLogFile(address(dummyLog));

        // Fund test user with Ether
        vm.deal(testUser, 1 ether);
        
        // User successfully deposits after Log initialized
        vm.prank(testUser);
        penny.Put{value: 1 ether}(0);
        
        // Verify balance update
        (, uint256 balance) = penny.Acc(testUser);
        assertEq(balance, 1 ether);
    }

    // New test with differential validation
    function test_LogDependency_DifferentialCheck() public {
        // Fund user for both deposit attempts
        vm.deal(testUser, 2 ether);

        console2.log("--- BEFORE-Trigger: First Deposit (Without LogFile) ---");
        (, uint256 initialBalance) = penny.Acc(testUser);
        console2.log("Initial account balance:", initialBalance, "wei");

        console2.log("\nTrigger: First Deposit without LogFile (expect revert)");
        vm.prank(testUser);
        vm.expectRevert();
        penny.Put{value: 1 ether}(0);

        console2.log("\n--- AFTER-Trigger: First Deposit ---");
        (, uint256 balanceAfterFail) = penny.Acc(testUser);
        console2.log("Account balance after failed deposit:", balanceAfterFail, "wei");
        bool unchangedBalance = (initialBalance == balanceAfterFail);
        console2.log("Balance unchanged? %s", unchangedBalance ? "Yes" : "No");
        
        console2.log("\n--- Trigger: SetLogFile ---");
        penny.SetLogFile(address(dummyLog));

        console2.log("\n--- BEFORE-Trigger: Second Deposit (With LogFile) ---");
        // Balance should still be unchanged
        (, uint256 balanceBeforeSuccess) = penny.Acc(testUser);
        console2.log("Balance before second deposit:", balanceBeforeSuccess, "wei");
        require(
            balanceBeforeSuccess == initialBalance,
            "Balance should remain unchanged after setting LogFile"
        );

        console2.log("\nTrigger: Second Deposit with LogFile set");
        vm.prank(testUser);
        penny.Put{value: 1 ether}(0);

        console2.log("\n--- AFTER-Trigger: Second Deposit ---");
        (, uint256 balanceAfterSuccess) = penny.Acc(testUser);
        console2.log("Balance after successful deposit:", balanceAfterSuccess, "wei");
        bool increasedBalance = (balanceAfterSuccess > initialBalance);
        console2.log("Balance increased? %s", increasedBalance ? "Yes" : "No");
        
        // Final vulnerability verdict
        if (unchangedBalance && increasedBalance) {
            console2.log("\nVulnerability not Exist: LogFile dependency is enforced as expected");
        } else {
            console2.log("\nVulnerability Exists: Unexpected behavior in LogFile enforcement");
        }
    }
}