// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BitGameVerse.sol";
import "forge-std/console2.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockRouter {
    address immutable factoryAddr = address(new MockFactory());
    
    function factory() external view returns (address) {
        return factoryAddr;
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract BitGameVerseBlacklistTest is Test {
    BitGameVerse public token;
    address owner = address(0x1);
    address user = address(0x2);
    address[] public accounts = [address(0x3), address(0x4)];

    function setUp() public {
        // Deploy router
        MockRouter mockRouter = new MockRouter();
        
        // Deploy token as owner
        vm.startPrank(owner);
        token = new BitGameVerse(address(mockRouter));
        
        // Transfer initial tokens
        token.transfer(user, 1 ether);
        for (uint256 i = 0; i < accounts.length; i++) {
            token.transfer(accounts[i], 1 ether);
        }
        
        // Skip 1 year to avoid initial cooldown
        vm.warp(block.timestamp + 365 days);
        
        vm.stopPrank();
    }

    function testOwnerCanSingleBlacklist() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        vm.prank(user);
        token.transfer(address(0x123), 0.5 ether);
        console2.log("Pre-transfer success: Initial transfer worked as expected");
        
        // Skip cooldown period after transfer
        vm.warp(block.timestamp + 365 days);

        console2.log("--- Trigger: Blacklist user ---");
        vm.prank(owner);
        token.updateIsBlacklisted(user, true);
        
        console2.log("--- AFTER-Trigger Transfer ---");
        vm.prank(user);
        vm.expectRevert();
        token.transfer(address(0x123), 0.5 ether);
        console2.log("Post-transfer reverted: Blacklist worked as expected");
        
        console2.log("Vulnerability Exists: Owner can single blacklist accounts and block transfers");
    }

    function testOwnerCanBulkBlacklist() public {
        console2.log("--- BEFORE-Trigger Transfer (Bulk) ---");
        for (uint256 i = 0; i < accounts.length; i++) {
            vm.prank(accounts[i]);
            token.transfer(address(0x123), 0.5 ether);
        }
        console2.log("Pre-transfer success: All bulk transfers worked");
        
        // Skip cooldown period after transfers
        vm.warp(block.timestamp + 365 days);

        console2.log("--- Trigger: Bulk blacklist ---");
        vm.prank(owner);
        token.bulkIsBlacklisted(accounts, true);
        
        console2.log("--- AFTER-Trigger Transfer (Bulk) ---");
        for (uint256 i = 0; i < accounts.length; i++) {
            vm.prank(accounts[i]);
            vm.expectRevert();
            token.transfer(address(0x123), 0.5 ether);
        }
        console2.log("Post-transfer reverted: All bulk transfers blocked");
        
        console2.log("Vulnerability Exists: Owner can bulk blacklist accounts and block transfers");
    }
}