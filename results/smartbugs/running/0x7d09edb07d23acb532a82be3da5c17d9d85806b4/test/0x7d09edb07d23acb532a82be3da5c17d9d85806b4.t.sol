// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

contract PoCGameTest is Test {
    PoCGame game;
    address whale = address(0x123);
    address player = address(0x456);
    uint256 wagerLimit = 1 ether;

    function setUp() public {
        game = new PoCGame(whale, wagerLimit);
        
        // Make the game open to public
        vm.prank(address(this));
        game.OpenToThePublic();

        // Fund the player
        vm.deal(player, 10 ether);
    }

    function testUncheckedDonateCall() public {
        // Create a mock whale contract that will reject donations
        MockWhale mockWhale = new MockWhale();
        game = new PoCGame(address(mockWhale), wagerLimit);
        vm.prank(address(this));
        game.OpenToThePublic();

        // Get initial whale balance
        uint256 whaleBalanceBefore = address(mockWhale).balance;
        console.log("--- BEFORE-Trigger Donate ---");
        console.log("MockWhale Balance (before): %d", whaleBalanceBefore);

        // Player makes a donation that will be rejected by whale
        console.log("--- Trigger Donate ---");
        vm.prank(player);
        game.donate{value: 1 ether}();

        // Get whale balance after donation
        uint256 whaleBalanceAfter = address(mockWhale).balance;
        console.log("--- AFTER-Trigger Donate ---");
        console.log("MockWhale Balance (after): %d", whaleBalanceAfter);

        // Verify balances are the same (no change)
        if (whaleBalanceAfter == whaleBalanceBefore) {
            console.log("Vulnerability Exists: Whale balance unchanged after donation - silent failure with ETH stuck");
        } else {
            console.log("Vulnerability not Exist: Whale balance changed during donation");
        }

        // Verify the ETH wasn't transferred
        assertEq(whaleBalanceAfter, 0, "ETH was transferred despite rejection");
    }

    function testUncheckedLoseWagerCall() public {
        // Create a mock whale contract that will reject donations
        MockWhale mockWhale = new MockWhale();
        game = new PoCGame(address(mockWhale), wagerLimit);
        vm.prank(address(this));
        game.OpenToThePublic();

        // Fund the game contract to simulate wager loss
        vm.deal(address(game), 1 ether);

        // Get initial whale balance
        uint256 whaleBalanceBefore = address(mockWhale).balance;
        console.log("--- BEFORE-Trigger loseWager ---");
        console.log("MockWhale Balance (before): %d", whaleBalanceBefore);

        // Directly test loseWager (bypassing play() which has other requirements)
        console.log("--- Trigger loseWager ---");
        vm.prank(address(this)); 
        (bool success,) = address(game).call(abi.encodeWithSignature("loseWager(uint256)", 0.5 ether));
        console.log("Call to loseWager: %s", success ? "did not revert" : "reverted");
        
        // Get whale balance after wager loss
        uint256 whaleBalanceAfter = address(mockWhale).balance;
        console.log("--- AFTER-Trigger loseWager ---");
        console.log("MockWhale Balance (after): %d", whaleBalanceAfter);

        // Verify both conditions: call didn't revert and balances unchanged
        if (success && whaleBalanceAfter == whaleBalanceBefore) {
            console.log("Vulnerability Exists: Silent failure with ETH stuck during loseWager call");
        } else {
            console.log("Vulnerability not Exist: Call reverted or whale balance changed");
        }

        // Verify the ETH wasn't transferred
        assertEq(address(mockWhale).balance, 0, "ETH was transferred despite rejection");
    }
}

contract MockWhale {
    // This contract will reject all donations
    function donate() external payable {
        revert("MockWhale rejecting donations");
    }
}