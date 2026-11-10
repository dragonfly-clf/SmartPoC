// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/insecure_transfer.sol";

contract TestIntegerOverflowMint is Test {
    IntegerOverflowAdd token;
    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        token = new IntegerOverflowAdd();
        vm.stopPrank();
    }

    function test_mintIntegerOverflow() public {
        // First mint: Set user's balance to maximum uint256
        vm.prank(owner);
        token.mint(user, type(uint256).max);
        
        // Verify initial mint succeeded
        assertEq(token.getBalance(user), type(uint256).max, "Initial mint failed");
        
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 preBalance = token.getBalance(user);
        uint256 preSupply = token.totalSupply();
        console.log("User balance before: ", preBalance);
        console.log("Total supply before: ", preSupply);

        console.log("--- Trigger Mint ---");
        // Second mint: Attempt to add 1 causing overflow
        vm.prank(owner);
        token.mint(user, 1);
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 postBalance = token.getBalance(user);
        uint256 postSupply = token.totalSupply();
        console.log("User balance after: ", postBalance);
        console.log("Total supply after: ", postSupply);
        
        // Determine vulnerability existence
        bool vulnerabilityExists = (preBalance == type(uint256).max) && 
                                (preSupply == type(uint256).max) && 
                                (postBalance == 0) && 
                                (postSupply == 0);

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Balance and supply overflowed from max to 0");
        } else {
            console.log("Vulnerability not Exist: No overflow occurred as expected");
        }
        
        // Verify balance overflow occurred (wrap-around to zero) - keeping original assert
        assertEq(token.getBalance(user), 0, "Overflow did not occur");
    }
}