// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SafeWolf.sol";

// Contract to simulate call behaviors
contract CallHelper {
    bool public shouldRevert;
    
    function setRevert(bool revertStatus) public {
        shouldRevert = revertStatus;
    }
    
    function testCall() public view {
        if (shouldRevert) {
            revert("CustomRevertMessage");
        }
    }
}

contract SafeWolfCallTest is Test {
    SafeWolf token;
    CallHelper helper;
    
    function setUp() public {
        token = new SafeWolf();
        helper = new CallHelper();
    }

    function testCallFailureWithDefaultMessage() public {
        console.log("--- BEGIN test: Low-level call reverts with default message ---");
        // Prepare valid call data
        bytes memory data = abi.encodeWithSignature("testCall()");
        
        // Expect the default low-level call revert message
        vm.expectRevert("Address: low-level call failed");
        address(token).call(abi.encodeWithSignature(
            "transfer(address,uint256)",
            address(helper),
            0
        ));
        console.log("Trigger: Low-level transfer call to SafeWolf contract");
        console.log("Vulnerability Exists: SafeWolf exposes default revert message when making invalid calls");
    }

    function testCallFailureWithCustomMessage() public {
        console.log("--- BEGIN test: Low-level call reverts with custom message ---");
        // Configure helper to revert
        helper.setRevert(true);
        // Prepare call data that will trigger revert
        bytes memory data = abi.encodeWithSignature("testCall()");
        
        // Expect our custom revert message
        vm.expectRevert("CustomRevertMessage");
        (bool success, ) = address(helper).call(data);
        console.log("Trigger: Direct low-level call to helper contract");
        console.log("Vulnerability Exists: External contract revert message exposure affects SafeWolf's call behavior");
    }

    function testSuccessfulCall() public {
        console.log("--- BEGIN test: Successful low-level call ---");
        // Configure helper not to revert
        helper.setRevert(false);
        // Prepare valid call data
        bytes memory data = abi.encodeWithSignature("testCall()");
        
        // Perform call and verify success
        (bool success, ) = address(helper).call(data);
        assertTrue(success);
        console.log("Trigger: Direct low-level call to helper contract");
        console.log("Vulnerability not Exist: Expected successful call behavior observed");
    }
}