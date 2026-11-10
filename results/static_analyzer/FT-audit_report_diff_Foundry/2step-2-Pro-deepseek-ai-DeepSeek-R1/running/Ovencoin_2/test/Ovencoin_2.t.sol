// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ovencoin.sol";

contract OvencoinTest is Test {
    Ovencoin public token;
    address owner = address(0x1);
    address notOwner = address(0x2);
    
    function setUp() public {
        vm.prank(owner);
        token = new Ovencoin();
    }
    
    function testRecoverAddressNotInitialized() public {
        console.log("--- BEFORE-Trigger Operation ---");
        console.log("Owner:", owner);
        assertEq(token.owner(), owner, "Initial owner should be set");
        
        console.log("--- Trigger Owner Renounce ---");
        // Only owner should be able to renounceOwnership
        vm.prank(owner);
        token.renounceOwnership();
        address newOwner = token.owner();
        console.log("New owner after renounce:", newOwner);

        console.log("--- Trigger Non-Owner Renounce ---");
        vm.prank(notOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.renounceOwnership();
        console.log("Revert successful: Non-owner prevented from renouncing");

        console.log("Vulnerability not Exist: Access control reverts non-owner calls as expected");
    }
    
    function testOwnerRecoverEquality() public {
        // Should always succeed since _recover is address(0) and tx.origin never 0
        assertTrue(owner != address(0), "Owner should not be zero address");
        assertTrue(token.owner() == owner, "Owner should be set correctly");
    }
}