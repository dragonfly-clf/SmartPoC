// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/bullstoken.sol";

contract BullCoinBlacklistTest is Test {
    BullCoin token;
    address owner = makeAddr("owner");
    address airdropWallet = makeAddr("airdropWallet");
    address user = makeAddr("user");
    address receiver = makeAddr("receiver");

    function setUp() public {
        // Owner deploys the contract with initial allocations
        vm.prank(owner);
        token = new BullCoin(
            1000,            // _totalSupply
            address(this),   // _lpWallet (dummy address)
            address(this),   // _ecoWallet (dummy address)
            airdropWallet    // _airdropWallet
        );

        // Transfer tokens to a regular user
        uint256 transferAmount = 10 ether;  // 10 tokens considering 18 decimals
        vm.prank(airdropWallet);
        token.transfer(user, transferAmount);

        // Sanity check - user should have tokens
        assertEq(token.balanceOf(user), transferAmount);
    }

    function testOwnerCanBlacklist() public {
        console.log("--- BEFORE-Trigger Blacklist Status ---");
        // Query initial blacklist status
        bool isBlacklistedBefore = token.blacklists(user);
        console.log("User blacklisted status (before):", isBlacklistedBefore ? "true" : "false");

        console.log("--- Trigger Blacklist Operation ---");
        // Owner blacklists user
        vm.prank(owner);
        token.blacklist(user, true);

        console.log("--- AFTER-Trigger Blacklist Status ---");
        // Query blacklist status after operation
        bool isBlacklistedAfter = token.blacklists(user);
        console.log("User blacklisted status (after):", isBlacklistedAfter ? "true" : "false");

        // Determine if vulnerability was exploited (state changed)
        bool stateChanged = (isBlacklistedBefore != isBlacklistedAfter);
        string memory verdict = stateChanged 
            ? "Vulnerability Exists: Blacklist status changed from false to true" 
            : "Vulnerability not Exist: Blacklist status unchanged";

        console.log("--- Blacklist State Change Verification ---");
        console.log("Status change occurred:", stateChanged ? "YES" : "NO");
        console.log("Verification Verdict:", verdict);

        console.log("--- Attempt Transfer ---");
        // Verify blacklisting prevents token transfers
        vm.prank(user);
        vm.expectRevert();  // Expect transaction to revert
        token.transfer(receiver, 1 ether);

        // Final verdict based on state change
        require(stateChanged, verdict);
        console.log(verdict);
    }
}