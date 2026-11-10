// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

contract RealOldFuckMakerTest is Test {
    RealOldFuckMaker public fuckMaker;
    address public user = makeAddr("user");
    
    function setUp() public {
        fuckMaker = new RealOldFuckMaker();
    }

    function test_TotalFucksMadeOverflow() public {
        bytes32 slot = bytes32(uint256(2)); // Assuming totalFucksMade is at storage slot 2
        bytes32 initialValue = bytes32(type(uint256).max - 1);
        vm.store(address(fuckMaker), slot, initialValue);

        // BEFORE snapshot
        uint256 preTotal = uint256(vm.load(address(fuckMaker), slot));
        (uint256 preUserFucks,) = fuckMaker.getUserStats(user);
        console.log("--- BEFORE-Trigger ---");
        console.log("Total Fucks Made (before):", preTotal);
        console.log("User Fucks (before):", preUserFucks);

        console.log("--- Trigger: makeOldFucks(2) ---");
        vm.prank(user);
        vm.expectRevert();
        fuckMaker.makeOldFucks(2);

        // AFTER snapshot
        uint256 postTotal = uint256(vm.load(address(fuckMaker), slot));
        (uint256 postUserFucks,) = fuckMaker.getUserStats(user);
        console.log("--- AFTER-Trigger ---");
        console.log("Total Fucks Made (after):", postTotal);
        console.log("User Fucks (after):", postUserFucks);

        // FINAL VERDICT
        bool stateUnchanged = (preTotal == postTotal) && (preUserFucks == postUserFucks);
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Overflow caused revert and state unchanged");
        } else {
            console.log("Vulnerability not Exist: State changed unexpectedly");
        }
    }
}