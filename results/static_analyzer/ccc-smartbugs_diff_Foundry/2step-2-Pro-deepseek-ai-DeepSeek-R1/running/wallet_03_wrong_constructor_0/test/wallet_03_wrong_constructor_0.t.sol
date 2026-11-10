// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract WalletInitTest is Test {
    Wallet public wallet;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.prank(deployer);
        wallet = new Wallet();
    }

    // Test that anyone can initialize the wallet
    function test_anyoneCanInitialize() public {
        console.log("--- BEFORE-Trigger Wallet Initialization ---");
        // No queryable state change expected

        console.log("--- Trigger: Attacker calls initWallet ---");
        // Attacker calls initWallet() without reverting
        vm.prank(attacker);
        wallet.initWallet();

        console.log("--- AFTER-Trigger ---");
        console.log("Vulnerability Exists: Attacker initialized contract without reverting");
    }

    // Test that the initializer can be called multiple times by anyone
    function test_reinitialization() public {
        console.log("--- BEFORE-Trigger: Initial Initialization (deployer) ---");
        // Deployer initializes
        vm.prank(deployer);
        wallet.initWallet();

        console.log("--- Trigger: Attacker reinitialization ---");
        vm.prank(attacker);
        wallet.initWallet();

        console.log("--- AFTER-Trigger ---");
        console.log("Vulnerability Exists: Attacker reinitialized contract without reverting");
    }
}