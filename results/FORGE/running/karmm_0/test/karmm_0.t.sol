// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KARMMToken.sol";

contract KARMMBlacklistTest is Test {
    KARMMToken public token;
    address public owner = vm.addr(1);
    address public user = vm.addr(2);
    
    function setUp() public {
        vm.prank(owner);
        token = new KARMMToken();  // Owner receives initial supply
        
        // Transfer tokens from owner to user
        vm.prank(owner);
        token.transfer(user, 1000 ether);
    }

    function test_owner_can_arbitrarily_blacklist() public {
        // BEFORE: Check initial blacklist status
        console.log("--- BEFORE-Trigger Blacklist ---");
        bool isBlacklistedBefore = token.isAddressBlacklisted(user);
        console.log("User blacklisted? %s", isBlacklistedBefore ? "Yes" : "No");
        
        assertFalse(isBlacklistedBefore, "User should not be blacklisted initially");
        
        // TRIGGER ACTION: Owner blacklists user
        console.log("--- Trigger: owner calls blacklistAddress ---");
        vm.prank(owner);
        token.blacklistAddress(user);
        
        // AFTER: Verify blacklist status changed
        console.log("--- AFTER-Trigger Blacklist ---");
        bool isBlacklistedAfter = token.isAddressBlacklisted(user);
        console.log("User blacklisted? %s", isBlacklistedAfter ? "Yes" : "No");
        assertTrue(isBlacklistedAfter, "User should be blacklisted after owner action");
        
        // DIFFERENTIAL VERDICT
        if (isBlacklistedAfter) {
            console.log("Vulnerability Exists: Owner can arbitrarily blacklist user address");
        } else {
            console.log("Vulnerability not Exist: Blacklist operation failed");
        }
        
        // Additional verification
        vm.prank(user);
        vm.expectRevert(); 
        token.transfer(address(0x123), 100 ether);
    }

    function test_nonowner_cannot_blacklist() public {
        // BEFORE: Initial state
        console.log("--- BEFORE-Attempted Blacklist ---");
        bool isBlacklistedBefore = token.isAddressBlacklisted(user);
        console.log("User blacklisted? %s", isBlacklistedBefore ? "Yes" : "No");
        
        // TRIGGER: Non-owner attempts to blacklist
        console.log("--- Trigger: non-owner attempts blacklistAddress ---");
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.blacklistAddress(user);
        
        // AFTER: Verify no change
        console.log("--- AFTER-Attempted Blacklist ---");
        bool isBlacklistedAfter = token.isAddressBlacklisted(user);
        console.log("User blacklisted? %s", isBlacklistedAfter ? "Yes" : "No");
        
        // DIFFERENTIAL VERDICT
        if (isBlacklistedAfter != isBlacklistedBefore) {
            console.log("Vulnerability Exists: Non-owner can change blacklist status");
        } else {
            console.log("Vulnerability not Exist: Non-owner cannot change blacklist status");
        }
    }
    
    function test_renouncing_ownership_removes_blacklist_power() public {
        // Setup ownership change
        vm.prank(owner);
        token.renounceOwnership();
        assertEq(token.owner(), address(0), "Ownership not renounced");
        
        // BEFORE: Initial state
        console.log("--- BEFORE-Attempted Blacklist ---");
        bool isBlacklistedBefore = token.isAddressBlacklisted(user);
        console.log("User blacklisted? %s", isBlacklistedBefore ? "Yes" : "No");
        
        // TRIGGER: Former owner attempts to blacklist
        console.log("--- Trigger: former owner attempts blacklistAddress ---");
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.blacklistAddress(user);
        
        // AFTER: Verify no change
        console.log("--- AFTER-Attempted Blacklist ---");
        bool isBlacklistedAfter = token.isAddressBlacklisted(user);
        console.log("User blacklisted? %s", isBlacklistedAfter ? "Yes" : "No");
        
        // DIFFERENTIAL VERDICT
        if (isBlacklistedAfter != isBlacklistedBefore) {
            console.log("Vulnerability Exists: Renounced owner can still blacklist");
        } else {
            console.log("Vulnerability not Exist: Renounced owner properly blocked");
        }
    }
}