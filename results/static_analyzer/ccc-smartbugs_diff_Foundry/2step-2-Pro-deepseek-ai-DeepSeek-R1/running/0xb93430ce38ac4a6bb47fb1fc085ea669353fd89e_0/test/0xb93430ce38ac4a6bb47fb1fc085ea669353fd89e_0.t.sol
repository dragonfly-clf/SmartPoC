// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

contract TimestampManipulationTest is Test {
    PrivateBank privateBank;
    Log logContract;
    address user = vm.addr(1);

    function setUp() public {
        vm.deal(user, 100 ether);
        logContract = new Log();
        privateBank = new PrivateBank(address(logContract));
    }

    function test_timestampManipulation() public {
        vm.startPrank(user);
        uint256 amount1 = 1 ether;
        uint256 amount2 = 2 ether;
        uint256 timestamp1 = 1000;
        uint256 timestamp2 = 2000;

        console.log("--- BEFORE-Trigger (First Deposit) ---");
        console.log("User balance: %s ETH", user.balance / 1e18);

        console.log("--- Trigger: First Deposit ---");
        vm.warp(timestamp1);
        privateBank.Deposit{value: amount1}();

        console.log("--- AFTER-Trigger (First Deposit) ---");
        (address sender0, string memory data0, uint256 u1_0, uint256 u2_0) = logContract.History(0);
        console.log("Log[0] - sender: ", sender0);
        console.log("Log[0] - data: ", data0);
        console.log("Log[0] - u1: ", u1_0);
        console.log("Log[0] - u2: ", u2_0);

        console.log("--- BEFORE-Trigger (Second Deposit) ---");
        console.log("User balance: %s ETH", user.balance / 1e18);

        console.log("--- Trigger: Second Deposit ---");
        vm.warp(timestamp2);
        privateBank.Deposit{value: amount2}();
        vm.stopPrank();

        console.log("--- AFTER-Trigger (Second Deposit) ---");
        (address sender1, string memory data1, uint256 u1_1, uint256 u2_1) = logContract.History(1);
        console.log("Log[1] - sender: ", sender1);
        console.log("Log[1] - data: ", data1);
        console.log("Log[1] - u1: ", u1_1);
        console.log("Log[1] - u2: ", u2_1);

        bool vulnerabilityConfirmed = true;
        string memory reason;

        // Validate first deposit record
        if (sender0 != user) {
            vulnerabilityConfirmed = false;
            reason = "First deposit: sender does not match user";
        } else if (keccak256(abi.encodePacked(data0)) != keccak256(abi.encodePacked("Deposit"))) {
            vulnerabilityConfirmed = false;
            reason = "First deposit: unexpected log data";
        } else if (u1_0 != timestamp1 && u2_0 != timestamp1) {
            vulnerabilityConfirmed = false;
            reason = "First deposit: timestamp not recorded";
        } else if (u1_0 != amount1 && u2_0 != amount1) {
            vulnerabilityConfirmed = false;
            reason = "First deposit: amount value not recorded";
        }

        // Validate second deposit if first passed
        if (vulnerabilityConfirmed) {
            if (sender1 != user) {
                vulnerabilityConfirmed = false;
                reason = "Second deposit: sender does not match user";
            } else if (keccak256(abi.encodePacked(data1)) != keccak256(abi.encodePacked("Deposit"))) {
                vulnerabilityConfirmed = false;
                reason = "Second deposit: unexpected log data";
            } else if (u1_1 != timestamp2 && u2_1 != timestamp2) {
                vulnerabilityConfirmed = false;
                reason = "Second deposit: timestamp not recorded";
            } else if (u1_1 != amount2 && u2_1 != amount2) {
                vulnerabilityConfirmed = false;
                reason = "Second deposit: amount value not recorded";
            }
        }

        // Final verdict
        if (vulnerabilityConfirmed) {
            console.log("Vulnerability Exists: Malicious timestamps recorded in logs");
        } else {
            console.log("Vulnerability not Exist: %s", reason);
        }
    }
}