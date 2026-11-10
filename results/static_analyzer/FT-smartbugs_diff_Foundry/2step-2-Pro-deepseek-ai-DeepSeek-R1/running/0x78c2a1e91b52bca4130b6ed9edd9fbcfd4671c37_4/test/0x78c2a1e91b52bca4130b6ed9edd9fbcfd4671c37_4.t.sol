// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x78c2a1e91b52bca4130b6ed9edd9fbcfd4671c37.sol";

contract MaliciousTarget {
    bool public wasCalled;
    uint public valueReceived;

    function setCalled() external payable {
        wasCalled = true;
        valueReceived = msg.value;
    }
}

contract WhaleGiveawayTest is Test {
    WhaleGiveaway1 public whaleContract;
    MaliciousTarget public maliciousTarget;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        whaleContract = new WhaleGiveaway1();
        
        maliciousTarget = new MaliciousTarget();
        vm.deal(address(whaleContract), 10 ether);
        vm.deal(attacker, 1 ether);
    }

    function test_Command_access_by_owner() public {
        vm.prank(owner);
        
        bytes memory data = abi.encodeWithSelector(
            MaliciousTarget.setCalled.selector
        );
        
        // Owner executes command as intended
        whaleContract.Command{value: 1 ether}(address(maliciousTarget), data);
        
        // Verify successful execution
        assertTrue(maliciousTarget.wasCalled(), "Owner command failed");
        assertEq(maliciousTarget.valueReceived(), 1 ether, "ETH transfer failed");
    }

    function test_Command_access_by_non_owner() public {
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger ---");
        bool preWasCalled = maliciousTarget.wasCalled();
        uint preBalance = address(maliciousTarget).balance;
        console.log("Pre-trigger wasCalled:", preWasCalled);
        console.log("Pre-trigger ETH balance:", preBalance);
        
        // Trigger action
        console.log("--- Trigger CALL ---");
        vm.prank(attacker);
        bytes memory data = abi.encodeWithSelector(
            MaliciousTarget.setCalled.selector
        );
        
        // Attempt exploit
        vm.expectRevert();
        whaleContract.Command{value: 1 ether}(address(maliciousTarget), data);
        
        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger ---");
        bool postWasCalled = maliciousTarget.wasCalled();
        uint postBalance = address(maliciousTarget).balance;
        console.log("Post-trigger wasCalled:", postWasCalled);
        console.log("Post-trigger ETH balance:", postBalance);
        
        // Vulnerability verification
        bool stateChanged = (postWasCalled != preWasCalled) || (postBalance != preBalance);
        if (stateChanged) {
            console.log("Vulnerability Exists: Non-owner call altered target contract state");
        } else {
            console.log("Vulnerability not Exist: Non-owner call couldn't modify target state");
        }

        // Original verifications
        assertFalse(maliciousTarget.wasCalled(), "Access control failed");
        assertEq(address(maliciousTarget).balance, 0, "ETH improperly transferred");
    }
}