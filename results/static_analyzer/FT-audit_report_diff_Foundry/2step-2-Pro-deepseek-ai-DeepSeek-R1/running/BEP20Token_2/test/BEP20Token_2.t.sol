// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import "../src/BEP20Token.sol";

contract SafeMathIssuesTest is Test {
    BEP20Token token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address spender = makeAddr("spender");
    uint256 constant INITIAL_SUPPLY = 60000000000;

    function setUp() public {
        vm.prank(owner);
        token = new BEP20Token();
    }

    // Test SafeMath underflow protection in decreaseAllowance
    function test_decreaseAllowanceRevertsWhenUnderflowing() public {
        vm.prank(owner);
        token.approve(spender, 1000);
        
        vm.prank(owner);
        vm.expectRevert("BEP20: decreased allowance below zero");
        token.decreaseAllowance(spender, 1001);
    }

    // Test Solidity 0.8.7's built-in overflow protection in mint
    function test_mintRevertsWithArithmeticOverflow() public {
        uint256 maxUint = type(uint256).max;
        uint256 initialSupply = token.totalSupply();
        uint256 overflowAmount = maxUint - initialSupply + 1;

        vm.prank(owner);
        vm.expectRevert(stdError.arithmeticError);
        token.mint(overflowAmount);
    }

    // Test SafeMath underflow protection in transfer
    function test_transferRevertsWhenExceedingBalance() public {
        uint256 ownerBalance = token.balanceOf(owner);
        uint256 invalidAmount = ownerBalance + 1;
        
        vm.prank(owner);
        vm.expectRevert("BEP20: transfer amount exceeds balance");
        token.transfer(user, invalidAmount);
    }

    // Test valid arithmetic operations
    function test_validTransferSucceeds() public {
        uint256 transferAmount = 1000;
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialUserBalance = token.balanceOf(user);

        vm.prank(owner);
        token.transfer(user, transferAmount);

        assertEq(token.balanceOf(owner), initialOwnerBalance - transferAmount);
        assertEq(token.balanceOf(user), initialUserBalance + transferAmount);

        // Final validation
        console.log("Vulnerability not Exist: All SafeMath protections are functional");
    }
}