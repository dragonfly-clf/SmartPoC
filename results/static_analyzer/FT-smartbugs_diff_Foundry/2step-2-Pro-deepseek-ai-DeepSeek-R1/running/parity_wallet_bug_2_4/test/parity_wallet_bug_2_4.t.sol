// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_2.sol";

contract WalletLibraryTest is Test {
    WalletLibrary public wallet;
    address[] public owners;
    uint256 public constant NUM_OWNERS = 250;

    function setUp() public {
        // Initialize owner addresses
        owners = new address[](NUM_OWNERS);
        for (uint256 i = 0; i < NUM_OWNERS; i++) {
            owners[i] = address(uint160(i + 1)); // Owner addresses: 0x1, 0x2, etc.
        }

        // Deploy and initialize wallet
        wallet = new WalletLibrary();
        wallet.initWallet(owners, 1, 0); // Initialize with 250 owners, requirement=1
    }

    function testRemoveOwnerGasConsumption() public {
        // Get first owner and ensure it owns itself
        address firstOwner = owners[0];
        assertTrue(wallet.isOwner(firstOwner));

        console.log("--- BEFORE-Trigger: Owner Removal ---");
        console.log("Owner %s exists: true", firstOwner);

        console.log("--- Trigger: removeOwner called ---");
        // Record gas usage for removal operation
        uint256 gasStart = gasleft();
        vm.prank(firstOwner);
        wallet.removeOwner(firstOwner);
        uint256 gasUsed = gasStart - gasleft();

        console.log("--- AFTER-Trigger: Owner Removal ---");
        // Validate owner was removed
        assertFalse(wallet.isOwner(firstOwner));
        console.log("Owner %s exists: false", firstOwner);
        console.log("Gas Used for removal: %s", gasUsed);

        // Final verdict based on gas consumption
        if (gasUsed > 300_000) {
            console.log("Vulnerability Exists: Gas consumption exceeded 300,000 gas, indicating DoS risk");
        } else {
            console.log("Vulnerability not Exist: Gas consumption was within acceptable limits");
        }
    }
}