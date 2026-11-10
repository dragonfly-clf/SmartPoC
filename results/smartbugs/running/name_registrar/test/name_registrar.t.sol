// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/name_registrar.sol";

contract NameRegistrarTest is Test {
    NameRegistrar registrar;
    address user1 = address(0x1);
    address user2 = address(0x2);
    bytes32 name1 = keccak256("test1");
    bytes32 name2 = keccak256("test2");
    address mappedAddress1 = address(0x3);
    address mappedAddress2 = address(0x4);

    function setUp() public {
        registrar = new NameRegistrar();
        registrar.setRegistrationFee(1 ether);
        
        // Set unlocked state directly in storage
        // Assuming unlocked is the first storage slot (slot 0)
        vm.store(address(registrar), bytes32(uint256(0)), bytes32(uint256(1)));
    }

    function testUninitializedStorageIssue() public {
        // Fund users
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // User1 registers a name
        vm.prank(user1);
        registrar.register{value: 1 ether}(name1, mappedAddress1);

        // Check registration was successful
        assertEq(registrar.resolve(name1), mappedAddress1);

        console.log("--- BEFORE-Trigger ---");
        address resolutionBefore = registrar.resolve(name1);
        console.log("User1 name resolution BEFORE attack:", resolutionBefore);

        console.log("--- TRIGGER: User2 Registration ---");
        // User2 registers a name - this should potentially overwrite due to vulnerability
        vm.prank(user2);
        registrar.register{value: 1 ether}(name2, mappedAddress2);

        console.log("--- AFTER-Trigger ---");
        address resolutionAfter = registrar.resolve(name1);
        console.log("User1 name resolution AFTER attack:", resolutionAfter);

        // Check if vulnerability exists (resolution changed)
        if (resolutionBefore != resolutionAfter) {
            console.log("State Changed: User1's name registration was corrupted");
            console.log("Vulnerability Exists: Uninitialized storage allows overwriting other registrations");
        } else {
            console.log("State Unchanged: User1's name registration remains intact");
            console.log("Vulnerability not Exist: Storage assignments are independent");
        }
        
        // Additional checks
        assertEq(registrar.resolve(name2), mappedAddress2);
        assertEq(registrar.totalRegistrations(), 2, "Should have 2 total registrations");
        assertTrue(
            registrar.resolve(name1) != registrar.resolve(name2),
            "Names should resolve to different addresses"
        );
    }
}