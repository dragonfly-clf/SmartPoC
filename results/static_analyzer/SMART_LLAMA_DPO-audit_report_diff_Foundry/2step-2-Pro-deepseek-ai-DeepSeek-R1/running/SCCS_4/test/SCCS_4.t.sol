// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCCS.sol";

contract SCCSBurnTest is Test {
    SCCS token;
    address owner = address(0xA);
    address user = address(0xB);
    uint256 initialSupply = 100_000_000_000 * 10 ** 18; // 100 billion tokens * decimals

    function setUp() public {
        vm.prank(owner);
        token = new SCCS();
        vm.prank(owner);
        token.transfer(user, 10_000 * 10 ** 18); // Transfer tokens to user
    }

    function testPublicBurnArbitraryBurning() public {
        uint256 burnAmount = 5_000 * 10 ** 18;

        console.log("--- BEFORE-Trigger PublicBurn ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("User balance before:", userBalanceBefore);
        console.log("Total supply before:", totalSupplyBefore);

        console.log("--- Trigger PublicBurn ---");
        vm.prank(user);
        token.publicBurn(burnAmount);

        console.log("--- AFTER-Trigger PublicBurn ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("User balance after:", userBalanceAfter);
        console.log("Total supply after:", totalSupplyAfter);

        // Calculate expected values
        uint256 expectedUserBalance = userBalanceBefore - burnAmount;
        uint256 expectedTotalSupply = totalSupplyBefore - burnAmount;

        // Check vulnerability existence
        bool vulnerable = (userBalanceAfter == expectedUserBalance) && 
                          (totalSupplyAfter == expectedTotalSupply);
        
        if (vulnerable) {
            console.log("Vulnerability Exists: Unauthorized token burning succeeded.");
        } else {
            if (userBalanceAfter != expectedUserBalance) {
                console.log("Balance mismatch: Expected", expectedUserBalance, "got", userBalanceAfter);
            }
            if (totalSupplyAfter != expectedTotalSupply) {
                console.log("Supply mismatch: Expected", expectedTotalSupply, "got", totalSupplyAfter);
            }
            console.log("Vulnerability not Exist: Token state didn't change as expected.");
        }

        // Additional assertions from original test
        assertEq(token.balanceOf(user), userBalanceBefore - burnAmount, "User balance not properly burned");
        assertEq(token.totalSupply(), totalSupplyBefore - burnAmount, "Total supply not properly decreased");
    }
}