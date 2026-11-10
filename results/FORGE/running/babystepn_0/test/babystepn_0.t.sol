// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYSTEPN.sol";

contract BlacklistTest is Test {
    BABYSTEPN token;
    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);
    
    // Mock addresses
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address MOCK_WETH = address(0xABCD);
    address MOCK_FACTORY = address(0x1234);
    address MOCK_PAIR = address(0x1111);

    function setUp() public {
        // Mock router and factory
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(MOCK_WETH));
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(MOCK_FACTORY));
        vm.mockCall(MOCK_FACTORY, abi.encodeWithSignature("createPair(address,address)"), abi.encode(MOCK_PAIR));

        vm.startPrank(owner);
        token = new BABYSTEPN();
        token.tradingStatus(true);
        
        // Transfer tokens to alice for testing
        uint256 balanceOwner = token.balanceOf(owner);
        token.transfer(alice, balanceOwner / 2);
        vm.stopPrank();
    }

    function testBlacklistedUserCannotTransfer() public {
        console.log("--- BEFORE-Trigger isBlacklisted ---");
        bool aliceBlacklistedBefore = token.isBlacklisted(alice);
        console.log("Alice Blacklist Status Before:", aliceBlacklistedBefore ? "BLACKLISTED" : "NOT BLACKLISTED");
        uint256 aliceBalance = token.balanceOf(alice);
        uint256 bobBalance = token.balanceOf(bob);
        
        console.log("--- Trigger manage_blacklist ---");
        // Owner blacklists alice
        vm.prank(owner);
        address[] memory addresses = new address[](1);
        addresses[0] = alice;
        token.manage_blacklist(addresses, true);
        
        console.log("--- AFTER-Trigger isBlacklisted ---");
        bool aliceBlacklistedAfter = token.isBlacklisted(alice);
        console.log("Alice Blacklist Status After:", aliceBlacklistedAfter ? "BLACKLISTED" : "NOT BLACKLISTED");
        
        console.log("--- Comparison Verdict ---");
        if (aliceBlacklistedBefore != aliceBlacklistedAfter) {
            console.log("Vulnerability Exists: Blacklist status changed from %s to %s", aliceBlacklistedBefore, aliceBlacklistedAfter);
        } else {
            console.log("Vulnerability not Exist: Blacklist status unchanged");
        }
        
        // Verify alice is blacklisted
        vm.prank(alice);
        vm.expectRevert("Blacklisted");
        token.transfer(bob, aliceBalance / 2);
        
        // Verify tokens not transferred
        assertEq(token.balanceOf(alice), aliceBalance);
        assertEq(token.balanceOf(bob), bobBalance);
    }

    function testBlacklistedRecipientCannotReceive() public {
        console.log("--- BEFORE-Trigger isBlacklisted ---");
        bool bobBlacklistedBefore = token.isBlacklisted(bob);
        console.log("Bob Blacklist Status Before:", bobBlacklistedBefore ? "BLACKLISTED" : "NOT BLACKLISTED");
        uint256 aliceBalance = token.balanceOf(alice);
        uint256 bobBalance = token.balanceOf(bob);
        
        console.log("--- Trigger manage_blacklist ---");
        // Owner blacklists bob
        vm.prank(owner);
        address[] memory addresses = new address[](1);
        addresses[0] = bob;
        token.manage_blacklist(addresses, true);
        
        console.log("--- AFTER-Trigger isBlacklisted ---");
        bool bobBlacklistedAfter = token.isBlacklisted(bob);
        console.log("Bob Blacklist Status After:", bobBlacklistedAfter ? "BLACKLISTED" : "NOT BLACKLISTED");
        
        console.log("--- Comparison Verdict ---");
        if (bobBlacklistedBefore != bobBlacklistedAfter) {
            console.log("Vulnerability Exists: Blacklist status changed from %s to %s", bobBlacklistedBefore, bobBlacklistedAfter);
        } else {
            console.log("Vulnerability not Exist: Blacklist status unchanged");
        }
        
        // Verify transfer to blacklisted recipient reverts
        vm.prank(alice);
        vm.expectRevert("Blacklisted");
        token.transfer(bob, aliceBalance / 2);
        
        // Verify tokens not transferred
        assertEq(token.balanceOf(alice), aliceBalance);
        assertEq(token.balanceOf(bob), bobBalance);
    }

    function testNonOwnerCannotBlacklist() public {
        address[] memory addresses = new address[](1);
        addresses[0] = alice;
        
        vm.prank(alice);
        vm.expectRevert("!OWNER");
        token.manage_blacklist(addresses, true);
    }
}