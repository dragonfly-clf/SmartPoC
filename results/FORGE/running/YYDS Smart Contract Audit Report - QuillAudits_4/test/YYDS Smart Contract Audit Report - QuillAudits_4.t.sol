// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YYDS.sol";

contract OwnableHarness is Ownable {
    function restrictedFunction() public onlyOwner {
        // Dummy function to test ownership
    }
}

contract OwnershipVulnerabilityTest is Test {
    OwnableHarness ownable;
    address public deployer = address(this);
    address public newOwner = address(0x123);
    address public attacker = address(0x666);

    function setUp() public {
        ownable = new OwnableHarness();
    }

    // Test one-step ownership renunciation vulnerability
    function test_renounceOwnershipVulnerability() public {
        // Verify deployer is initial owner
        assertEq(ownable.owner(), deployer);

        console.log("--- BEFORE-Trigger State ---");
        address ownerBefore = ownable.owner();
        console.log("Current owner before renounce:", ownerBefore);

        console.log("--- Trigger: renounceOwnership ---");
        ownable.renounceOwnership();
        
        console.log("--- AFTER-Trigger State ---");
        address ownerAfter = ownable.owner();
        console.log("Current owner after renounce:", ownerAfter);
        
        // Validate ownership is permanently lost
        assertEq(ownerAfter, address(0));
        
        // Verify contract critical functions become unusable
        vm.expectRevert("Ownable: caller is not the owner");
        ownable.restrictedFunction();

        // Final vulnerability verification
        if (ownerAfter == address(0)) {
            console.log("Vulnerability Exists: Ownership renounced in one-step operation");
        } else {
            console.log("Vulnerability not Exist: Ownership not successfully renounced");
        }
    }

    // Test one-step ownership transfer vulnerability
    function test_transferOwnershipVulnerability() public {
        // Verify deployer is initial owner
        assertEq(ownable.owner(), deployer);

        console.log("--- BEFORE-Trigger State ---");
        address ownerBefore = ownable.owner();
        console.log("Current owner before transfer:", ownerBefore);

        console.log("--- Trigger: transferOwnership(attacker) ---");
        ownable.transferOwnership(attacker);
        
        console.log("--- AFTER-Trigger State ---");
        address ownerAfter = ownable.owner();
        console.log("Current owner after transfer:", ownerAfter);
        
        // Validate immediate ownership transfer
        assertEq(ownerAfter, attacker);
        
        // Verify original owner loses access immediately
        vm.expectRevert("Ownable: caller is not the owner");
        ownable.restrictedFunction();
        
        // Verify new owner gains full control
        vm.prank(attacker);
        ownable.restrictedFunction();  // Should not revert

        // Final vulnerability verification
        if (ownerAfter == attacker) {
            console.log("Vulnerability Exists: Ownership transferred to attacker in one-step operation");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
    }

    // Test accidental transfer to zero address vulnerability
    function test_transferToZeroAddressVulnerability() public {
        console.log("--- BEFORE-Trigger State ---");
        address ownerBefore = ownable.owner();
        console.log("Current owner before transfer:", ownerBefore);

        console.log("--- Trigger: transferOwnership(address(0)) [Expected to revert] ---");
        vm.expectRevert("Ownable: new owner is the zero address");
        ownable.transferOwnership(address(0));

        console.log("--- AFTER-Trigger State ---");
        address ownerAfter = ownable.owner();
        console.log("Current owner after transfer attempt:", ownerAfter);

        // Final vulnerability verification
        if (ownerAfter == ownerBefore) {
            console.log("Vulnerability not Exist: Transfer to zero address prevented by safeguard");
        } else {
            console.log("Vulnerability Exists: Zero address transfer succeeded");
        }
    }
}