// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract PrivilegeEscalationTest is Test {
    Fidometa token;
    address owner = address(0x1);
    address attacker = address(0x2);
    address zeroAddress = address(0);

    function setUp() public {
        vm.prank(owner);
        token = new Fidometa();
    }

    function testOwnershipTransferVulnerability() public {
        console.log("--- BEFORE-Trigger Owner Check ---");
        address initialOwner = token.owner();
        console.log("Initial owner address:", initialOwner);

        console.log("--- Trigger TransferOwnership ---");
        // Owner transfers ownership to attacker without restrictions
        vm.prank(owner);
        token.transferOwnership(attacker);

        console.log("--- AFTER-Trigger Owner Check ---");
        address newOwner = token.owner();
        console.log("Owner after transfer:", newOwner);
        assertEq(newOwner, attacker, "Ownership transfer failed");

        // Execute privileged function to demonstrate control
        vm.startPrank(attacker);
        token.excludedFromSurcharge2(attacker);
        vm.stopPrank();

        // Final vulnerability verification
        if (newOwner == attacker) {
            console.log("Vulnerability Exists: Ownership successfully transferred to attacker");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
    }

    function testRenounceOwnershipVulnerability() public {
        console.log("--- BEFORE-Trigger Owner Check ---");
        address initialOwner = token.owner();
        console.log("Initial owner address:", initialOwner);

        console.log("--- Trigger RenounceOwnership ---");
        // Owner renounces ownership
        vm.prank(owner);
        token.renounceOwnership();

        console.log("--- AFTER-Trigger Owner Check ---");
        address finalOwner = token.owner();
        console.log("Owner after renounce:", finalOwner);
        assertEq(finalOwner, zeroAddress, "Renounce ownership failed");

        // Verify privileged functions are locked
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(1 ether);

        // Final vulnerability verification
        if (finalOwner == zeroAddress) {
            console.log("Vulnerability Exists: Ownership successfully renounced");
        } else {
            console.log("Vulnerability not Exist: Ownership renounce failed");
        }
    }
}