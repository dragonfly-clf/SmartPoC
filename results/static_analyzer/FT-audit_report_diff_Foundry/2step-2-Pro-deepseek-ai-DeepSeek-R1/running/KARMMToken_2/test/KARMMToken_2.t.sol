// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KARMMToken.sol";

contract KARMMTokenBlacklistTest is Test {
    KARMMToken token;
    address owner = address(0x100);
    address user = address(0x200);
    address blacklistedAddress = address(0x300);
    uint256 constant INITIAL_SUPPLY = 3000000000 * 10**18;

    function setUp() public {
        vm.startPrank(owner);
        token = new KARMMToken();
        // Set initial balances
        token.transfer(user, INITIAL_SUPPLY / 4); // User receives tokens
        token.transfer(address(token), INITIAL_SUPPLY / 4);
        vm.stopPrank();
    }

    function testBlacklistedTransferRestrictions() public {
        bool vulnerabilityExists = false;
        uint256 amountToTransfer = INITIAL_SUPPLY / 100; // Consistent transfer amount
        
        // Pre-test balances
        console.log("Initial state:");
        console.log("--- BEFORE BLACKLISTING ---");
        uint256 ownerInitial = token.balanceOf(owner);
        uint256 userInitial = token.balanceOf(user);
        uint256 blacklistedInitial = token.balanceOf(blacklistedAddress);
        uint256 contractInitial = token.balanceOf(address(token));
        console.log("Owner balance:", ownerInitial);
        console.log("User balance:", userInitial);
        console.log("Blacklisted balance:", blacklistedInitial);
        console.log("Contract balance:", contractInitial);
        
        // Blacklist target address
        console.log("\n--- TRIGGER: BLACKLIST OPERATION ---");
        vm.prank(owner);
        token.blacklistAddress(blacklistedAddress);
        assertTrue(token.isAddressBlacklisted(blacklistedAddress), "Address should be blacklisted");

        // Test 1: Direct transfer protection
        console.log("\n--- TEST 1: DIRECT TRANSFER RESTRICTION ---");
        console.log("--- BEFORE-Trigger (Test1) ---");
        uint256 userBalBefore = token.balanceOf(user);
        uint256 blacklistedBalBefore = token.balanceOf(blacklistedAddress);
        console.log("User (sender) balance:", userBalBefore);
        console.log("Blacklisted (recipient) balance:", blacklistedBalBefore);

        console.log("--- Trigger: Direct Transfer ---");
        vm.prank(user);
        vm.expectRevert("Recipient is blacklisted");
        token.transfer(blacklistedAddress, amountToTransfer);
        
        console.log("--- AFTER-Trigger (Test1) ---");
        uint256 userBalAfter = token.balanceOf(user);
        uint256 blacklistedBalAfter = token.balanceOf(blacklistedAddress);
        console.log("User (sender) balance:", userBalAfter);
        console.log("Blacklisted (recipient) balance:", blacklistedBalAfter);
        
        // Validate state unchanged for Test1
        bool test1Passed = (userBalAfter == userBalBefore) && 
                          (blacklistedBalAfter == blacklistedBalBefore);
        console.log("Test1 State Match? %s", test1Passed ? "PASS" : "FAIL");
        if (!test1Passed) vulnerabilityExists = true;

        // Test 2: WithdrawTokens protection
        console.log("\n--- TEST 2: CONTRACT WITHDRAWAL RESTRICTION ---");
        console.log("--- BEFORE-Trigger (Test2) ---");
        uint256 contractBalBefore = token.balanceOf(address(token));
        blacklistedBalBefore = token.balanceOf(blacklistedAddress);
        console.log("Contract balance:", contractBalBefore);
        console.log("Blacklisted (recipient) balance:", blacklistedBalBefore);

        console.log("--- Trigger: Contract Withdrawal ---");
        vm.prank(owner);
        vm.expectRevert("Recipient is blacklisted");
        token.withdrawTokens(blacklistedAddress, amountToTransfer);
        
        console.log("--- AFTER-Trigger (Test2) ---");
        uint256 contractBalAfter = token.balanceOf(address(token));
        blacklistedBalAfter = token.balanceOf(blacklistedAddress);
        console.log("Contract balance:", contractBalAfter);
        console.log("Blacklisted (recipient) balance:", blacklistedBalAfter);
        
        // Validate state unchanged for Test2
        bool test2Passed = (contractBalAfter == contractBalBefore) && 
                          (blacklistedBalAfter == blacklistedBalBefore);
        console.log("Test2 State Match? %s", test2Passed ? "PASS" : "FAIL");
        if (!test2Passed) vulnerabilityExists = true;

        // Final verdict
        console.log("\n--- VULNERABILITY VERDICT ---");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State modified during blacklisted transfers");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after reverted transfers");
        }
    }
}