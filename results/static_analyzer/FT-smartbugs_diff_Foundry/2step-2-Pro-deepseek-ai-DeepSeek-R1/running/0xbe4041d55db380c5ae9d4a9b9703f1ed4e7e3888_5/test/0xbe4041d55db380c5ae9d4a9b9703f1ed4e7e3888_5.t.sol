// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract MoneyBoxTest is Test {
    MONEY_BOX moneyBox;
    Log logContract;
    address testUser = makeAddr("testUser");

    function setUp() public {
        moneyBox = new MONEY_BOX();
        logContract = new Log();
        vm.deal(testUser, 1 ether);
    }

    // Test that Put operations revert when LogFile is not initialized
    function testPutFailsWithoutLogFile() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("Operation: Attempt Put without initializing LogFile");
        console.log("Expected: transaction should revert");

        console.log("--- Trigger Operation ---");
        console.log("Calling Put() with 0.5 ether...");
        vm.prank(testUser);
        vm.expectRevert();
        moneyBox.Put{value: 0.5 ether}(0);

        console.log("--- AFTER-Trigger Result ---");
        console.log("Outcome: Put operation successfully reverted");
        console.log("Vulnerability Exists: Put fails without LogFile initialization");
    }

    // Test that Collect operations revert when LogFile is reset to uninitialized state
    function testCollectFailsWithoutLogFile() public {
        // Proper initialization sequence
        moneyBox.SetLogFile(address(logContract));
        vm.prank(testUser);
        moneyBox.Put{value: 0.5 ether}(0);
        vm.warp(block.timestamp + 1);  // Advance to unlock time
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Operation: Reset LogFile then attempt Collect");
        console.log("Expected: Collect operation should revert");

        console.log("--- Trigger Operation #1 ---");
        console.log("Resetting LogFile to address(0)");
        moneyBox.SetLogFile(address(0));  // Vulnerability trigger

        console.log("--- Trigger Operation #2 ---");
        console.log("Calling Collect(0.5 ether)...");
        vm.prank(testUser);
        vm.expectRevert();
        moneyBox.Collect(0.5 ether);

        console.log("--- AFTER-Trigger Result ---");
        console.log("Outcome: Collect operation successfully reverted");
        console.log("Vulnerability Exists: Collect fails after LogFile reset");
    }
}