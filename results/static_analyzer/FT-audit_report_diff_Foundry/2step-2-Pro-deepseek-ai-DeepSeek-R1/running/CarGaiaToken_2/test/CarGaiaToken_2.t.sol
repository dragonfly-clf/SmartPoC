// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CarGaiaToken.sol";

contract CarGaiaTokenTest is Test {
    CarGaiaToken token;
    address owner = address(0x1);
    address saleAddress = address(0x1000);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        vm.startPrank(owner);
        token = new CarGaiaToken(
            1_000_000 * 1e18,   // initialSupply
            "TestToken",         // name
            "TT",                // symbol
            18,                  // decimals
            saleAddress,         // sale
            address(0x1),        // community
            address(0x2),        // advisor
            address(0x3),        // ecosystem
            address(0x4),        // foundation
            address(0x5)         // team
        );
        vm.stopPrank();
        
        vm.prank(saleAddress);
        token.transfer(alice, 100 * 1e18);
    }

    function testTransferUnderflowVulnerability() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        // Record pre-trigger state
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        console2.log("Alice balance before:", aliceBefore);
        console2.log("Bob balance before:", bobBefore);

        console2.log("--- Trigger Transfer ---");
        // Attempt to transfer more than balance
        vm.prank(alice);
        vm.expectRevert(stdError.arithmeticError);
        token.transfer(bob, 101 * 1e18);

        console2.log("--- AFTER-Trigger Transfer ---");
        // Record post-trigger state
        uint256 aliceAfter = token.balanceOf(alice);
        uint256 bobAfter = token.balanceOf(bob);
        console2.log("Alice balance after:", aliceAfter);
        console2.log("Bob balance after:", bobAfter);

        // Compare states
        if (aliceBefore != aliceAfter || bobBefore != bobAfter) {
            console2.log("Vulnerability: Balances changed after underflow attempt");
            console2.log("Vulnerability Exists: Transfer underflow allowed without revert");
        } else {
            console2.log("Safeguard: Balances unchanged after underflow attempt");
            console2.log("Vulnerability not Exist: Transfer reverts safely on underflow");
        }
    }
}