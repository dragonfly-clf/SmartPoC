// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/blackjack.sol";

contract BlackJackTest is Test {
    BlackJack public blackjack;
    address public constant PLAYER = address(0x123);
    uint256 public constant MIN_BET = 1 wei;
    uint256 public constant MAX_BET = 100 ether;
    uint256 public constant ARRAY_SIZE = 5000; // Set to large size to guarantee gas exhaustion

    function setUp() public {
        blackjack = new BlackJack();
        
        // Set minBet and maxBet via storage manipulation
        // Corrected storage slots (0 = minBet, 1 = maxBet)
        bytes32 MINBET_SLOT = bytes32(uint256(0));
        bytes32 MAXBET_SLOT = bytes32(uint256(1));
        vm.store(address(blackjack), MINBET_SLOT, bytes32(uint256(MIN_BET)));
        vm.store(address(blackjack), MAXBET_SLOT, bytes32(uint256(MAX_BET)));
    }

    function testGasLimitInCalculateScore() public {
        // Fund player and start their context
        vm.deal(PLAYER, 1 ether);
        vm.startPrank(PLAYER);
        
        // Start game with minimum bet
        blackjack.deal{value: MIN_BET}();

        // Get game storage locations
        uint256 mapSlot = 2; // games slot
        bytes32 playerMapKey = keccak256(abi.encode(PLAYER, mapSlot));
        bytes32 playerCardsLengthSlot = bytes32(uint256(playerMapKey) + 3);
        
        // Set playerCards length to extremely large value
        vm.store(address(blackjack), playerCardsLengthSlot, bytes32(ARRAY_SIZE));
        
        vm.stopPrank();

        // Test stand() which should revert due to gas exhaustion
        vm.startPrank(PLAYER);
        console.log("--- Trigger stand() with gas exhaustion ---");
        try blackjack.stand() {
            console.log("Vulnerability not Exist: stand() call did not revert (should be impossible with huge array)");
        } catch (bytes memory) {
            console.log("Vulnerability Exists: stand() reverted due to gas exhaustion");
        }
        vm.stopPrank();
    }
}