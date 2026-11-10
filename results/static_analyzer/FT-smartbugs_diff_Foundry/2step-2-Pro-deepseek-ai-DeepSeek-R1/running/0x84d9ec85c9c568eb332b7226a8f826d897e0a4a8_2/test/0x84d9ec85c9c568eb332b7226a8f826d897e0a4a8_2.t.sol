// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x84d9ec85c9c568eb332b7226a8f826d897e0a4a8.sol";

contract WedIndexAuthorizationTest is Test {
    WedIndex wedIndex;
    address owner = address(0x01);
    address validNewOwner = address(0x02);
    address stranger = address(0x03);
    address zeroAddress = address(0);

    function setUp() public {
        vm.prank(owner);
        wedIndex = new WedIndex();
    }

    function testVulnerableChangeOwnerToZero() public {
        console.log("--- BEFORE-Trigger changeOwner ---");
        address prevOwner = wedIndex.owner();
        address prevNewOwner = wedIndex.newOwner();
        console.log("Current owner: %s", prevOwner);
        console.log("Current newOwner: %s", prevNewOwner);

        console.log("--- Trigger changeOwner(zeroAddress) ---");
        vm.prank(owner);
        wedIndex.changeOwner(zeroAddress);
        
        console.log("--- AFTER-Trigger changeOwner ---");
        address postChangeNewOwner = wedIndex.newOwner();
        console.log("New newOwner: %s", postChangeNewOwner);

        console.log("--- BEFORE-Trigger acceptOwnership ---");
        address preAcceptOwner = wedIndex.owner();
        console.log("Owner before accept: %s", preAcceptOwner);

        console.log("--- Trigger acceptOwnership(zeroAddress) ---");
        vm.prank(zeroAddress);
        wedIndex.acceptOwnership();
        
        console.log("--- AFTER-Trigger acceptOwnership ---");
        address postAcceptOwner = wedIndex.owner();
        console.log("Owner after accept: %s", postAcceptOwner);
        
        if (postAcceptOwner == zeroAddress) {
            console.log("Vulnerability Exists: Contract became ownerless");
        } else {
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
    }

    function testStrangerCannotAcceptOwnership() public {
        console.log("--- BEFORE-Trigger ownership transfer setup ---");
        address initialOwner = wedIndex.owner();
        address initialNewOwner = wedIndex.newOwner();
        console.log("Initial owner: %s", initialOwner);
        console.log("Initial newOwner: %s", initialNewOwner);

        vm.prank(owner);
        wedIndex.changeOwner(validNewOwner);

        console.log("--- AFTER-Trigger ownership transfer setup ---");
        address postSetupNewOwner = wedIndex.newOwner();
        console.log("NewOwner after setup: %s", postSetupNewOwner);
        console.log("Owner remains: %s", wedIndex.owner());

        console.log("--- BEFORE-Trigger stranger acceptOwnership ---");
        address beforeStrangerOwner = wedIndex.owner();
        console.log("Owner before stranger call: %s", beforeStrangerOwner);
        address beforeStrangerNewOwner = wedIndex.newOwner();
        console.log("NewOwner before stranger call: %s", beforeStrangerNewOwner);

        console.log("--- Trigger stranger.acceptOwnership ---");
        vm.prank(stranger);
        wedIndex.acceptOwnership();

        console.log("--- AFTER-Trigger stranger acceptOwnership ---");
        address afterStrangerOwner = wedIndex.owner();
        address afterStrangerNewOwner = wedIndex.newOwner();
        console.log("Owner after stranger call: %s", afterStrangerOwner);
        console.log("NewOwner after stranger call: %s", afterStrangerNewOwner);

        bool stateChangedDuringStrangerCall = 
            (afterStrangerOwner != beforeStrangerOwner) || 
            (afterStrangerNewOwner != beforeStrangerNewOwner);
            
        if (!stateChangedDuringStrangerCall) {
            console.log("Vulnerability not Exist: Unauthorized change blocked");
        } else {
            console.log("Vulnerability Exists: Ownership state changed by stranger");
        }

        // Valid new owner completes transfer
        vm.prank(validNewOwner);
        wedIndex.acceptOwnership();
        assertEq(wedIndex.owner(), validNewOwner);
    }
}