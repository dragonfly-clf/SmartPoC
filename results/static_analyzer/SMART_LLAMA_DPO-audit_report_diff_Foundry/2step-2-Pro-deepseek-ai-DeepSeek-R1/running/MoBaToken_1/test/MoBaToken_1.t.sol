// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    MoBaToken token;
    address owner = address(0x1);
    address alice = address(0x2);

    function setUp() public {
        vm.prank(owner);
        token = new MoBaToken("TestToken", "TTK");
    }

    function testOwnerCanBurnUserTokens() public {
        // Mint tokens to Alice using owner privileges
        vm.prank(owner);
        token.cross(alice, 1000 ether);
        
        // State checks BEFORE the vulnerability trigger
        console.log("--- BEFORE-Trigger ManagerBurn ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Alice balance before:  %s", aliceBalanceBefore);
        console.log("Total supply before:   %s", totalSupplyBefore);
        assertEq(aliceBalanceBefore, 1000 ether, "Initial mint to Alice failed");

        // Trigger: Owner forcibly burns Alice's tokens
        console.log("--- Trigger ManagerBurn ---");
        vm.prank(owner);
        token.managerBurn(alice, 500 ether);

        // State checks AFTER the vulnerability trigger
        console.log("--- AFTER-Trigger ManagerBurn ---");
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Alice balance after:   %s", aliceBalanceAfter);
        console.log("Total supply after:    %s", totalSupplyAfter);

        // Calculate state differences
        uint256 aliceBalanceReduction = aliceBalanceBefore - aliceBalanceAfter;
        uint256 totalSupplyReduction = totalSupplyBefore - totalSupplyAfter;
        console.log("Alice balance reduction: %s", aliceBalanceReduction);
        console.log("Total supply reduction:  %s", totalSupplyReduction);

        // Vulnerability check
        bool balanceChanged = aliceBalanceReduction == 500 ether;
        bool supplyChanged = totalSupplyReduction == 500 ether;
        bool vulnerabilityExists = balanceChanged && supplyChanged;
        
        // Final verification
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can forcibly burn user tokens");
        } else {
            console.log("Vulnerability not Exist: Burn operation had unexpected effects");
        }

        // Assertions for test framework
        assertEq(aliceBalanceAfter, 500 ether, "Alice's balance not updated correctly");
        assertEq(totalSupplyAfter, totalSupplyBefore - 500 ether, "Total supply not reduced");
    }
}