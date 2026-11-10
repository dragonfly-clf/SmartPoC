// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

contract PoCGameArbitrarySendTest is Test {
    PoCGame internal game;
    address internal whaleAddress = address(0x123); // Changed to valid whale address
    uint256 internal constant WAGER_LIMIT = 1 ether;
    
    address internal owner = makeAddr("owner");
    address internal alice = makeAddr("alice");
    address internal donor = makeAddr("donor");

    function setUp() public {
        vm.prank(owner);
        game = new PoCGame(whaleAddress, WAGER_LIMIT);
        
        vm.prank(owner);
        game.OpenToThePublic();
        
        vm.prank(owner);
        game.AdjustDifficulty(2); // Set winning number to 1

        // Prepare balances
        vm.deal(alice, 10 ether);
        vm.deal(donor, 10 ether);
    }

    function testArbitraryEthSend() public {
        uint256 initialContractBalance = address(game).balance;

        // Make wager as Alice (set both sender and origin)
        vm.prank(alice, alice);
        game.wager{value: 1 ether}();
        
        // Verify wager recorded
        assertTrue(game.hasPlayerWagered(alice), "Wager not recorded");
        
        // Large donation to increase vulnerability impact
        vm.prank(donor);
        payable(address(game)).transfer(5 ether);
        
        uint256 boostedBalance = address(game).balance;
        require(boostedBalance > initialContractBalance, "Donation failed");

        // Advance block for play()
        vm.roll(block.number + 5);

        console.log("--- BEFORE Trigger play() ---");
        uint256 aliceBalanceBefore = alice.balance;
        uint256 whaleBalanceBefore = whaleAddress.balance;
        uint256 contractBalanceBefore = address(game).balance;
        console.log("Contract ETH balance Before: %d", contractBalanceBefore);
        console.log("Alice ETH balance Before: %d", aliceBalanceBefore);
        console.log("Whale ETH balance Before: %d", whaleBalanceBefore);

        console.log("--- Trigger: play() ---");
        // Trigger play with proper EOA identity
        vm.prank(alice, alice);
        game.play();

        console.log("--- AFTER Trigger play() ---");
        uint256 aliceBalanceAfter = alice.balance;
        uint256 whaleBalanceAfter = whaleAddress.balance;
        uint256 contractBalanceAfter = address(game).balance;
        console.log("Contract ETH balance After: %d", contractBalanceAfter);
        console.log("Alice ETH balance After: %d", aliceBalanceAfter);
        console.log("Whale ETH balance After: %d", whaleBalanceAfter);
        
        // Differential verification
        bool whaleReceivedETH = whaleBalanceAfter != whaleBalanceBefore;
        if (whaleReceivedETH) {
            console.log("Vulnerability Verification: Whale ETH balance increased unexpectedly");
            console.log("Vulnerability Exists: Whale address received ETH arbitrarily");
        } else {
            console.log("Vulnerability Verification: Whale ETH balance unchanged");
            console.log("Vulnerability not Exist: Whale address ETH unchanged");
        }

        // Additional assertions
        uint256 expectedTransfer = contractBalanceBefore / 2;
        assertEq(
            aliceBalanceAfter,
            aliceBalanceBefore + expectedTransfer,
            "Winner not paid correctly"
        );
        assertEq(
            contractBalanceAfter,
            contractBalanceBefore - expectedTransfer,
            "Contract balance not reduced"
        );
        assertEq(
            whaleAddress.balance,
            whaleBalanceBefore,
            "Whale received ETH incorrectly"
        );
    }
}