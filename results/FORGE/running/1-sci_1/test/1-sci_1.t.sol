// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCIp.sol";

contract SCIpMintTest is Test {
    SCIp token;
    address constant owner = address(0xdeadbeef);
    address constant recipient = address(0xcafebabe);
    uint256 constant INITIAL_SUPPLY = 10000000000 * 1e18;
    
    function setUp() public {
        vm.startPrank(owner);
        token = new SCIp(); // Deploys with initial mint to owner
        vm.stopPrank();
    }

    function test_OwnerCanMintArbitraryTokens() public {
        // Define mint amount
        uint256 mintAmount = 5000 * 1e18; // 5000 tokens
        
        // Capture initial state
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialRecipientBalance = token.balanceOf(recipient);

        console.log("--- BEFORE-Trigger Mint ---");
        console.log("Total Supply: %s", initialTotalSupply);
        console.log("Recipient Balance: %s", initialRecipientBalance);

        // Validate initial state
        assertEq(initialTotalSupply, INITIAL_SUPPLY, "Initial total supply mismatch");
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY, "Initial owner balance mismatch");
        assertEq(initialRecipientBalance, 0, "Initial recipient balance should be zero");

        console.log("--- Trigger Mint ---");
        // Owner mints tokens to recipient
        vm.prank(owner);
        token.mint(recipient, mintAmount);
        console.log("Minted %s tokens to recipient", mintAmount);

        console.log("--- AFTER-Trigger Mint ---");
        // Capture post-mint state
        uint256 newTotalSupply = token.totalSupply();
        uint256 newRecipientBalance = token.balanceOf(recipient);
        
        console.log("Total Supply: %s", newTotalSupply);
        console.log("Recipient Balance: %s", newRecipientBalance);

        // Calculate differences
        uint256 supplyDifference = newTotalSupply - initialTotalSupply;
        uint256 balanceDifference = newRecipientBalance - initialRecipientBalance;
        
        console.log("Total Supply Increase: %s", supplyDifference);
        console.log("Recipient Balance Increase: %s", balanceDifference);

        // Check vulnerability condition
        bool vulnerabilityExists = (supplyDifference == mintAmount) && (balanceDifference == mintAmount);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can mint arbitrary tokens without restriction");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions are in place");
        }

        // Original assertions remain for compatibility
        assertEq(
            newTotalSupply,
            initialTotalSupply + mintAmount,
            "Total supply did not increase by mint amount"
        );
        assertEq(
            newRecipientBalance,
            mintAmount,
            "Recipient did not receive minted tokens"
        );
    }
}