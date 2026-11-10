// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette roulette;
    address player = address(0x1);

    // Helper to read private slot 37 (where secretNumber is stored)
    function readSecretNumber(address rouletteAddr) private view returns (uint8) {
        bytes32 slot = bytes32(uint256(37));
        bytes32 data = vm.load(rouletteAddr, slot);
        return uint8(uint256(data));
    }

    function testShuffleReusesBlockParametersInSameBlock() public {
        // Deploy contract (this happens in its own block)
        roulette = new CryptoRoulette();

        // Advance to new block for clean setup
        vm.roll(block.number + 1);

        // Fund player and prepare for interaction
        vm.deal(player, 1 ether);

        // Before Trigger: State snapshot
        console.log("--- BEFORE-Trigger Play ---");
        uint8 initialSecret = readSecretNumber(address(roulette));
        console.log("Initial secret number:", initialSecret);

        // Play first time
        console.log("--- Trigger: First Play ---");
        vm.startPrank(player);
        uint256 betPrice = roulette.betPrice();
        roulette.play{value: betPrice}(1);
        vm.stopPrank();
        
        uint8 secretAfterFirstPlay = readSecretNumber(address(roulette));
        console.log("Secret after first play:", secretAfterFirstPlay);

        // Play second time in same block/transaction
        console.log("--- Trigger: Second Play ---");
        vm.startPrank(player);
        roulette.play{value: betPrice}(1);
        vm.stopPrank();
        
        // After Trigger: State snapshot and comparison
        console.log("--- AFTER-Second Trigger Play ---");
        uint8 secretAfterSecondPlay = readSecretNumber(address(roulette));
        console.log("Secret after second play:", secretAfterSecondPlay);

        // Vulnerability determination
        if (secretAfterFirstPlay == secretAfterSecondPlay) {
            console.log("Secrets Identical: Vulnerability Exists - Block parameters reused in same block");
            console.log("Vulnerability Exists: Block parameters reused in same block causing identical secret numbers");
        } else {
            console.log("Secrets Different: Vulnerability not Exist - Block parameters changed between plays");
            console.log("Vulnerability not Exist: Block parameters changed between plays creating different secrets");
        }

        // Original assertion for test correctness
        assertEq(secretAfterFirstPlay, secretAfterSecondPlay);
    }
}