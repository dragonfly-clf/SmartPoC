// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract BlackListTest is Test {
    DEXI public token;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.startPrank(owner);
        token = new DEXI();
        vm.stopPrank();
    }

    function test_ownerCanBlacklistAddresses() public {
        console.log("--- BEFORE-Trigger Blacklist Status ---");
        bool preStatus = token._isBlacklisted(user);
        console.log("Pre-trigger status: User blacklisted?", preStatus);

        // Create an array with a test address
        address[] memory addresses = new address[](1);
        addresses[0] = user;

        console.log("--- Trigger addToBlackList ---");
        // Call the function by the owner to blacklist the test address
        vm.prank(owner);
        token.addToBlackList(addresses);

        console.log("--- AFTER-Trigger Blacklist Status ---");
        bool postStatus = token._isBlacklisted(user);
        console.log("Post-trigger status: User blacklisted?", postStatus);
        
        if (preStatus == false && postStatus == true) {
            console.log("Vulnerability Exists: Owner successfully changed blacklist status");
        } else {
            console.log("Vulnerability not Exist: Blacklist status unchanged");
        }
    }
}