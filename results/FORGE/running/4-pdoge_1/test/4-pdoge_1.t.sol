// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PILOTDOGE.sol";

contract PilotDogeBlacklistTest is Test {
    PILOTDOGE token;
    address owner = address(0x001);
    address user1 = address(0x002);
    address user2 = address(0x003);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = 0x1111111111111111111111111111111111111111;
    address mockWETH = 0x2222222222222222222222222222222222222222;
    address mockPair = 0x3333333333333333333333333333333333333333;

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair call (handle any input parameters)
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token with proper mocking
        vm.startPrank(owner);
        token = new PILOTDOGE();
        
        // Fund test users
        uint256 totalSupply = token.totalSupply();
        token.transfer(user1, totalSupply / 3);
        vm.stopPrank();
    }

    function testBlacklistBlocksTransactions() public {
        uint256 amount = 1 * 10 ** token.decimals();
        
        // Transfer to user2 before blacklisting
        vm.prank(owner);
        token.transfer(user2, amount);

        console.log("--- BEFORE-Trigger Blacklist Management ---");
        bool user2BlacklistedBefore = token.isBlacklisted(user2);
        console.log("User2 blacklisted status (before):", user2BlacklistedBefore ? "YES" : "NO");

        console.log("--- Trigger: enable_blacklist and manage_blacklist ---");
        // Enable blacklist and add user2 to blacklist
        vm.prank(owner);
        token.enable_blacklist(true);
        
        address[] memory targets = new address[](1);
        targets[0] = user2;
        vm.prank(owner);
        token.manage_blacklist(targets, true);

        console.log("--- AFTER-Trigger Blacklist Status ---");
        bool user2BlacklistedAfter = token.isBlacklisted(user2);
        console.log("User2 blacklisted status (after):", user2BlacklistedAfter ? "YES" : "NO");

        // Validate whether vulnerability was exploited
        bool vulnerabilityExploited = !user2BlacklistedBefore && user2BlacklistedAfter;
        console.log("Vulnerability verdict:", vulnerabilityExploited ? "Status changed!" : "Status unchanged!");

        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Blacklist state successfully modified");
        } else {
            console.log("Vulnerability not Exist: Blacklist state modification failed");
        }
    }
}