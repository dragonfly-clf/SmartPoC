// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Wheely.sol";

contract WheelyAuditTest is Test {
    Wheely token;
    address owner = address(0x111);
    address hacker = address(0x666);

    function setUp() public {
        vm.startPrank(owner);
        token = new Wheely(
            "VulnerableToken", 
            "VULN", 
            18, 
            1000000, 
            address(0xFee)
        );
        vm.stopPrank();
    }

    // Test: Ownership transfer vulnerability
    function test_unauthorizedOwnershipTransfer() public {
        // 1. Verify original owner
        assertEq(token.owner(), owner, "Initial owner should be deployer");

        console.log("--- BEFORE-Trigger Ownership Record ---");
        address preOwner = token.owner();
        console.log("Current owner: %s", preOwner);

        console.log("--- Trigger Unauthorized Transfer by Hacker ---");
        bool success;
        vm.prank(hacker);
        // Low-level call to avoid test auto-revert
        (success, ) = address(token).call(
            abi.encodeWithSignature("transferOwnership(address)", hacker)
        );

        console.log("--- AFTER-Trigger Ownership Record ---");
        address postOwner = token.owner();
        console.log("New owner: %s", postOwner);

        // Verdict logic
        string memory finalVerdict;
        if (success && postOwner == hacker) {
            finalVerdict = "Vulnerability Exists: Unauthorized ownership transfer succeeded";
        } else {
            finalVerdict = "Vulnerability not Exist: Unauthorized transfer failed with revert or no ownership change";
        }

        // Final verdict single line output
        console.log(finalVerdict);
        
        // Force test failure if vulnerability exists (security bypass)
        if (success && postOwner == hacker) {
            fail(); // Foundry function to mark test as failed
        }
    }
}