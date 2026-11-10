// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract KeyCashGameFeeManipulationTest is Test {
    KeyCashGame game;
    address owner = address(0xA11CE);

    function setUp() public {
        // Deploy the target contract with the test-defined owner as msg.sender.
        vm.prank(owner);
        game = new KeyCashGame();
    }

    function testOwnerCanSetEarningPlatformShareTo100Percent() public {
        assertEq(game.owner(), owner);

        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 prizeShareBefore = game.sharePrizePoolForEarningPlatform();
        uint256 ticketShareBefore = game.shareTicketPriceForEarningPlatform();
        console.log("Prize pool earning-platform share before:", prizeShareBefore);
        console.log("Ticket price earning-platform share before:", ticketShareBefore);

        console.log("--- Trigger: owner sets earning-platform shares to 100% ---");
        vm.startPrank(owner);

        // No maximum cap is enforced: 100% of the prize pool can be redirected
        // to the earning platform/team wallet.
        game.setPrizePoolShare(0, 0, 0, 100);

        // Same issue for ticket-price distribution: 100% can go to the
        // earning platform/team wallet.
        game.setTicketPriceShare(0, 0, 100);

        vm.stopPrank();

        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 prizeShareAfter = game.sharePrizePoolForEarningPlatform();
        uint256 ticketShareAfter = game.shareTicketPriceForEarningPlatform();
        console.log("Prize pool earning-platform share after:", prizeShareAfter);
        console.log("Ticket price earning-platform share after:", ticketShareAfter);

        bool prizeChanged = prizeShareAfter != prizeShareBefore;
        bool ticketChanged = ticketShareAfter != ticketShareBefore;
        bool prizeEqualsManipulatedValue = prizeShareAfter == 100;
        bool ticketEqualsManipulatedValue = ticketShareAfter == 100;

        console.log("Prize pool earning-platform share changed:", prizeChanged);
        console.log("Ticket price earning-platform share changed:", ticketChanged);
        console.log("Prize pool earning-platform share equals 100:", prizeEqualsManipulatedValue);
        console.log("Ticket price earning-platform share equals 100:", ticketEqualsManipulatedValue);

        if (prizeChanged && ticketChanged && prizeEqualsManipulatedValue && ticketEqualsManipulatedValue) {
            console.log("Vulnerability Exists: owner can set prize-pool and ticket-price earning-platform shares to 100% without a cap");
        } else {
            console.log("Vulnerability not Exist: earning-platform shares did not both change to the manipulated 100% values");
        }
    }
}