// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol"; // Added for logging
import "../src/SHANKS_INU.sol";

// Mock Router implementation with correct checksum
contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x456);
    }
    
    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
}

// Mock Factory implementation
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract SHANKS_INUBlacklistTest is Test {
    SHANKS_INU token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    address constant presaler = address(0x410876C017bab6C4C9c595c34F6F21648847BEeD);

    function setUp() public {
        // Set up mock router at fixed address
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        MockRouter mockRouter = new MockRouter();
        vm.etch(routerAddr, address(mockRouter).code);
        
        // Set up mock factory at fixed address
        address factoryAddr = address(0x456);
        MockFactory mockFactory = new MockFactory();
        vm.etch(factoryAddr, address(mockFactory).code);

        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new SHANKS_INU();
        
        // Configure token for testing
        token.setDeadBlocks(0);                   // Trading enabled immediately
        token.setFees(0, 0, 0, 0, 100);           // Set zero fees
        token.setTxLimit(type(uint256).max);       // Remove transfer limit
        vm.stopPrank();

        // Transfer tokens from presaler to test users
        uint256 amount = 1000 * (10 ** token.decimals());
        vm.startPrank(presaler);
        token.transfer(user1, amount);
        token.transfer(user2, amount);
        vm.stopPrank();
    }

    function test_blacklistBlocksTransfer() public {
        uint256 amount = 100 * (10 ** token.decimals());
        
        vm.startPrank(owner);
        
        // Check initial blacklist state BEFORE operation
        console2.log("--- BEFORE: Trigger manage_blacklist ---");
        bool blacklistModeStateBefore = token.blacklistMode();
        bool isUser1BlacklistedBefore = token.isBlacklisted(user1);
        console2.log("Blacklist mode enabled:", blacklistModeStateBefore);
        console2.log("User1 blacklist status:", isUser1BlacklistedBefore);
        console2.log("");
        
        // Enable blacklist
        token.enable_blacklist(true);
        
        // Add user1 to blacklist (TRIGGER operation)
        console2.log("--- TRIGGER: manage_blacklist ---");
        address[] memory targets = new address[](1);
        targets[0] = user1;
        token.manage_blacklist(targets, true);
        console2.log("Added user1 to blacklist");
        console2.log("");
        
        // Check blacklist state AFTER operation
        console2.log("--- AFTER: Trigger manage_blacklist ---");
        bool blacklistModeStateAfter = token.blacklistMode();
        bool isUser1BlacklistedAfter = token.isBlacklisted(user1);
        console2.log("Blacklist mode enabled:", blacklistModeStateAfter);
        console2.log("User1 blacklist status:", isUser1BlacklistedAfter);
        
        vm.stopPrank();
        
        // Vulnerability verification
        console2.log("\n--- VERDICT ---");
        if (!isUser1BlacklistedBefore && isUser1BlacklistedAfter) {
            console2.log("Vulnerability Exists: Blacklist state successfully manipulated for user1");
        } else {
            console2.log("Vulnerability not Exist: Blacklist state unchanged for user1");
        }
        console2.log("----------------------------------");
        
        // Attempt transfer from blacklisted user (should fail)
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, amount);

        // Verify balances remain unchanged
        uint256 expectedBalance = 1000 * (10 ** token.decimals());
        assertEq(token.balanceOf(user1), expectedBalance, "User1 balance should remain unchanged");
        assertEq(token.balanceOf(user2), expectedBalance, "User2 balance should remain unchanged");
    }
}