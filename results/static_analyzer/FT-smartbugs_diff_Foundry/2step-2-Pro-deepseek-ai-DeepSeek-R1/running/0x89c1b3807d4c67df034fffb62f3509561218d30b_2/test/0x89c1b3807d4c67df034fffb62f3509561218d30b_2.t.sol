// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

contract TownCrierTest is Test {
    TownCrier public townCrier;
    address public owner = address(0x123);

    function setUp() public {
        vm.prank(owner);
        townCrier = new TownCrier();
    }

    function test_upgradeWithHighBitAddress() public {
        address highBitAddress = address(
            uint160(0x8000000000000000000000000000000000000000)
        );
        int256 expectedVersion = int256(int(int160(uint160(highBitAddress))));
        
        console.log("--- BEFORE-Trigger State ---");
        int preNewVersion = townCrier.newVersion();
        bool preKillswitch = townCrier.killswitch();
        console.log("Current newVersion: %d", preNewVersion);
        console.log("Current killswitch: %s", preKillswitch);
        require(preNewVersion == 0, "Initial newVersion not 0");
        require(!preKillswitch, "Initial killswitch not false");

        console.log("--- Trigger Upgrade ---");
        vm.recordLogs();
        vm.prank(owner);
        townCrier.upgrade(highBitAddress);

        console.log("--- AFTER-Trigger State ---");
        int postNewVersion = townCrier.newVersion();
        bool postKillswitch = townCrier.killswitch();
        console.log("New newVersion: %d", postNewVersion);
        console.log("New killswitch: %s", postKillswitch);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 1, "Expected event not emitted");

        bytes32 expectedEventSig = keccak256("Upgrade(address)");
        assertEq(
            entries[0].topics[0],
            expectedEventSig,
            "Incorrect event signature"
        );

        address loggedAddress;
        if (entries[0].data.length > 0) {
            loggedAddress = abi.decode(entries[0].data, (address));
        } else {
            assertGe(
                entries[0].topics.length,
                2,
                "Missing indexed address in topics"
            );
            loggedAddress = address(
                uint160(uint256(entries[0].topics[1]))
            );
        }

        assertEq(
            loggedAddress,
            highBitAddress,
            "Logged address mismatch"
        );
        
        if (postNewVersion == expectedVersion && postKillswitch) {
            console.log("Vulnerability Exists: newVersion set to high-bit integer and killswitch activated");
        } else {
            console.log("Vulnerability not Exist: State changes not as expected");
        }
    }
}