// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/random_number_generator.sol";

contract WeakPRNGTest is Test {
    RandomNumberGenerator rng;

    function setUp() public {
        rng = new RandomNumberGenerator();
    }

    function testWeakPRNG() public {
        console2.log("--- Taking Initial Snapshot ---");
        uint256 snapshotId = vm.snapshot();

        console2.log("--- BEFORE First Game Call ---");
        uint256 initialWinningNumber = rng.winningNumber();
        console2.log("Initial winning number:", initialWinningNumber);

        console2.log("--- Trigger First Game Call ---");
        rng.playGame(1);
        uint256 firstResult = rng.winningNumber();
        console2.log("First call winning number:", firstResult);

        console2.log("--- Reverting to Snapshot ---");
        vm.revertTo(snapshotId);

        console2.log("--- BEFORE Second Game Call ---");
        uint256 winningNumberAfterRevert = rng.winningNumber();
        console2.log("Winning number after revert (should be initial):", winningNumberAfterRevert);

        console2.log("--- Trigger Second Game Call ---");
        rng.playGame(1);
        uint256 secondResult = rng.winningNumber();
        console2.log("Second call winning number:", secondResult);

        console2.log("--- Comparison Verdict ---");
        bool sameResult = (firstResult == secondResult);
        console2.log("Results are identical:", sameResult ? "YES" : "NO");

        if (sameResult) {
            console2.log("Vulnerability Exists: The same random number was generated twice in the same blockchain context, signifying a weak PRNG.");
        } else {
            console2.log("Vulnerability not Exist: Different random numbers were generated, indicating sufficient randomness resistance.");
        }

        // Final assertion for test results
        assertEq(firstResult, secondResult, "Weak PRNG produces identical results in same blockchain conditions");
    }
}