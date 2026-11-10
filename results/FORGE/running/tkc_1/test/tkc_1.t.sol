// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KingdomCoin.sol";

contract KingdomCoinBlacklistTest is Test {
    KingdomCoin token;
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address[] blacklistedAddresses;

    function setUp() public {
        vm.startPrank(owner);

        // Mock router and factory calls
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x123);
        address mockPair = address(0x456);
        address mockWETH = address(0x789);

        // Mock router factory call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH call
        vm.mockCall(
            routerAddress,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy contract after setting up mocks
        token = new KingdomCoin();
        vm.stopPrank();

        // Initialize blacklist addresses
        blacklistedAddresses.push(user1);
        blacklistedAddresses.push(user2);
    }

    function test_OwnerCanBlacklistAddresses() public {
        // Pre-trigger blacklist status
        console2.log("--- BEFORE-Trigger Blacklist ---");
        bool beforeUser1 = token.isBlacklisted(user1);
        bool beforeUser2 = token.isBlacklisted(user2);
        console2.log("User1 blacklisted:", beforeUser1);
        console2.log("User2 blacklisted:", beforeUser2);

        // Verify initial non-blacklisted state
        assertFalse(beforeUser1, "User1 should not be blacklisted initially");
        assertFalse(beforeUser2, "User2 should not be blacklisted initially");

        // Trigger blacklist operation
        console2.log("--- Trigger Blacklist ---");
        vm.prank(owner);
        token.blackList(blacklistedAddresses, true);

        // Post-trigger blacklist status
        console2.log("--- AFTER-Trigger Blacklist ---");
        bool afterUser1 = token.isBlacklisted(user1);
        bool afterUser2 = token.isBlacklisted(user2);
        console2.log("User1 blacklisted:", afterUser1);
        console2.log("User2 blacklisted:", afterUser2);

        // Vulnerability verification
        if (!beforeUser1 && !beforeUser2 && afterUser1 && afterUser2) {
            console2.log("Vulnerability Exists: Owner successfully blacklisted addresses");
            console2.log("Vulnerability Exists: Owner successfully blacklisted addresses");
        } else {
            console2.log("Vulnerability not Exist: Blacklist operation failed");
            console2.log("Vulnerability not Exist: Blacklist operation failed");
        }

        // Original assertions remain as sanity checks
        assertTrue(token.isBlacklisted(user1), "User1 should be blacklisted");
        assertTrue(token.isBlacklisted(user2), "User2 should be blacklisted");
    }
}