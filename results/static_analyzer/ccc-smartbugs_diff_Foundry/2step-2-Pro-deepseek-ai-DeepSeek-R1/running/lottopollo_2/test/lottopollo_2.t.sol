// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lottopollo.sol";

contract LottopolloTest is Test {
    lottopollo public lotto;

    function setUp() public {
        lotto = new lottopollo();
    }

    function test_PredictableRandomness() public {
        console.log("--- BEFORE-Trigger RandomGen ---");
        uint firstBlockTime = block.timestamp;
        uint firstRandom = lotto.randomGen();
        console.log("Block Timestamp: %d", firstBlockTime);
        console.log("RandomGen result: %d", firstRandom);
        console.log("Comparison: First output matches block timestamp?",
            firstRandom == firstBlockTime ? "YES" : "NO");

        console.log("--- Trigger Warp ---");
        uint newTime = firstBlockTime + 100;
        vm.warp(newTime);
        console.log("Warped Block Timestamp to: %d", newTime);

        console.log("--- AFTER-Trigger RandomGen ---");
        uint afterBlockTime = block.timestamp;
        uint secondRandom = lotto.randomGen();
        console.log("Block Timestamp after warp: %d", afterBlockTime);
        console.log("RandomGen result: %d", secondRandom);
        console.log("Comparison: Second output matches new timestamp?",
            secondRandom == newTime ? "YES" : "NO");

        bool vulnerabilityExists = (firstRandom == firstBlockTime) && 
                                   (secondRandom == newTime);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: The random number generator outputs the current block timestamp, making lottery results predictable and manipulable by miners.");
        } else {
            console.log("Vulnerability not Exist: Random number generator does not solely depend on block.timestamp or the test environment didn't properly manipulate time.");
        }
    }
}