// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract TimestampManipulationTest is Test {
    PrivateDeposit privateDeposit;
    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        privateDeposit = new PrivateDeposit();
        vm.stopPrank();
        vm.deal(user, 1 ether);
    }

    function test_TimestampManipulation() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 initialTimestamp = block.timestamp;
        console.log("Initial timestamp:", initialTimestamp);

        console.log("--- Trigger Warp and Deposit ---");
        uint256 manipulatedTimestamp = initialTimestamp + 1 hours;
        vm.warp(manipulatedTimestamp);

        bool depositSuccess;
        vm.prank(user);
        try privateDeposit.Deposit{value: 1 ether}() {
            depositSuccess = true;
        } catch Error(string memory reason) {
            depositSuccess = false;
            console.log("Deposit reverted:", reason);
        } catch (bytes memory) {
            depositSuccess = false;
            console.log("Deposit reverted without reason");
        }

        console.log("--- AFTER-Trigger ---");
        console.log("Current timestamp:", block.timestamp);
        console.log("Deposit success:", depositSuccess ? "true" : "false");

        // Vulnerability verification logic
        if (depositSuccess && block.timestamp == manipulatedTimestamp) {
            console.log("Vulnerability Exists: Deposit executed successfully at the manipulated timestamp");
        } else {
            console.log("Vulnerability not Exist: Deposit failed or timestamp manipulation did not occur");
        }
    }
}