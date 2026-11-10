// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract OwnerChangeTest is Test {
    TokenSender public tokenSender;
    address public deployer = address(0x1);
    address public newOwner = address(0x2);
    address public zeroAddress = address(0);
    address public mockToken = address(0x123); // Mock token address

    function setUp() public {
        vm.prank(deployer);
        tokenSender = new TokenSender(mockToken); // Pass mock token address
    }

    function testCanChangeOwnerToZeroAddress() public {
        console2.log("--- BEFORE-Trigger Owner ---");
        address ownerBefore = tokenSender.owner();
        console2.log("Owner contract: %s", address(tokenSender));
        console2.log("Owner before:   %s (Deployer: %s)", ownerBefore, deployer);
        assertEq(ownerBefore, deployer, "Initial owner should be deployer");

        console2.log("\n--- Trigger ChangeOwner to ZeroAddress ---");
        vm.prank(deployer);
        tokenSender.changeOwner(zeroAddress);
        console2.log("Called: changeOwner(%s)", zeroAddress);

        console2.log("\n--- AFTER-Trigger Owner ---");
        address ownerAfter = tokenSender.owner();
        console2.log("Owner after:    %s (Zero: %s)", ownerAfter, zeroAddress);

        console2.log("\n--- Verdict ---");
        if (ownerAfter == zeroAddress) {
            console2.log("Vulnerability Exists: Owner successfully changed to zero address");
        } else {
            console2.log("Vulnerability not Exist: changeOwner rejected zero address");
        }
        
        assertEq(ownerAfter, zeroAddress, "Vulnerability not exploited: Owner is not zero address");
    }
}