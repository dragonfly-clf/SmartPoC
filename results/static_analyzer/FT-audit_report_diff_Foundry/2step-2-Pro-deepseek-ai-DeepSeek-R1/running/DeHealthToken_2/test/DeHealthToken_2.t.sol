// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeHealthToken.sol";

contract DeHealthTokenTest is Test {
    DeHealthToken token;
    address admin = address(0x1);
    uint256 constant MAX_SUPPLY = 1000000000 * 1e18;

    function setUp() public {
        vm.startPrank(admin);
        token = new DeHealthToken();
        token.initialize(admin);
        vm.stopPrank();
    }

    function testMaxSupplyCanBeExceeded() public {
        vm.startPrank(admin);
        
        // Set initial balance to max supply
        address[] memory addresses = new address[](1);
        uint256[] memory balances = new uint256[](1);
        addresses[0] = admin;
        balances[0] = MAX_SUPPLY;
        token.__loadBalances(addresses, balances);
        
        // Capture state BEFORE critical operation
        console.log("--- BEFORE critical __loadBalances ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 adminBalanceBefore = token.balanceOf(admin);
        console.log("Initial total supply:  %s", totalSupplyBefore);
        console.log("Initial admin balance: %s", adminBalanceBefore);
        console.log("");

        // Execute critical operation - load additional token
        console.log("--- TRIGGER: __loadBalances (1 token) ---");
        balances[0] = 1;
        token.__loadBalances(addresses, balances);
        
        // Capture state AFTER critical operation
        console.log("--- AFTER critical __loadBalances ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 adminBalanceAfter = token.balanceOf(admin);
        console.log("Updated total supply:  %s", totalSupplyAfter);
        console.log("Updated admin balance: %s", adminBalanceAfter);
        console.log("");
        
        vm.stopPrank();

        // Differential validation
        uint256 supplyDiff = totalSupplyAfter - totalSupplyBefore;
        uint256 balanceDiff = adminBalanceAfter - adminBalanceBefore;
        console.log("DIFFERENTIAL RESULTS:");
        console.log("- Total supply change:  %s", supplyDiff);
        console.log("- Admin balance change: %s", balanceDiff);
        console.log("- Max supply cap violation: %s",
            totalSupplyAfter > MAX_SUPPLY ? "YES, VULNERABLE" : "NO, SAFE");
        
        // Vulnerability verdict (single final output)
        if (totalSupplyAfter > MAX_SUPPLY) {
            console.log("Vulnerability Exists: Token total supply exceeds max cap (%s > %s)", 
                totalSupplyAfter, MAX_SUPPLY);
        } else {
            console.log("Vulnerability not Exist: Token supply remains at or below max cap (%s <= %s)", 
                totalSupplyAfter, MAX_SUPPLY);
        }
    }
}