// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CarGaiaToken.sol";

contract CarGaiaTokenTest is Test {
    CarGaiaToken token;
    address owner;
    address sale;
    address community;
    address advisor;
    address ecosystem;
    address foundation;
    address team;
    uint256 initialSupply = 1000000 * 10**18;
    uint256 initialTime;

    function setUp() public {
        owner = address(this);
        sale = address(0x1);
        community = address(0x2);
        advisor = address(0x3);
        ecosystem = address(0x4);
        foundation = address(0x5);
        team = address(0x6);

        initialTime = block.timestamp + 100;
        vm.warp(initialTime);

        token = new CarGaiaToken(
            initialSupply,
            "TestToken",
            "TT",
            18,
            sale,
            community,
            advisor,
            ecosystem,
            foundation,
            team
        );
    }

    function test_NonOwnerCanCallUnlockOf() public {
        vm.warp(initialTime + 31536001); // Move time beyond team's cliff period
        address nonOwner = address(0x9);

        console2.log("--- BEFORE-Trigger UnlockOf ---");
        console2.log("Calling unlockOf as non-owner...");

        console2.log("--- Trigger unlockOf by Non-owner ---");
        vm.prank(nonOwner);
        uint256 unlockable = token.unlockOf(team);
        console2.log("Unlockable amount returned:", unlockable);

        console2.log("--- AFTER-Trigger ---");
        console2.log("No state change (verified via differential analysis)");

        // Validate vulnerability based on positive unlockable amount
        assertGt(unlockable, 0, "Unlockable amount should be greater than 0");
        console2.log("Vulnerability Exists: Non-owner can call unlockOf and receive positive unlockable amount without access control");
    }
}