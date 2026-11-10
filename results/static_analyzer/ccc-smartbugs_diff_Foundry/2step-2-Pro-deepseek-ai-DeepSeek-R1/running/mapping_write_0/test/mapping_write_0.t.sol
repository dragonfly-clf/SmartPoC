// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mapping_write.sol";

contract Map_DoS_Test is Test {
    Map public mapContract;
    MaliciousOwner public maliciousOwner;

    function setUp() public {
        // Deploy malicious owner contract (cannot receive ETH)
        maliciousOwner = new MaliciousOwner();
        
        // Deploy map contract with malicious owner address as deployer
        vm.prank(address(maliciousOwner));
        mapContract = new Map();
    }

    function test_withdraw_DenialOfService() public {
        // Fund the contract with ETH
        vm.deal(address(mapContract), 1 ether);
        
        console.log("--- BEFORE-Trigger Balances ---");
        // Record initial balance states
        uint256 contractBalanceBefore = address(mapContract).balance;
        uint256 ownerBalanceBefore = address(maliciousOwner).balance;
        console.log("Contract ETH balance (before): %s", contractBalanceBefore);
        console.log("Malicious owner ETH balance (before): %s", ownerBalanceBefore);
        
        console.log("--- Trigger Withdraw ---");
        // Attempt to withdraw as owner (maliciousOwner)
        vm.prank(address(maliciousOwner));
        vm.expectRevert(); // Revert due to failed ETH transfer
        mapContract.withdraw();

        console.log("--- AFTER-Trigger Balances ---");
        // Record balance states after exploitation attempt
        uint256 contractBalanceAfter = address(mapContract).balance;
        uint256 ownerBalanceAfter = address(maliciousOwner).balance;
        console.log("Contract ETH balance (after): %s", contractBalanceAfter);
        console.log("Malicious owner ETH balance (after): %s", ownerBalanceAfter);

        // Verify balances remain unchanged
        if (contractBalanceBefore == contractBalanceAfter && ownerBalanceBefore == ownerBalanceAfter) {
            console.log("Vulnerability Exists: Withdraw failed due to DoS, balances unchanged");
        } else {
            console.log("Vulnerability not Exist: Withdraw unexpectedly succeeded");
        }
    }
}

// Helper contract without ETH receive capability
contract MaliciousOwner {
    Map public map;

    constructor() {
        map = new Map();
    }
}