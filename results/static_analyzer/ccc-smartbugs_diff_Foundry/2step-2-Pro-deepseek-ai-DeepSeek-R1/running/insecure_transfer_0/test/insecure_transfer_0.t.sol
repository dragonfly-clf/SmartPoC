// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/insecure_transfer.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd token;
    address owner;
    address user = address(0x1);

    function setUp() public {
        owner = address(this);
        token = new IntegerOverflowAdd();
    }

    function test_MintOverflow() public {
        uint256 maxUint = type(uint256).max;
        uint256 initialMintAmount = maxUint - 10;

        // Initial mint (under max limit)
        token.mint(user, initialMintAmount);
        uint256 balanceAfterFirstMint = token.balanceOf(user);
        uint256 supplyAfterFirstMint = token.totalSupply();

        // Verify initial mint succeeded
        assertEq(balanceAfterFirstMint, initialMintAmount, "Initial balance incorrect");
        assertEq(supplyAfterFirstMint, initialMintAmount, "Initial supply incorrect");

        // Record state before overflow-trigger
        console.log("--- BEFORE-Trigger (Second Mint) ---");
        uint256 balanceBeforeSecondMint = token.balanceOf(user);
        uint256 supplyBeforeSecondMint = token.totalSupply();
        console.log("User balance before second mint: ", balanceBeforeSecondMint);
        console.log("Total supply before second mint: ", supplyBeforeSecondMint);

        // Trigger overflow operation
        console.log("--- Trigger Second Mint (Overflow) ---");
        uint256 overflowMintAmount = 11;
        console.log("Minting additional %s tokens", overflowMintAmount);
        token.mint(user, overflowMintAmount);

        // Record state after overflow-trigger
        console.log("--- AFTER-Trigger (Second Mint) ---");
        uint256 balanceAfterOverflow = token.balanceOf(user);
        uint256 supplyAfterOverflow = token.totalSupply();
        console.log("User balance after second mint: ", balanceAfterOverflow);
        console.log("Total supply after second mint: ", supplyAfterOverflow);

        // Vulnerability verification
        bool vulnerabilityExists = balanceAfterOverflow == 0 && supplyAfterOverflow == 0;
        assertEq(balanceAfterOverflow, 0, "Overflowed balance is not 0");
        assertEq(supplyAfterOverflow, 0, "Overflowed supply is not 0");
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Integer overflow causes balance/supply to wrap to 0");
        } else {
            console.log("Vulnerability not Exist: No integer overflow occurred");
        }
    }

    function test_NormalMint() public {
        token.mint(user, 100);
        assertEq(token.balanceOf(user), 100, "Normal mint failed");
    }
}