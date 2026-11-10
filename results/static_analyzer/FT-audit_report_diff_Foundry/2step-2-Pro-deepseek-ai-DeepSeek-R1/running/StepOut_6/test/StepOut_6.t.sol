// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StepOut.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }

    function WETH() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract StepOutTest is Test {
    StepOut public token;
    
    address public owner = makeAddr("owner");
    address public newOwner = makeAddr("newOwner");
    address public zeroAddress = address(0);
    
    address public constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant FACTORY_ADDRESS = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(FACTORY_ADDRESS, address(mockFactory).code);
        
        vm.prank(owner);
        token = new StepOut();
    }

    function test_TransferOwnershipFailsForZeroAddress() public {
        console.log("--- BEFORE-Trigger Owner ---");
        address currentOwnerBefore = token.owner();
        console.log("Current owner before transfer:", currentOwnerBefore);
        assertEq(currentOwnerBefore, owner, "Initial owner should be setup owner");
        
        console.log("--- Trigger TransferOwnership (to zero address) ---");
        vm.prank(owner);
        vm.expectRevert("Ownable: new owner is the zero address");
        token.transferOwnership(zeroAddress);
        
        console.log("--- AFTER-Trigger Owner ---");
        address currentOwnerAfter = token.owner();
        console.log("Current owner after transfer:", currentOwnerAfter);
        
        // Vulnerability verification
        if (currentOwnerAfter == currentOwnerBefore) {
            console.log("Vulnerability not Exist: Ownership remains unchanged as expected after invalid transfer");
        } else {
            console.log("Vulnerability Exists: Ownership changed unexpectedly after invalid transfer");
        }
        
        assertEq(currentOwnerAfter, owner, "Owner should remain unchanged after failed transfer");
    }

    function test_TransferOwnershipSucceedsForValidAddress() public {
        console.log("--- BEFORE-Trigger Owner ---");
        address currentOwnerBefore = token.owner();
        console.log("Current owner before transfer:", currentOwnerBefore);
        assertEq(currentOwnerBefore, owner, "Initial owner should be setup owner");
        
        console.log("--- Trigger TransferOwnership (to newOwner) ---");
        vm.prank(owner);
        token.transferOwnership(newOwner);
        
        console.log("--- AFTER-Trigger Owner ---");
        address currentOwnerAfter = token.owner();
        console.log("Current owner after transfer:", currentOwnerAfter);
        
        // Vulnerability verification
        if (currentOwnerAfter == newOwner) {
            console.log("Vulnerability not Exist: Ownership transferred successfully as expected");
        } else {
            console.log("Vulnerability Exists: Ownership did not change after valid transfer");
        }
        
        assertEq(currentOwnerAfter, newOwner, "Ownership should be transferred to new owner");
    }
}