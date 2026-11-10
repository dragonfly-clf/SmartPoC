// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/insecure_transfer.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd public token;

    function setUp() public {
        token = new IntegerOverflowAdd();
    }

    function test_TotalSupplyIntegerOverflow() public {
        uint256 maxUint = type(uint256).max;

        // First mint: set totalSupply to near overflow state
        token.mint(address(1), maxUint - 100);

        // Validate pre-overflow state
        assertEq(token.totalSupply(), maxUint - 100, "Pre-overflow total supply incorrect");
        assertEq(token.getBalance(address(1)), maxUint - 100, "Pre-overflow balance incorrect");

        console.log("--- BEFORE-Trigger Mint (101 tokens) ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 balanceBefore = token.getBalance(address(1));
        console.log("Pre-trigger totalSupply: %s, user balance: %s", totalSupplyBefore, balanceBefore);

        console.log("--- Trigger Mint (101 tokens) ---");
        // Second mint: trigger integer overflow by adding 101
        token.mint(address(1), 101);

        console.log("--- AFTER-Trigger Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 balanceAfter = token.getBalance(address(1));
        console.log("Post-trigger totalSupply: %s, user balance: %s", totalSupplyAfter, balanceAfter);
        
        // Differential comparison
        bool vulnerabilityOccurred = (totalSupplyAfter == 0 && balanceAfter == 0);
        if (vulnerabilityOccurred) {
            console.log("Diff: totalSupply Before=%d After=%d (OVERFLOW)", totalSupplyBefore, totalSupplyAfter);
            console.log("Diff: balance Before=%d After=%d (OVERFLOW)", balanceBefore, balanceAfter);
            console.log("Vulnerability Exists: Integer overflow occurred - state reset to zero");
        } else {
            console.log("Diff: totalSupply Before=%d After=%d (NO OVERFLOW)", totalSupplyBefore, totalSupplyAfter);
            console.log("Diff: balance Before=%d After=%d (NO OVERFLOW)", balanceBefore, balanceAfter);
            console.log("Vulnerability not Exist: State remains non-zero - overflow protection works");
        }

        // Original assertions remain for test correctness
        assertEq(totalSupplyAfter, 0, "Integer overflow not occurred in totalSupply");
        assertEq(balanceAfter, 0, "Integer overflow not reflected in user balance");
    }
}