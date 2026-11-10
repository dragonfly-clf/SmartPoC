// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EKARTINU.sol";

contract EKARTINUTaxOverflowTest is Test {
    EKARTINU public token;
    address public owner;
    address public user = address(0x1);
    address public recipient = address(0x2);

    function setUp() public {
        owner = address(this);
        token = new EKARTINU();
        
        // Mint initial tokens to user
        token.excludeFromFee(owner);  // Exclude owner from fees
        token.transfer(user, 1000 * 10**9);
    }

    // Test fee overflow when multiplication result exceeds uint256 max
    function testTaxMultiplicationOverflow() public {
        // Set extreme fee value to cause multiplication overflow
        token.setLiquidityFee(type(uint256).max);

        // Confirm user has balance
        uint256 balance = token.balanceOf(user);
        assertGt(balance, 0);

        // Attempt transfer - should revert due to overflow
        vm.startPrank(user);
        vm.expectRevert();
        token.transfer(recipient, balance);
        vm.stopPrank();
        console.log("Vulnerability Exists: Multiplication overflow in tax calculation causes revert");
    }

    // Test fee underflow when tax sum exceeds transfer amount
    function testTaxSubtractionUnderflow() public {
        // Set fees that total > 100% (50+50+50=150%)
        token.setLiquidityFee(50);
        token.setRedistributionFee(50);
        token.setCovidFee(50);

        // Confirm user has balance
        uint256 balance = token.balanceOf(user);
        assertGt(balance, 0);

        // Attempt transfer - should revert due to underflow
        vm.startPrank(user);
        vm.expectRevert();
        token.transfer(recipient, balance);
        vm.stopPrank();
        console.log("Vulnerability Exists: Subtraction underflow in tax calculation causes revert");
    }
}