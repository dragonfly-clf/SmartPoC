// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TAG.sol";

contract TagBlacklistTest is Test {
    TAG tag;
    address admin = address(0x1);
    address user = address(0x2);
    address[] addressesToBlacklist;

    function setUp() public {
        vm.startPrank(admin);
        tag = new TAG();
        addressesToBlacklist = new address[](1);
        addressesToBlacklist[0] = user;
        vm.stopPrank();
    }

    function testAddToBlacklistFails() public {
        console.log("--- BEFORE-Trigger Blacklist Status ---");
        // Verify and log initial blacklist status
        bool initialBlacklistStatus = tag.isBlacklisted(user);
        console.log("User blacklist status BEFORE addToBlackList: ", initialBlacklistStatus ? "Blacklisted" : "Not Blacklisted");
        assertFalse(initialBlacklistStatus);

        console.log("--- Trigger addToBlackList ---");
        // Attempt to blacklist user
        vm.prank(admin);
        tag.addToBlackList(addressesToBlacklist);

        console.log("--- AFTER-Trigger Blacklist Status ---");
        // Verify and log post-operation blacklist status
        bool finalBlacklistStatus = tag.isBlacklisted(user);
        console.log("User blacklist status AFTER addToBlackList: ", finalBlacklistStatus ? "Blacklisted" : "Not Blacklisted");

        // Differential comparison verdict
        if (finalBlacklistStatus == initialBlacklistStatus) {
            console.log("Vulnerability Exists: User's blacklist status did not change despite admin action");
        } else {
            console.log("Vulnerability not Exist: User's blacklist status changed as expected");
        }

        // Final vulnerability verdict
        if (finalBlacklistStatus) {
            console.log("Vulnerability not Exist: The user was successfully blacklisted");
        } else {
            console.log("Vulnerability Exists: The user was not blacklisted due to vulnerability");
        }
    }
}